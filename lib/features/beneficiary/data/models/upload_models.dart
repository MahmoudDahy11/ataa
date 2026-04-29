import 'package:ataa/features/beneficiary/domain/entities/upload_entities.dart';

class UploadSessionModel extends UploadSession {
  const UploadSessionModel({
    required super.uploadId,
    required super.signedUrl,
    required super.storageKey,
    required super.expiresAt,
    required super.headers,
  });

  factory UploadSessionModel.fromJson(Map<String, dynamic> json) {
    final headers = (json['headers'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final signedUrl =
        json['signedUrl'] as String? ?? json['uploadUrl'] as String? ?? '';
    final storageKey =
        json['storageKey'] as String? ?? json['filePath'] as String? ?? '';
    return UploadSessionModel(
      uploadId: json['uploadId'] as String? ?? '',
      signedUrl: signedUrl,
      storageKey: storageKey,
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
      headers: headers,
    );
  }
}
