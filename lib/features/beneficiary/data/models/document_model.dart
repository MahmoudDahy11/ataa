import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/features/beneficiary/data/models/model_utils.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.ownerId,
    required super.type,
    required super.displayName,
    required super.fileName,
    required super.mimeType,
    required super.sizeBytes,
    required super.storageKey,
    required super.status,
    required super.uploadId,
    required super.isDeleted,
    required super.schemaVersion,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return DocumentModel(
      id: id.isEmpty ? (json['id'] as String? ?? '') : id,
      ownerId: json['ownerId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      mimeType: json['mimeType'] as String? ?? '',
      sizeBytes: (json['sizeBytes'] as num? ?? 0).toInt(),
      storageKey: json['storageKey'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      uploadId: json['uploadId'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      schemaVersion: (json['schemaVersion'] as num? ?? AppStrings.schemaVersion)
          .toInt(),
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'type': type,
      'displayName': displayName,
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'storageKey': storageKey,
      'status': status,
      'uploadId': uploadId,
      'isDeleted': isDeleted,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
