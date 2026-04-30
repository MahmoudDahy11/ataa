export const ErrorCode = {
  internalServerError: "INTERNAL_SERVER_ERROR",
  invalidFileType: "INVALID_FILE_TYPE",
  fileTooLarge: "FILE_TOO_LARGE",
  unauthorized: "UNAUTHORIZED",
  uploadSessionNotFound: "UPLOAD_SESSION_NOT_FOUND",
  uploadSessionExpired: "UPLOAD_SESSION_EXPIRED",
  uploadAlreadyConfirmed: "UPLOAD_ALREADY_CONFIRMED",
  uploadNotFound: "UPLOAD_NOT_FOUND",
  rateLimited: "RATE_LIMITED",
} as const;

export type ErrorCodeValue = (typeof ErrorCode)[keyof typeof ErrorCode];
