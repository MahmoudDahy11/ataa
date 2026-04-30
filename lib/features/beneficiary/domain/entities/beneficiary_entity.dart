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

  BeneficiaryEntity copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? nationalId,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? governorate,
    int? familySize,
    String? incomeStatus,
    String? healthCondition,
    String? healthDetails,
    String? debtInfo,
    double? monthlyExpenses,
    bool? hasLoans,
    String? payoutMethod,
    String? payoutAccount,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    List<String>? documentIds,
    String? status,
    bool? isDeleted,
    int? schemaVersion,
    List<DocumentEntity>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BeneficiaryEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      familySize: familySize ?? this.familySize,
      incomeStatus: incomeStatus ?? this.incomeStatus,
      healthCondition: healthCondition ?? this.healthCondition,
      healthDetails: healthDetails ?? this.healthDetails,
      debtInfo: debtInfo ?? this.debtInfo,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      hasLoans: hasLoans ?? this.hasLoans,
      payoutMethod: payoutMethod ?? this.payoutMethod,
      payoutAccount: payoutAccount ?? this.payoutAccount,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      documentIds: documentIds ?? this.documentIds,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
