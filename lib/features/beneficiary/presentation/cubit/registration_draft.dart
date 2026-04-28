import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';

class RegistrationDraft {
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
  final String payoutAccount;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final List<String> documentIds;
  final List<DocumentEntity> documents;

  const RegistrationDraft({
    this.fullName = '',
    this.phone = '',
    this.nationalId = '',
    this.dateOfBirth,
    this.address = '',
    this.city = '',
    this.governorate = '',
    this.familySize = 1,
    this.incomeStatus = IncomeStatusOption.none,
    this.healthCondition = HealthConditionOption.healthy,
    this.healthDetails = '',
    this.debtInfo = '',
    this.monthlyExpenses,
    this.hasLoans = false,
    this.payoutMethod = PayoutMethodOption.vodafoneCash,
    this.payoutAccount = '',
    this.bankName = '',
    this.accountNumber = '',
    this.accountHolderName = '',
    this.documentIds = const [],
    this.documents = const [],
  });

  RegistrationDraft copyWith({
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
    List<DocumentEntity>? documents,
  }) {
    return RegistrationDraft(
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
      documents: documents ?? this.documents,
    );
  }

  BeneficiaryEntity toEntity({required String id}) {
    return BeneficiaryEntity(
      id: id,
      fullName: fullName,
      phone: phone,
      nationalId: nationalId,
      dateOfBirth: dateOfBirth,
      address: address,
      city: city,
      governorate: governorate,
      familySize: familySize,
      incomeStatus: incomeStatus,
      healthCondition: healthCondition,
      healthDetails: healthDetails,
      debtInfo: debtInfo,
      monthlyExpenses: monthlyExpenses,
      hasLoans: hasLoans,
      payoutMethod: payoutMethod,
      payoutAccount: payoutAccount.isEmpty ? null : payoutAccount,
      bankName: bankName.isEmpty ? null : bankName,
      accountNumber: accountNumber.isEmpty ? null : accountNumber,
      accountHolderName: accountHolderName.isEmpty ? null : accountHolderName,
      documentIds: documentIds,
      status: BeneficiaryStatus.pendingReview,
      isDeleted: false,
      schemaVersion: AppStrings.schemaVersion,
      documents: documents,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
