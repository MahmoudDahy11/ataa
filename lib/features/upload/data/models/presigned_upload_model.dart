import 'package:ataa/features/upload/domain/entities/presigned_upload.dart';

class PresignedUploadModel extends PresignedUpload {
  const PresignedUploadModel({required super.url, required super.fileKey});

  factory PresignedUploadModel.fromJson(Map<String, dynamic> json) {
    return PresignedUploadModel(
      url: json['url'] as String? ?? '',
      fileKey: json['fileKey'] as String? ?? '',
    );
  }
}
