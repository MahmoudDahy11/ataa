import { getFirestore, Timestamp } from "firebase-admin/firestore";

import { ErrorCode } from "../errors/error-codes";
import { HttpError } from "../errors/http-error";
import { sessionId } from "../utils/file-utils";

const sessions = () => getFirestore().collection("upload_sessions");

export async function createUploadSession(
  fileKey: string,
  userId: string,
  sizeBytes: number,
): Promise<void> {
  const expiresAt = Timestamp.fromMillis(Date.now() + 10 * 60 * 1000);
  await sessions().doc(sessionId(fileKey)).set({
    fileKey,
    userId,
    sizeBytes,
    used: false,
    expiresAt,
    createdAt: Timestamp.now(),
  });
}

export async function validateUploadSession(
  fileKey: string,
  userId: string,
): Promise<FirebaseFirestore.DocumentData> {
  const snapshot = await sessions().doc(sessionId(fileKey)).get();
  const data = snapshot.data();
  if (!snapshot.exists || !data)
    throw new HttpError(404, ErrorCode.uploadSessionNotFound);
  if (data.userId !== userId) throw new HttpError(401, ErrorCode.unauthorized);
  if (data.used) throw new HttpError(409, ErrorCode.uploadAlreadyConfirmed);
  if (data.expiresAt?.toMillis?.() <= Date.now()) {
    throw new HttpError(410, ErrorCode.uploadSessionExpired);
  }
  return data;
}

export async function markUploadSessionUsed(fileKey: string): Promise<void> {
  await sessions().doc(sessionId(fileKey)).update({
    used: true,
    usedAt: Timestamp.now(),
  });
}

export async function countActiveSessions(userId: string): Promise<number> {
  const snap = await sessions()
    .where("userId", "==", userId)
    .where("used", "==", false)
    .get();
  
  const now = Date.now();
  return snap.docs.filter((doc) => {
    const data = doc.data();
    return data.expiresAt && data.expiresAt.toMillis() > now;
  }).length;
}

