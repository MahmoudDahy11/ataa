class UploadRequest {
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String scope;

  const UploadRequest({
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.scope,
  });
}

class UploadSession {
  final String uploadId;
  final String signedUrl;
  final String storageKey;
  final DateTime? expiresAt;
  final Map<String, String> headers;

  const UploadSession({
    required this.uploadId,
    required this.signedUrl,
    required this.storageKey,
    required this.expiresAt,
    required this.headers,
  });
}
