import dotenv from "dotenv";
import { initializeApp, getApps, cert } from "firebase-admin/app";

import { createApp } from "./app";
import { assertUploadEnv, env } from "./config/env";

dotenv.config();

if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    }),
  });
}

assertUploadEnv();

createApp().listen(env.port, "0.0.0.0", () => {
  console.log(`Upload server listening on http://0.0.0.0:${env.port}`);
});