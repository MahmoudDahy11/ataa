import 'dart:typed_data';

import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/upload_entities.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BeneficiaryCubit', () {
    test('loadProfile enables case creation for approved beneficiaries', () async {
      final cubit = BeneficiaryCubit(
        repo: _FakeBeneficiaryRepo(status: BeneficiaryStatus.approved),
        authRepo: _FakeAuthRepo(),
      );

      await cubit.loadProfile();

      expect(cubit.state.profile?.status, BeneficiaryStatus.approved);
      expect(cubit.canCreateCase(), isTrue);
    });

    test('startUpload rejects invalid mime type before backend call', () async {
      final cubit = BeneficiaryCubit(
        repo: _FakeBeneficiaryRepo(status: BeneficiaryStatus.pendingReview),
        authRepo: _FakeAuthRepo(),
      );

      await cubit.startUpload(
        fileName: 'bad.txt',
        mimeType: 'text/plain',
        bytes: Uint8List.fromList([1, 2, 3]),
        scope: 'beneficiary_document',
        documentType: RequiredDocumentType.idCard,
      );

      expect(cubit.state.errorMessage, contains('JPG, PNG, or PDF'));
    });

    test('continueRegistration validates national ID before advancing', () async {
      final cubit = BeneficiaryCubit(
        repo: _FakeBeneficiaryRepo(status: BeneficiaryStatus.pendingReview),
        authRepo: _FakeAuthRepo(),
      );

      cubit.saveRegistrationStep(
        cubit.state.registrationDraft.copyWith(
          fullName: 'User Name',
          nationalId: '123',
          dateOfBirth: DateTime(1995, 1, 1),
        ),
      );

      await cubit.continueRegistration();

      expect(cubit.state.currentStep, 0);
      expect(cubit.state.errorMessage, contains('14 digits'));
    });

    test('submit step requires all predefined documents', () async {
      final cubit = BeneficiaryCubit(
        repo: _FakeBeneficiaryRepo(status: BeneficiaryStatus.pendingReview),
        authRepo: _FakeAuthRepo(),
      );

      cubit.saveRegistrationStep(
        cubit.state.registrationDraft.copyWith(
          fullName: 'User Name',
          nationalId: '12345678901234',
          dateOfBirth: DateTime(1995, 1, 1),
          address: 'Street 1',
          city: 'Nasr City',
          governorate: 'Cairo',
          familySize: 4,
          incomeStatus: IncomeStatusOption.low,
          healthCondition: HealthConditionOption.healthy,
          debtInfo: 'Debt',
          payoutMethod: PayoutMethodOption.vodafoneCash,
          payoutAccount: '01000000000',
        ),
      );
      cubit.goToStep(6);

      await cubit.continueRegistration();

      expect(cubit.state.errorMessage, contains('ID Card'));
    });
  });
}

class _FakeBeneficiaryRepo implements BeneficiaryRepo {
  final String status;

  _FakeBeneficiaryRepo({required this.status});

  @override
  Future<Either<CustomFailure, DocumentEntity>> confirmUpload({
    required String uploadId,
    required String ownerId,
    required String type,
  }) async => Right(_document());

  @override
  Future<Either<CustomFailure, CaseEntity>> getCaseById(String caseId) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<CustomFailure, List<CaseEntity>>> getOwnedCasesPage({
    DocumentSnapshot<Object?>? startAfter,
    int limit = 10,
  }) async => const Right([]);

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> getProfile() async {
    return Right(_profile(status));
  }

  @override
  Future<Either<CustomFailure, UploadSession>> initUpload({
    required UploadRequest request,
  }) async => Left(AuthFailure(errMessage: 'Should not be called'));

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> registerBeneficiary({
    required BeneficiaryEntity beneficiary,
  }) async => Right(beneficiary);

  @override
  Future<Either<CustomFailure, DocumentEntity>> retryUpload({
    required String uploadId,
    required String ownerId,
    required String type,
    required Uint8List bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async => Right(_document());

  @override
  Future<Either<CustomFailure, CaseEntity>> saveDraftCase({
    required CaseEntity draft,
  }) async => Right(draft);

  @override
  Future<Either<CustomFailure, CaseEntity>> submitCaseForReview({
    required String caseId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> updateProfile({
    required BeneficiaryEntity beneficiary,
  }) async => Right(beneficiary);

  @override
  Stream<Either<CustomFailure, List<CaseEntity>>> watchOwnedCases({
    int limit = 10,
  }) => const Stream.empty();

  BeneficiaryEntity _profile(String status) {
    return BeneficiaryEntity(
      id: 'uid-1',
      fullName: 'Beneficiary Name',
      phone: '+201000000000',
      nationalId: '12345678901234',
      dateOfBirth: DateTime(1990, 5, 10),
      address: 'Street 1',
      city: 'Cairo',
      governorate: 'Cairo',
      familySize: 4,
      incomeStatus: IncomeStatusOption.low,
      healthCondition: HealthConditionOption.chronic,
      healthDetails: 'Notes',
      debtInfo: 'Debt',
      monthlyExpenses: 1200,
      hasLoans: true,
      payoutMethod: PayoutMethodOption.vodafoneCash,
      payoutAccount: '01000000000',
      bankName: null,
      accountNumber: null,
      accountHolderName: null,
      documentIds: const ['doc-1'],
      status: status,
      isDeleted: false,
      schemaVersion: 1,
      documents: const [],
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
  }

  DocumentEntity _document() {
    return const DocumentEntity(
      id: 'doc-1',
      ownerId: 'uid-1',
      type: RequiredDocumentType.idCard,
      displayName: 'ID Card',
      fileName: 'id.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 10,
      storageKey: 'key',
      status: 'ready',
      uploadId: 'upload-1',
      isDeleted: false,
      schemaVersion: 1,
      createdAt: null,
      updatedAt: null,
    );
  }
}

class _FakeAuthRepo implements AuthRepo {
  @override
  String? get currentUserId => 'uid-1';

  @override
  String? get currentUserPhone => '+201000000000';

  @override
  Future<Either<AuthFailure, String?>> getUserRole({required String uid}) async {
    return const Right('Beneficiary');
  }

  @override
  Future<Either<AuthFailure, Unit>> saveUserRole({
    required String uid,
    required String role,
    required String phone,
  }) async => const Right(unit);

  @override
  Future<void> signOut() async {}

  @override
  Future<Either<AuthFailure, String>> verifyPhone({required String phone}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, String>> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    throw UnimplementedError();
  }
}
