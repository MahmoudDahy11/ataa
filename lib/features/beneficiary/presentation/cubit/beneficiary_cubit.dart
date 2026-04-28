import 'dart:typed_data';

import 'package:ataa/core/env/app_env.dart';
import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/upload_entities.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/case_draft.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficiaryCubit extends Cubit<BeneficiaryState> {
  final BeneficiaryRepo _repo;
  final AuthRepo _authRepo;

  BeneficiaryCubit({required BeneficiaryRepo repo, required AuthRepo authRepo})
    : _repo = repo,
      _authRepo = authRepo,
      super(
        BeneficiaryState(
          registrationDraft: RegistrationDraft(
            phone: authRepo.currentUserPhone ?? '',
          ),
        ),
      );

  String get currentUserId => _authRepo.currentUserId ?? '';

  void saveRegistrationStep(RegistrationDraft draft) {
    emit(state.copyWith(registrationDraft: draft, clearError: true));
  }

  void goToStep(int step) {
    emit(state.copyWith(currentStep: step, clearError: true));
  }

  Future<void> continueRegistration() async {
    final error = _validateStep(state.currentStep);
    if (error != null) {
      emit(state.copyWith(errorMessage: error, clearSuccess: true));
      return;
    }
    if (state.currentStep == 6) {
      await submitRegistration();
      return;
    }
    emit(state.copyWith(currentStep: state.currentStep + 1, clearError: true));
  }

  Future<void> submitRegistration() async {
    final error = _validateAllRegistration();
    if (error != null) {
      emit(state.copyWith(errorMessage: error, clearSuccess: true));
      return;
    }
    emit(state.copyWith(isSubmittingRegistration: true, clearError: true));
    final result = await _repo.registerBeneficiary(
      beneficiary: state.registrationDraft.toEntity(id: currentUserId),
    );
    result.fold(_emitFailure, (profile) {
      emit(
        state.copyWith(
          isSubmittingRegistration: false,
          profile: profile,
          uploadedDocuments: profile.documents,
          uploadedDocumentsByType: _documentsByType(profile.documents),
          successMessage: 'Registration submitted for review.',
          clearError: true,
        ),
      );
    });
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await _repo.getProfile();
    result.fold(_emitFailure, (profile) {
      emit(
        state.copyWith(
          isLoading: false,
          profile: profile,
          uploadedDocuments: profile.documents,
          uploadedDocumentsByType: _documentsByType(profile.documents),
          registrationDraft: state.registrationDraft.copyWith(
            phone: profile.phone,
            fullName: profile.fullName,
            nationalId: profile.nationalId,
            dateOfBirth: profile.dateOfBirth,
            address: profile.address,
            city: profile.city,
            governorate: profile.governorate,
            familySize: profile.familySize,
            incomeStatus: profile.incomeStatus,
            healthCondition: profile.healthCondition,
            healthDetails: profile.healthDetails,
            debtInfo: profile.debtInfo,
            monthlyExpenses: profile.monthlyExpenses,
            hasLoans: profile.hasLoans,
            payoutMethod: profile.payoutMethod,
            payoutAccount: profile.payoutAccount ?? '',
            bankName: profile.bankName ?? '',
            accountNumber: profile.accountNumber ?? '',
            accountHolderName: profile.accountHolderName ?? '',
            documentIds: profile.documentIds,
            documents: profile.documents,
          ),
        ),
      );
    });
  }

  Future<void> updateProfile() async {
    final profile = state.profile;
    if (profile == null) {
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await _repo.updateProfile(beneficiary: profile);
    result.fold(_emitFailure, (updated) {
      emit(
        state.copyWith(
          isLoading: false,
          profile: updated,
          uploadedDocumentsByType: _documentsByType(updated.documents),
          successMessage: 'Profile updated successfully.',
        ),
      );
    });
  }

  Future<void> loadDashboard({Object? startAfter}) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await _repo.getOwnedCasesPage(limit: 10);
    result.fold(_emitFailure, (cases) {
      final nextCases = startAfter == null
          ? cases
          : [...state.ownedCases, ...cases];
      emit(
        state.copyWith(
          isLoading: false,
          ownedCases: nextCases,
          hasMoreCases: cases.length == 10,
          lastCaseCursor: cases.isEmpty ? state.lastCaseCursor : cases.last.id,
          totalCases: nextCases.length,
          activeCases: _activeCasesCount(nextCases),
          completedCases: _completedCasesCount(nextCases),
        ),
      );
    });
  }

  void saveDraftCase(CaseDraft draft) {
    emit(state.copyWith(caseDraft: draft, clearError: true));
  }

  Future<void> persistCaseDraft() async {
    emit(
      state.copyWith(isSavingCase: true, clearError: true, clearSuccess: true),
    );
    final result = await _repo.saveDraftCase(
      draft: state.caseDraft.toEntity(beneficiaryId: currentUserId),
    );
    result.fold(_emitFailure, (saved) {
      emit(
        state.copyWith(
          isSavingCase: false,
          caseDraft: state.caseDraft.copyWith(id: saved.id),
          selectedCase: saved,
          successMessage: 'Draft saved successfully.',
        ),
      );
    });
  }

  Future<void> submitCase() async {
    if (state.caseDraft.id.isEmpty) {
      await persistCaseDraft();
    }
    final caseId = state.caseDraft.id;
    if (caseId.isEmpty) {
      return;
    }
    emit(
      state.copyWith(isSavingCase: true, clearError: true, clearSuccess: true),
    );
    final result = await _repo.submitCaseForReview(caseId: caseId);
    result.fold(_emitFailure, (saved) {
      emit(
        state.copyWith(
          isSavingCase: false,
          selectedCase: saved,
          successMessage: 'Case submitted for review.',
        ),
      );
    });
  }

  Future<void> loadCaseDetails(String id) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repo.getCaseById(id);
    result.fold(_emitFailure, (caseDetails) {
      emit(state.copyWith(isLoading: false, selectedCase: caseDetails));
    });
  }

  Future<void> startUpload({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
    required String scope,
    String? documentType,
  }) async {
    if (!_isAllowedMimeType(mimeType)) {
      emit(
        state.copyWith(
          errorMessage: 'Only JPG, PNG, or PDF files are allowed.',
        ),
      );
      return;
    }
    if (bytes.length > AppEnv.uploadMaxBytes) {
      emit(
        state.copyWith(errorMessage: 'Selected file exceeds the upload limit.'),
      );
      return;
    }
    emit(
      state.copyWith(isUploading: true, uploadProgress: 0, clearError: true),
    );
    final effectiveType = documentType ?? scope;
    final initResult = await _repo.initUpload(
      request: UploadRequest(
        fileName: fileName,
        mimeType: mimeType,
        sizeBytes: bytes.length,
        scope: scope,
      ),
    );
    await initResult.fold((failure) async => _emitFailure(failure), (
      session,
    ) async {
      emit(
        state.copyWith(
          activeUploadId: session.uploadId,
          activeUploadType: effectiveType,
        ),
      );
      final result = await _repo.retryUpload(
        uploadId: session.uploadId,
        ownerId: currentUserId,
        type: effectiveType,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: (progress) {
          emit(state.copyWith(isUploading: true, uploadProgress: progress));
        },
      );
      result.fold(_emitFailure, (document) {
        final nextByType = {
          ...state.uploadedDocumentsByType,
          document.type: document,
        };
        final nextDocuments = nextByType.values.toList();
        emit(
          state.copyWith(
            isUploading: false,
            uploadProgress: 1,
            uploadedDocuments: nextDocuments,
            uploadedDocumentsByType: nextByType,
            registrationDraft: state.registrationDraft.copyWith(
              documents: nextDocuments,
              documentIds: nextDocuments.map((item) => item.id).toList(),
            ),
            successMessage: 'Upload completed successfully.',
          ),
        );
      });
    });
  }

  Future<void> retryUpload({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final uploadId = state.activeUploadId;
    final uploadType = state.activeUploadType;
    if (uploadId == null || uploadType == null) {
      emit(
        state.copyWith(
          errorMessage: 'No upload session is available to retry.',
        ),
      );
      return;
    }
    emit(state.copyWith(isUploading: true, clearError: true));
    final result = await _repo.retryUpload(
      uploadId: uploadId,
      ownerId: currentUserId,
      type: uploadType,
      bytes: bytes,
      mimeType: mimeType,
      onProgress: (progress) => emit(state.copyWith(uploadProgress: progress)),
    );
    result.fold(_emitFailure, (document) {
      final nextByType = {
        ...state.uploadedDocumentsByType,
        document.type: document,
      };
      emit(
        state.copyWith(
          isUploading: false,
          uploadedDocuments: nextByType.values.toList(),
          uploadedDocumentsByType: nextByType,
          successMessage: 'Upload retry succeeded.',
        ),
      );
    });
  }

  bool canCreateCase() {
    return state.profile?.status == BeneficiaryStatus.approved;
  }

  bool isDocumentUploaded(String type) {
    return state.uploadedDocumentsByType.containsKey(type);
  }

  bool _isAllowedMimeType(String mimeType) {
    return AllowedUploadTypes.all.contains(mimeType);
  }

  String? _validateAllRegistration() {
    for (var step = 0; step < 7; step++) {
      final error = _validateStep(step);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  String? _validateStep(int step) {
    final draft = state.registrationDraft;
    switch (step) {
      case 0:
        if (draft.fullName.trim().isEmpty) {
          return 'Full name is required.';
        }
        if (!RegExp(r'^\d{14}$').hasMatch(draft.nationalId)) {
          return 'National ID must be exactly 14 digits.';
        }
        if (draft.dateOfBirth == null) {
          return 'Date of birth is required.';
        }
        if (draft.phone.trim().isEmpty) {
          return 'Verified phone number is required.';
        }
        return null;
      case 1:
        if (draft.address.trim().isEmpty) {
          return 'Address is required.';
        }
        if (draft.governorate.isEmpty || draft.city.isEmpty) {
          return 'Governorate and city are required.';
        }
        return null;
      case 2:
        if (draft.familySize < 1 || draft.familySize > 20) {
          return 'Family size must be between 1 and 20.';
        }
        if (!IncomeStatusOption.all.contains(draft.incomeStatus)) {
          return 'Please select an income status.';
        }
        return null;
      case 3:
        if (!HealthConditionOption.all.contains(draft.healthCondition)) {
          return 'Please select a health condition.';
        }
        return null;
      case 4:
        if (draft.debtInfo.trim().isEmpty) {
          return 'Debt information is required.';
        }
        return null;
      case 5:
        if (draft.payoutMethod == PayoutMethodOption.vodafoneCash) {
          if (draft.payoutAccount.trim().isEmpty) {
            return 'Vodafone Cash number is required.';
          }
        } else if (draft.payoutMethod == PayoutMethodOption.bank) {
          if (draft.bankName.trim().isEmpty ||
              draft.accountNumber.trim().isEmpty ||
              draft.accountHolderName.trim().isEmpty) {
            return 'All bank account fields are required.';
          }
        }
        return null;
      case 6:
        for (final type in RequiredDocumentType.all) {
          if (!isDocumentUploaded(type)) {
            return 'Please upload ${RequiredDocumentType.labels[type]}.';
          }
        }
        return null;
      default:
        return null;
    }
  }

  Map<String, DocumentEntity> _documentsByType(List<DocumentEntity> documents) {
    return {for (final document in documents) document.type: document};
  }

  int _activeCasesCount(List<CaseEntity> cases) {
    return cases
        .where(
          (item) =>
              item.status == CaseLifecycle.draft ||
              item.status == CaseLifecycle.pendingReview ||
              item.status == CaseLifecycle.collecting,
        )
        .length;
  }

  int _completedCasesCount(List<CaseEntity> cases) {
    return cases
        .where(
          (item) =>
              item.status == CaseLifecycle.completed ||
              item.status == CaseLifecycle.paid,
        )
        .length;
  }

  void _emitFailure(CustomFailure failure) {
    emit(
      state.copyWith(
        isLoading: false,
        isSubmittingRegistration: false,
        isSavingCase: false,
        isUploading: false,
        errorMessage: failure.errMessage,
        clearSuccess: true,
      ),
    );
  }
}
