import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/features/beneficiary/data/models/document_model.dart';
import 'package:ataa/features/beneficiary/data/models/model_utils.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';

class BeneficiaryModel extends BeneficiaryEntity {
  const BeneficiaryModel({
    required super.id,
    required super.fullName,
    required super.phone,
    required super.nationalId,
    required super.dateOfBirth,
    required super.address,
    required super.city,
    required super.governorate,
    required super.familySize,
    required super.incomeStatus,
    required super.healthCondition,
    required super.healthDetails,
    required super.debtInfo,
    required super.monthlyExpenses,
    required super.hasLoans,
    required super.payoutMethod,
    required super.payoutAccount,
    required super.bankName,
    required super.accountNumber,
    required super.accountHolderName,
    required super.documentIds,
    required super.status,
    required super.isDeleted,
    required super.schemaVersion,
    required super.documents,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BeneficiaryModel.fromEntity(BeneficiaryEntity entity) {
    return BeneficiaryModel(
      id: entity.id,
      fullName: entity.fullName,
      phone: entity.phone,
      nationalId: entity.nationalId,
      dateOfBirth: entity.dateOfBirth,
      address: entity.address,
      city: entity.city,
      governorate: entity.governorate,
      familySize: entity.familySize,
      incomeStatus: entity.incomeStatus,
      healthCondition: entity.healthCondition,
      healthDetails: entity.healthDetails,
      debtInfo: entity.debtInfo,
      monthlyExpenses: entity.monthlyExpenses,
      hasLoans: entity.hasLoans,
      payoutMethod: entity.payoutMethod,
      payoutAccount: entity.payoutAccount,
      bankName: entity.bankName,
      accountNumber: entity.accountNumber,
      accountHolderName: entity.accountHolderName,
      documentIds: entity.documentIds,
      status: entity.status,
      isDeleted: entity.isDeleted,
      schemaVersion: entity.schemaVersion,
      documents: entity.documents,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory BeneficiaryModel.fromJson(
    Map<String, dynamic> json, {
    String id = '',
  }) {
    return BeneficiaryModel(
      id: id.isEmpty ? (json['id'] as String? ?? '') : id,
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      nationalId: json['nationalId'] as String? ?? '',
      dateOfBirth: parseTimestamp(json['dateOfBirth']),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      governorate: json['governorate'] as String? ?? '',
      familySize: (json['familySize'] as num? ?? 1).toInt(),
      incomeStatus: json['incomeStatus'] as String? ?? IncomeStatusOption.none,
      healthCondition:
          json['healthCondition'] as String? ?? HealthConditionOption.healthy,
      healthDetails: json['healthDetails'] as String? ?? '',
      debtInfo: json['debtInfo'] as String? ?? '',
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble(),
      hasLoans: json['hasLoans'] as bool? ?? false,
      payoutMethod: json['payoutMethod'] as String? ?? '',
      payoutAccount: json['payoutAccount'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      documentIds: (json['documentIds'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      status: json['status'] as String? ?? BeneficiaryStatus.pendingReview,
      isDeleted: json['isDeleted'] as bool? ?? false,
      schemaVersion: (json['schemaVersion'] as num? ?? AppStrings.schemaVersion)
          .toInt(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(DocumentModel.fromJson)
          .toList(),
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'nationalId': nationalId,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'city': city,
      'governorate': governorate,
      'familySize': familySize,
      'incomeStatus': incomeStatus,
      'healthCondition': healthCondition,
      'healthDetails': healthDetails,
      'debtInfo': debtInfo,
      'monthlyExpenses': monthlyExpenses,
      'hasLoans': hasLoans,
      'payoutMethod': payoutMethod,
      'payoutAccount': payoutAccount,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'documentIds': documentIds,
      'status': status,
      'isDeleted': isDeleted,
      'schemaVersion': schemaVersion,
      'documents': documents.map((document) {
        return document is DocumentModel
            ? document.toJson()
            : DocumentModel(
                id: document.id,
                ownerId: document.ownerId,
                type: document.type,
                displayName: document.displayName,
                fileName: document.fileName,
                mimeType: document.mimeType,
                sizeBytes: document.sizeBytes,
                storageKey: document.storageKey,
                status: document.status,
                uploadId: document.uploadId,
                isDeleted: document.isDeleted,
                schemaVersion: document.schemaVersion,
                createdAt: document.createdAt,
                updatedAt: document.updatedAt,
              ).toJson();
      }).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
