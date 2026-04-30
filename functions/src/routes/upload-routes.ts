import { Router } from "express";

import { env } from "../config/env";
import { ErrorCode } from "../errors/error-codes";
import { HttpError } from "../errors/http-error";
import { requireAuth, type AuthedRequest } from "../middleware/auth";
import { createDocument } from "../services/document-service";
import { deleteOrphanSessions } from "../services/cleanup-service";
import { createUploadUrl, headObject } from "../services/storj-service";
import {
  countActiveSessions,
  createUploadSession,
  markUploadSessionUsed,
  validateUploadSession,
} from "../services/upload-session-service";
import { buildFileKey, validateFile } from "../utils/file-utils";

export const uploadRouter = Router();

uploadRouter.post("/init", requireAuth, async (request, response, next) => {
  try {
    const { fileName = "", mimeType = "", sizeBytes = 0 } = request.body ?? {};
    validateFile(String(mimeType), Number(sizeBytes));
    
    const activeCount = await countActiveSessions((request as AuthedRequest).userId);
    if (activeCount >= env.uploadSessionLimitPerUser) {
      throw new HttpError(429, ErrorCode.rateLimited);
    }

    const fileKey = buildFileKey((request as AuthedRequest).userId, String(fileName), String(mimeType));
    await createUploadSession(fileKey, (request as AuthedRequest).userId, Number(sizeBytes));
    const url = await createUploadUrl(fileKey, String(mimeType));
    response.json({ url, fileKey });
  } catch (error) {
    console.error("[POST /upload/init] Error:", error);
    next(error);
  }
});

uploadRouter.post("/confirm", requireAuth, async (request, response, next) => {
  try {
    const { fileKey = "", type = "", fileName = "", mimeType = "", sizeBytes = 0 } = request.body ?? {};
    validateFile(String(mimeType), Number(sizeBytes));
    const session = await validateUploadSession(String(fileKey), (request as AuthedRequest).userId);
    
    // HEAD check
    const { exists, contentLength } = await headObject(String(fileKey));
    if (!exists || contentLength !== session.sizeBytes) {
      throw new HttpError(422, ErrorCode.uploadNotFound);
    }

    const document = await createDocument({
      fileKey: String(fileKey),
      fileName: String(fileName),
      mimeType: String(mimeType),
      ownerId: (request as AuthedRequest).userId,
      sizeBytes: Number(sizeBytes),
      type: String(type),
    });
    await markUploadSessionUsed(String(fileKey));
    response.json(document);
  } catch (error) {
    console.error("[POST /upload/confirm] Error:", error);
    next(error);
  }
});

// Internal endpoint meant to be called by a cron job
uploadRouter.post("/cleanup-orphans", async (_request, response, next) => {
  try {
    await deleteOrphanSessions();
    response.json({ ok: true });
  } catch (error) {
    console.error("[POST /upload/cleanup-orphans] Error:", error);
    next(error);
  }
});

