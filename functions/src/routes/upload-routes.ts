import { Router } from "express";

import { requireAuth, type AuthedRequest } from "../middleware/auth";
import { createDocument } from "../services/document-service";
import { createUploadUrl } from "../services/storj-service";
import {
  createUploadSession,
  markUploadSessionUsed,
  validateUploadSession,
} from "../services/upload-session-service";
import { buildFileKey, validateFile } from "../utils/file-utils";

export const uploadRouter = Router();

uploadRouter.post("/init", requireAuth, async (request, response) => {
  const { fileName = "", mimeType = "", sizeBytes = 0 } = request.body ?? {};
  validateFile(String(mimeType), Number(sizeBytes));
  const fileKey = buildFileKey((request as AuthedRequest).userId, String(fileName), String(mimeType));
  await createUploadSession(fileKey, (request as AuthedRequest).userId);
  const url = await createUploadUrl(fileKey, String(mimeType));
  response.json({ url, fileKey });
});

uploadRouter.post("/confirm", requireAuth, async (request, response) => {
  const { fileKey = "", type = "", fileName = "", mimeType = "", sizeBytes = 0 } = request.body ?? {};
  validateFile(String(mimeType), Number(sizeBytes));
  await validateUploadSession(String(fileKey), (request as AuthedRequest).userId);
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
});
