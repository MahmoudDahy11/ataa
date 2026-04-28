import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/case_draft.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';

class BeneficiaryState {
  final bool isLoading;
  final bool isSubmittingRegistration;
  final bool isSavingCase;
  final bool isUploading;
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
  final double uploadProgress;
  final String? activeUploadId;
  final String? activeUploadType;
  final int totalCases;
  final int activeCases;
  final int completedCases;

  const BeneficiaryState({
    this.isLoading = false,
    this.isSubmittingRegistration = false,
    this.isSavingCase = false,
    this.isUploading = false,
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
    this.uploadProgress = 0,
    this.activeUploadId,
    this.activeUploadType,
    this.totalCases = 0,
    this.activeCases = 0,
    this.completedCases = 0,
  });

  BeneficiaryState copyWith({
    bool? isLoading,
    bool? isSubmittingRegistration,
    bool? isSavingCase,
    bool? isUploading,
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
    double? uploadProgress,
    String? activeUploadId,
    String? activeUploadType,
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
      isUploading: isUploading ?? this.isUploading,
      currentStep: currentStep ?? this.currentStep,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
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
      uploadProgress: uploadProgress ?? this.uploadProgress,
      activeUploadId: activeUploadId ?? this.activeUploadId,
      activeUploadType: activeUploadType ?? this.activeUploadType,
      totalCases: totalCases ?? this.totalCases,
      activeCases: activeCases ?? this.activeCases,
      completedCases: completedCases ?? this.completedCases,
    );
  }
}
