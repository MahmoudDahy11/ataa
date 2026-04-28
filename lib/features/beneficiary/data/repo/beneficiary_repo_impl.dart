import 'dart:async';
import 'dart:typed_data';

import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/data/data_source/beneficiary_remote_data_source.dart';
import 'package:ataa/features/beneficiary/data/models/beneficiary.dart';
import 'package:ataa/features/beneficiary/data/models/case_model.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/upload_entities.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class BeneficiaryRepoImpl implements BeneficiaryRepo {
  final BeneficiaryRemoteDataSource _dataSource;

  BeneficiaryRepoImpl({required BeneficiaryRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> registerBeneficiary({
    required BeneficiaryEntity beneficiary,
  }) async {
    try {
      final model = await _dataSource.register(
        beneficiary: BeneficiaryModel(
          id: beneficiary.id,
          fullName: beneficiary.fullName,
          phone: beneficiary.phone,
          nationalId: beneficiary.nationalId,
          dateOfBirth: beneficiary.dateOfBirth,
          address: beneficiary.address,
          city: beneficiary.city,
          governorate: beneficiary.governorate,
          familySize: beneficiary.familySize,
          incomeStatus: beneficiary.incomeStatus,
          healthCondition: beneficiary.healthCondition,
          healthDetails: beneficiary.healthDetails,
          debtInfo: beneficiary.debtInfo,
          monthlyExpenses: beneficiary.monthlyExpenses,
          hasLoans: beneficiary.hasLoans,
          payoutMethod: beneficiary.payoutMethod,
          payoutAccount: beneficiary.payoutAccount,
          bankName: beneficiary.bankName,
          accountNumber: beneficiary.accountNumber,
          accountHolderName: beneficiary.accountHolderName,
          documentIds: beneficiary.documentIds,
          status: beneficiary.status,
          isDeleted: beneficiary.isDeleted,
          schemaVersion: beneficiary.schemaVersion,
          documents: beneficiary.documents,
          createdAt: beneficiary.createdAt,
          updatedAt: beneficiary.updatedAt,
        ),
      );
      return Right(model);
    } on FirebaseException catch (error) {
      return Left(AuthFailure.fromGenericError(error.message ?? error.code));
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> getProfile() async {
    try {
      return Right(await _dataSource.getProfile());
    } on FirebaseException catch (error) {
      return Left(AuthFailure.fromGenericError(error.message ?? error.code));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> updateProfile({
    required BeneficiaryEntity beneficiary,
  }) async {
    try {
      final model = await _dataSource.updateProfile(
        beneficiary: BeneficiaryModel(
          id: beneficiary.id,
          fullName: beneficiary.fullName,
          phone: beneficiary.phone,
          nationalId: beneficiary.nationalId,
          dateOfBirth: beneficiary.dateOfBirth,
          address: beneficiary.address,
          city: beneficiary.city,
          governorate: beneficiary.governorate,
          familySize: beneficiary.familySize,
          incomeStatus: beneficiary.incomeStatus,
          healthCondition: beneficiary.healthCondition,
          healthDetails: beneficiary.healthDetails,
          debtInfo: beneficiary.debtInfo,
          monthlyExpenses: beneficiary.monthlyExpenses,
          hasLoans: beneficiary.hasLoans,
          payoutMethod: beneficiary.payoutMethod,
          payoutAccount: beneficiary.payoutAccount,
          bankName: beneficiary.bankName,
          accountNumber: beneficiary.accountNumber,
          accountHolderName: beneficiary.accountHolderName,
          documentIds: beneficiary.documentIds,
          status: beneficiary.status,
          isDeleted: beneficiary.isDeleted,
          schemaVersion: beneficiary.schemaVersion,
          documents: beneficiary.documents,
          createdAt: beneficiary.createdAt,
          updatedAt: beneficiary.updatedAt,
        ),
      );
      return Right(model);
    } on FirebaseException catch (error) {
      return Left(AuthFailure.fromGenericError(error.message ?? error.code));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Stream<Either<CustomFailure, List<CaseEntity>>> watchOwnedCases({
    int limit = 10,
  }) {
    return _dataSource
        .watchOwnedCases(limit: limit)
        .map((cases) => Right<CustomFailure, List<CaseEntity>>(cases));
  }

  @override
  Future<Either<CustomFailure, List<CaseEntity>>> getOwnedCasesPage({
    DocumentSnapshot<Object?>? startAfter,
    int limit = 10,
  }) async {
    try {
      return Right(
        await _dataSource.getOwnedCasesPage(
          startAfter: startAfter,
          limit: limit,
        ),
      );
    } on FirebaseException catch (error) {
      return Left(AuthFailure.fromGenericError(error.message ?? error.code));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, CaseEntity>> getCaseById(String caseId) async {
    try {
      return Right(await _dataSource.getCaseById(caseId));
    } on FirebaseException catch (error) {
      return Left(AuthFailure.fromGenericError(error.message ?? error.code));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, CaseEntity>> saveDraftCase({
    required CaseEntity draft,
  }) async {
    try {
      final profile = await _dataSource.getProfile();
      if (profile.status != BeneficiaryStatus.approved) {
        return Left(
          AuthFailure.fromGenericError('Approval is required first.'),
        );
      }
      final model = await _dataSource.saveDraftCase(
        draft: CaseModel(
          id: draft.id,
          beneficiaryId: draft.beneficiaryId,
          title: draft.title,
          category: draft.category,
          targetAmount: draft.targetAmount,
          collectedAmount: draft.collectedAmount,
          description: draft.description,
          mediaKeys: draft.mediaKeys,
          status: CaseLifecycle.draft,
          isDeleted: draft.isDeleted,
          schemaVersion: draft.schemaVersion,
          createdAt: draft.createdAt,
          updatedAt: draft.updatedAt,
        ),
      );
      return Right(model);
    } on FirebaseException catch (error) {
      return Left(AuthFailure.fromGenericError(error.message ?? error.code));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, CaseEntity>> submitCaseForReview({
    required String caseId,
  }) async {
    try {
      final profile = await _dataSource.getProfile();
      if (profile.status != BeneficiaryStatus.approved) {
        return Left(
          AuthFailure.fromGenericError('Approval is required first.'),
        );
      }
      return Right(await _dataSource.submitCaseForReview(caseId: caseId));
    } on FirebaseException catch (error) {
      return Left(AuthFailure.fromGenericError(error.message ?? error.code));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, UploadSession>> initUpload({
    required UploadRequest request,
  }) async {
    try {
      return Right(await _dataSource.initUpload(request: request));
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, DocumentEntity>> confirmUpload({
    required String uploadId,
    required String ownerId,
    required String type,
  }) async {
    try {
      return Right(
        await _dataSource.confirmUpload(
          uploadId: uploadId,
          ownerId: ownerId,
          type: type,
        ),
      );
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, DocumentEntity>> retryUpload({
    required String uploadId,
    required String ownerId,
    required String type,
    required Uint8List bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final session = await _dataSource.getUploadSession(uploadId);
      await _uploadWithBackoff(
        session: session,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: onProgress,
      );
      return confirmUpload(uploadId: uploadId, ownerId: ownerId, type: type);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  Future<void> _uploadWithBackoff({
    required UploadSession session,
    required Uint8List bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _dataSource.uploadBytes(
          session: session,
          bytes: bytes,
          mimeType: mimeType,
          onProgress: onProgress,
        );
        return;
      } catch (_) {
        if (attempt == 2) {
          rethrow;
        }
        await Future<void>.delayed(Duration(seconds: 1 << attempt));
      }
    }
  }
}
