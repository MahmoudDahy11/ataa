import { NextFunction, Request, Response } from "express";
import { getAuth } from "firebase-admin/auth";

import { ErrorCode } from "../errors/error-codes";
import { HttpError } from "../errors/http-error";

export type AuthedRequest = Request & { userId: string };

export async function requireAuth(
  request: Request,
  _response: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const header = request.header("authorization") ?? "";
    const token = header.replace(/^Bearer\s+/i, "");
    if (!token) throw new HttpError(401, ErrorCode.unauthorized);
    const decoded = await getAuth().verifyIdToken(token);
    (request as AuthedRequest).userId = decoded.uid;
    next();
  } catch (err) {
    console.error("Auth Error:", err);
    next(new HttpError(401, ErrorCode.unauthorized));
  }
}
