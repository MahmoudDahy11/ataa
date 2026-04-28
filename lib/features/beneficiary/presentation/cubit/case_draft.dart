import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';

class CaseDraft {
  final String id;
  final String title;
  final String category;
  final String description;
  final double targetAmount;
  final List<String> mediaKeys;

  const CaseDraft({
    this.id = '',
    this.title = '',
    this.category = '',
    this.description = '',
    this.targetAmount = 0,
    this.mediaKeys = const [],
  });

  CaseDraft copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    double? targetAmount,
    List<String>? mediaKeys,
  }) {
    return CaseDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      mediaKeys: mediaKeys ?? this.mediaKeys,
    );
  }

  CaseEntity toEntity({required String beneficiaryId}) {
    return CaseEntity(
      id: id,
      beneficiaryId: beneficiaryId,
      title: title,
      category: category,
      targetAmount: targetAmount,
      collectedAmount: 0,
      description: description,
      mediaKeys: mediaKeys,
      status: CaseLifecycle.draft,
      isDeleted: false,
      schemaVersion: AppStrings.schemaVersion,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
