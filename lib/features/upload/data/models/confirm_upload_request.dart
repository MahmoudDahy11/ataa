class ConfirmUploadRequest {
  final String fileKey;
  final String type;
  final String fileName;
  final String mimeType;
  final int sizeBytes;

  const ConfirmUploadRequest({
    required this.fileKey,
    required this.type,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileKey': fileKey,
      'type': type,
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
    };
  }
}
