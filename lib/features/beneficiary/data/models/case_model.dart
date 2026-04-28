import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/features/beneficiary/data/models/model_utils.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';

class CaseModel extends CaseEntity {
  const CaseModel({
    required super.id,
    required super.beneficiaryId,
    required super.title,
    required super.category,
    required super.targetAmount,
    required super.collectedAmount,
    required super.description,
    required super.mediaKeys,
    required super.status,
    required super.isDeleted,
    required super.schemaVersion,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return CaseModel(
      id: id.isEmpty ? (json['id'] as String? ?? '') : id,
      beneficiaryId: json['beneficiaryId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num? ?? 0).toDouble(),
      collectedAmount: (json['collectedAmount'] as num? ?? 0).toDouble(),
      description: json['description'] as String? ?? '',
      mediaKeys: (json['mediaKeys'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      status: json['status'] as String? ?? CaseLifecycle.draft,
      isDeleted: json['isDeleted'] as bool? ?? false,
      schemaVersion: (json['schemaVersion'] as num? ?? AppStrings.schemaVersion)
          .toInt(),
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beneficiaryId': beneficiaryId,
      'title': title,
      'category': category,
      'targetAmount': targetAmount,
      'collectedAmount': collectedAmount,
      'description': description,
      'mediaKeys': mediaKeys,
      'status': status,
      'isDeleted': isDeleted,
      'schemaVersion': schemaVersion,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
