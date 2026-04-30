import { ErrorCodeValue } from "./error-codes";

export class HttpError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: ErrorCodeValue,
  ) {
    super(code);
  }
}
