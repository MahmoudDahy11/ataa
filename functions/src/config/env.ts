import * as dotenv from 'dotenv';
dotenv.config();

export const env = {
  bucket: process.env.STORJ_BUCKET ?? "",
  endpoint: process.env.STORJ_ENDPOINT ?? "https://gateway.storjshare.io",
  accessKey: process.env.STORJ_ACCESS_KEY ?? "",
  secretKey: process.env.STORJ_SECRET_KEY ?? "",
  maxFileSize: Number(process.env.MAX_FILE_SIZE ?? 5242880),
  port: Number(process.env.PORT ?? 3000),
  uploadSessionLimitPerUser: Number(process.env.UPLOAD_SESSION_LIMIT_PER_USER ?? 10),
};

export const allowedMimeTypes = new Set([
  "image/jpeg",
  "image/png",
  "application/pdf",
]);

export function assertUploadEnv(): void {
  if (!env.bucket || !env.accessKey || !env.secretKey) {
    throw new Error("Storj environment variables are missing (STORJ_BUCKET, STORJ_ACCESS_KEY, STORJ_SECRET_KEY)");
  }
  if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_CLIENT_EMAIL || !process.env.FIREBASE_PRIVATE_KEY) {
    throw new Error("Firebase environment variables are missing (FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY)");
  }
}

