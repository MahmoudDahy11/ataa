import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/case_draft.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';

class BeneficiaryState {
  final bool isLoading;
  final bool isSubmittingRegistration;
  final bool isSavingCase;
  final int currentStep;
  final String? errorMessage;
  final String? successMessage;
  final RegistrationDraft registrationDraft;
  final CaseDraft caseDraft;
  final BeneficiaryEntity? profile;
  final CaseEntity? selectedCase;
  final List<CaseEntity> ownedCases;
  final List<DocumentEntity> uploadedDocuments;
  final Map<String, DocumentEntity> uploadedDocumentsByType;
  final bool hasMoreCases;
  final Object? lastCaseCursor;
  final int totalCases;
  final int activeCases;
  final int completedCases;

  const BeneficiaryState({
    this.isLoading = false,
    this.isSubmittingRegistration = false,
    this.isSavingCase = false,
    this.currentStep = 0,
    this.errorMessage,
    this.successMessage,
    this.registrationDraft = const RegistrationDraft(),
    this.caseDraft = const CaseDraft(),
    this.profile,
    this.selectedCase,
    this.ownedCases = const [],
    this.uploadedDocuments = const [],
    this.uploadedDocumentsByType = const {},
    this.hasMoreCases = true,
    this.lastCaseCursor,
    this.totalCases = 0,
    this.activeCases = 0,
    this.completedCases = 0,
  });

  BeneficiaryState copyWith({
    bool? isLoading,
    bool? isSubmittingRegistration,
    bool? isSavingCase,
    int? currentStep,
    String? errorMessage,
    String? successMessage,
    RegistrationDraft? registrationDraft,
    CaseDraft? caseDraft,
    BeneficiaryEntity? profile,
    CaseEntity? selectedCase,
    List<CaseEntity>? ownedCases,
    List<DocumentEntity>? uploadedDocuments,
    Map<String, DocumentEntity>? uploadedDocumentsByType,
    bool? hasMoreCases,
    Object? lastCaseCursor,
    int? totalCases,
    int? activeCases,
    int? completedCases,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BeneficiaryState(
      isLoading: isLoading ?? this.isLoading,
      isSubmittingRegistration:
          isSubmittingRegistration ?? this.isSubmittingRegistration,
      isSavingCase: isSavingCase ?? this.isSavingCase,
      currentStep: currentStep ?? this.currentStep,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
      registrationDraft: registrationDraft ?? this.registrationDraft,
      caseDraft: caseDraft ?? this.caseDraft,
      profile: profile ?? this.profile,
      selectedCase: selectedCase ?? this.selectedCase,
      ownedCases: ownedCases ?? this.ownedCases,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      uploadedDocumentsByType:
          uploadedDocumentsByType ?? this.uploadedDocumentsByType,
      hasMoreCases: hasMoreCases ?? this.hasMoreCases,
      lastCaseCursor: lastCaseCursor ?? this.lastCaseCursor,
      totalCases: totalCases ?? this.totalCases,
      activeCases: activeCases ?? this.activeCases,
      completedCases: completedCases ?? this.completedCases,
    );
  }
}
