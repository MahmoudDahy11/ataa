import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';

class BeneficiaryEntity {
  final String id;
  final String fullName;
  final String phone;
  final String nationalId;
  final DateTime? dateOfBirth;
  final String address;
  final String city;
  final String governorate;
  final int familySize;
  final String incomeStatus;
  final String healthCondition;
  final String healthDetails;
  final String debtInfo;
  final double? monthlyExpenses;
  final bool hasLoans;
  final String payoutMethod;
  final String? payoutAccount;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final List<String> documentIds;
  final String status;
  final bool isDeleted;
  final int schemaVersion;
  final List<DocumentEntity> documents;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BeneficiaryEntity({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.nationalId,
    required this.dateOfBirth,
    required this.address,
    required this.city,
    required this.governorate,
    required this.familySize,
    required this.incomeStatus,
    required this.healthCondition,
    required this.healthDetails,
    required this.debtInfo,
    required this.monthlyExpenses,
    required this.hasLoans,
    required this.payoutMethod,
    required this.payoutAccount,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.documentIds,
    required this.status,
    required this.isDeleted,
    required this.schemaVersion,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
  });
}
