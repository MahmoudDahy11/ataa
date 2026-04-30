import { PutObjectCommand, HeadObjectCommand, DeleteObjectCommand, S3Client } from "@aws-sdk/client-s3";
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
  requestChecksumCalculation: "WHEN_REQUIRED",
  responseChecksumValidation: "WHEN_REQUIRED",
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

export async function headObject(fileKey: string): Promise<{ exists: boolean; contentLength: number }> {
  const command = new HeadObjectCommand({
    Bucket: env.bucket,
    Key: fileKey,
  });
  try {
    const response = await client.send(command);
    return { exists: true, contentLength: response.ContentLength ?? 0 };
  } catch (err: any) {
    if (err.name === 'NotFound' || err.$metadata?.httpStatusCode === 404) {
      return { exists: false, contentLength: 0 };
    }
    throw err;
  }
}

export async function deleteObject(fileKey: string): Promise<void> {
  const command = new DeleteObjectCommand({
    Bucket: env.bucket,
    Key: fileKey,
  });
  await client.send(command);
}
