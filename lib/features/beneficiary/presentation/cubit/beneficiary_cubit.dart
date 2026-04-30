import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/case_draft.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'beneficiary_cubit_validation.dart';

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

  bool canContinueRegistration() => _validateStep(state.currentStep) == null;

  void saveDraftCase(CaseDraft draft) {
    emit(state.copyWith(caseDraft: draft, clearError: true));
  }

  void saveUploadedDocument(DocumentEntity document) {
    final nextByType = {
      ...state.uploadedDocumentsByType,
      document.type: document,
    };
    final nextDocuments = nextByType.values.toList();
    emit(
      state.copyWith(
        uploadedDocuments: nextDocuments,
        uploadedDocumentsByType: nextByType,
        registrationDraft: state.registrationDraft.copyWith(
          documents: nextDocuments,
          documentIds: nextDocuments.map((item) => item.id).toList(),
        ),
        clearError: true,
      ),
    );
  }

  bool canCreateCase() => state.profile?.status == BeneficiaryStatus.approved;
  bool isDocumentUploaded(String type) =>
      state.uploadedDocumentsByType.containsKey(type);

  Future<void> continueRegistration() async {
    final error = _validateStep(state.currentStep);
    if (error != null) {
      emit(state.copyWith(errorMessage: error, clearSuccess: true));
      return;
    }
    if (state.currentStep == 4) {
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
          successMessage: 'تم إرسال الطلب للمراجعة بنجاح',
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
    if (state.caseDraft.id.isEmpty) {
      return;
    }
    emit(
      state.copyWith(isSavingCase: true, clearError: true, clearSuccess: true),
    );
    final result = await _repo.submitCaseForReview(caseId: state.caseDraft.id);
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

  void _emitFailure(CustomFailure failure) {
    emit(
      state.copyWith(
        isLoading: false,
        isSubmittingRegistration: false,
        isSavingCase: false,
        errorMessage: failure.errMessage,
        clearSuccess: true,
      ),
    );
  }
}
