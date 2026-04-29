import {randomUUID} from "crypto";
import * as admin from "firebase-admin";
import {defineSecret, defineString} from "firebase-functions/params";
import {onRequest} from "firebase-functions/v2/https";
import {S3Client, PutObjectCommand} from "@aws-sdk/client-s3";
import {getSignedUrl} from "@aws-sdk/s3-request-presigner";

admin.initializeApp();

const storjAccessKey = defineSecret("STORJ_ACCESS_KEY");
const storjSecretKey = defineSecret("STORJ_SECRET_KEY");
const storjEndpoint = defineString("STORJ_ENDPOINT", {
  default: "https://gateway.storjshare.io",
});
const storjBucket = defineString("STORJ_BUCKET", {default: "ataa"});

const uploadSessions = admin.firestore().collection("uploadSessions");
const documents = admin.firestore().collection("documents");
const expiresInSeconds = 300;

type InitUploadBody = {
  fileName?: string;
  mimeType?: string;
  contentType?: string;
  sizeBytes?: number;
  scope?: string;
  schemaVersion?: number;
};

type RequestLike = any;
type ResponseLike = any;

function allowCors(response: ResponseLike): void {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  response.set(
    "Access-Control-Allow-Headers",
    "Authorization, Content-Type, x-user-id",
  );
}

async function requireUserId(request: RequestLike): Promise<string> {
  const authorization = request.header("authorization") ?? "";
  const match = authorization.match(/^Bearer (.+)$/i);
  if (!match) {
    throw new Error("Missing Firebase ID token");
  }

  const decodedToken = await admin.auth().verifyIdToken(match[1]);
  const headerUserId = request.header("x-user-id");
  if (headerUserId && headerUserId !== decodedToken.uid) {
    throw new Error("Authenticated user mismatch");
  }

  return decodedToken.uid;
}

function sanitizePathPart(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 120);
}

function resolveStorageKey(userId: string, body: InitUploadBody): string {
  const fileName = sanitizePathPart(body.fileName ?? "document");
  const scope = sanitizePathPart(body.scope ?? "documents");
  const safeFileName = fileName || "document";
  const safeScope = scope || "documents";
  return `beneficiaries/${userId}/${safeScope}/${randomUUID()}-${safeFileName}`;
}

function createS3Client(): S3Client {
  return new S3Client({
    region: "us-east-1",
    endpoint: storjEndpoint.value(),
    forcePathStyle: true,
    credentials: {
      accessKeyId: storjAccessKey.value(),
      secretAccessKey: storjSecretKey.value(),
    },
  });
}

function sendError(
  response: ResponseLike,
  status: number,
  message: string,
): void {
  response.status(status).json({error: message});
}

async function handleInitUpload(
  request: RequestLike,
  response: ResponseLike,
): Promise<void> {
  if (request.method !== "POST") {
    sendError(response, 405, "Method not allowed");
    return;
  }

  try {
    const userId = await requireUserId(request);
    const body = request.body as InitUploadBody;
    const contentType = body.mimeType ?? body.contentType;
    if (!contentType) {
      sendError(response, 400, "mimeType is required");
      return;
    }

    const storageKey = resolveStorageKey(userId, body);
    const uploadId = randomUUID();
    const expiresAt = new Date(Date.now() + expiresInSeconds * 1000);
    const command = new PutObjectCommand({
      Bucket: storjBucket.value(),
      Key: storageKey,
      ContentType: contentType,
    });
    const signedUrl = await getSignedUrl(createS3Client(), command, {
      expiresIn: expiresInSeconds,
    });

    await uploadSessions.doc(uploadId).set({
      uploadId,
      ownerId: userId,
      storageKey,
      bucket: storjBucket.value(),
      contentType,
      fileName: body.fileName ?? null,
      sizeBytes: body.sizeBytes ?? null,
      scope: body.scope ?? null,
      schemaVersion: body.schemaVersion ?? 1,
      status: "initialized",
      expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    response.json({
      uploadId,
      signedUrl,
      uploadUrl: signedUrl,
      storageKey,
      filePath: storageKey,
      expiresAt: expiresAt.toISOString(),
      headers: {"Content-Type": contentType},
    });
  } catch (error) {
    sendError(
      response,
      401,
      error instanceof Error ? error.message : "Unauthorized",
    );
  }
}

async function handleConfirmUpload(
  request: RequestLike,
  response: ResponseLike,
): Promise<void> {
  if (request.method !== "POST") {
    sendError(response, 405, "Method not allowed");
    return;
  }

  try {
    const userId = await requireUserId(request);
    const uploadId = String(request.body?.uploadId ?? "");
    const type = String(request.body?.type ?? "document");
    const sessionRef = uploadSessions.doc(uploadId);
    const session = await sessionRef.get();
    if (!session.exists) {
      sendError(response, 404, "Upload session not found");
      return;
    }

    const data = session.data() ?? {};
    if (data.ownerId !== userId) {
      sendError(response, 403, "Upload session owner mismatch");
      return;
    }

    const documentRef = documents.doc();
    const now = admin.firestore.FieldValue.serverTimestamp();
    const document = {
      id: documentRef.id,
      uploadId,
      ownerId: userId,
      type,
      displayName: type,
      fileName: data.fileName ?? "",
      storageKey: data.storageKey,
      url: `${storjEndpoint.value()}/${storjBucket.value()}/${data.storageKey}`,
      mimeType: data.contentType,
      sizeBytes: data.sizeBytes ?? 0,
      status: "stored",
      isDeleted: false,
      schemaVersion: data.schemaVersion ?? 1,
      createdAt: now,
      updatedAt: now,
    };

    await documentRef.set(document);
    await sessionRef.set(
      {status: "confirmed", confirmedAt: now, documentId: documentRef.id},
      {merge: true},
    );

    response.json(document);
  } catch (error) {
    sendError(
      response,
      401,
      error instanceof Error ? error.message : "Unauthorized",
    );
  }
}

export const uploadApi = onRequest(
  {
    region: "us-central1",
    secrets: [storjAccessKey, storjSecretKey],
  },
  async (request, response) => {
    allowCors(response);
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }

    if (request.path === "/init-upload") {
      await handleInitUpload(request, response);
      return;
    }
    if (request.path === "/confirm-upload") {
      await handleConfirmUpload(request, response);
      return;
    }

    sendError(response, 404, "Upload route not found");
  },
);
