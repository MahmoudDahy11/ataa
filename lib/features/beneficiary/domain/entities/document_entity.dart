class DocumentEntity {
  final String id;
  final String ownerId;
  final String type;
  final String displayName;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String storageKey;
  final String status;
  final String? uploadId;
  final bool isDeleted;
  final int schemaVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DocumentEntity({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.displayName,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.storageKey,
    required this.status,
    required this.uploadId,
    required this.isDeleted,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
  });
}
