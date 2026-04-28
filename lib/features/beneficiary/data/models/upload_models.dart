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
    return UploadSessionModel(
      uploadId: json['uploadId'] as String? ?? '',
      signedUrl: json['signedUrl'] as String? ?? '',
      storageKey: json['storageKey'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
      headers: headers,
    );
  }
}
