import { randomUUID } from "crypto";

import { allowedMimeTypes, env } from "../config/env";
import { ErrorCode } from "../errors/error-codes";
import { HttpError } from "../errors/http-error";

const extensionByMimeType: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "application/pdf": "pdf",
};

export function validateFile(mimeType: string, sizeBytes: number): void {
  if (!allowedMimeTypes.has(mimeType)) {
    throw new HttpError(400, ErrorCode.invalidFileType);
  }
  if (sizeBytes > env.maxFileSize) {
    throw new HttpError(400, ErrorCode.fileTooLarge);
  }
}

export function buildFileKey(userId: string, fileName: string, mimeType: string): string {
  const extension = extensionByMimeType[mimeType] ?? fileName.split(".").pop() ?? "bin";
  return `users/${userId}/documents/${Date.now()}_${randomUUID()}.${extension}`;
}

export function sessionId(fileKey: string): string {
  return encodeURIComponent(fileKey);
}
