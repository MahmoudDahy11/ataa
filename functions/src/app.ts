import express, { NextFunction, Request, Response } from "express";

import { ErrorCode } from "./errors/error-codes";
import { HttpError } from "./errors/http-error";
import { uploadRouter } from "./routes/upload-routes";

export function createApp() {
  const app = express();
  app.use(express.json());
  app.get("/health", (_request, response) => response.json({ ok: true }));
  app.use("/upload", uploadRouter);
  app.use((error: unknown, _request: Request, response: Response, _next: NextFunction) => {
    if (error instanceof HttpError) {
      return response.status(error.status).json({ error: error.code });
    }
    console.error(error);
    return response.status(500).json({ error: ErrorCode.internalServerError });
  });
  return app;
}
