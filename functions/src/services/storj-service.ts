import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

import { env } from "../config/env";

const client = new S3Client({
  region: "us-east-1",
  endpoint: env.endpoint,
  forcePathStyle: true,
  credentials: {
    accessKeyId: env.accessKey,
    secretAccessKey: env.secretKey,
  },
});

export function createUploadUrl(
  fileKey: string,
  mimeType: string,
): Promise<string> {
  return getSignedUrl(
    client,
    new PutObjectCommand({
      Bucket: env.bucket,
      Key: fileKey,
      ContentType: mimeType,
    }),
    { expiresIn: 300 },
  );
}
