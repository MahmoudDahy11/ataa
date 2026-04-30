import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/data/data_source/beneficiary_remote_data_source.dart';
import 'package:ataa/features/beneficiary/data/models/beneficiary.dart';
import 'package:ataa/features/beneficiary/data/models/case_model.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class BeneficiaryRepoImpl implements BeneficiaryRepo {
  final BeneficiaryRemoteDataSource _dataSource;

  BeneficiaryRepoImpl({required BeneficiaryRemoteDataSource dataSource})
    : _dataSource = dataSource;

  Future<Either<CustomFailure, T>> _handle<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on FirebaseException catch (e) {
      return Left(AuthFailure.fromGenericError(e.message ?? e.code));
    } catch (e) {
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> registerBeneficiary({
    required BeneficiaryEntity beneficiary,
  }) => _handle<BeneficiaryEntity>(
    () => _dataSource.register(
      beneficiary: BeneficiaryModel.fromEntity(beneficiary),
    ),
  );

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> getProfile() =>
      _handle<BeneficiaryEntity>(() => _dataSource.getProfile());

  @override
  Future<Either<CustomFailure, BeneficiaryEntity>> updateProfile({
    required BeneficiaryEntity beneficiary,
  }) => _handle<BeneficiaryEntity>(
    () => _dataSource.updateProfile(
      beneficiary: BeneficiaryModel.fromEntity(beneficiary),
    ),
  );

  @override
  Stream<Either<CustomFailure, List<CaseEntity>>> watchOwnedCases({
    int limit = 10,
  }) => _dataSource
      .watchOwnedCases(limit: limit)
      .map((cases) => Right<CustomFailure, List<CaseEntity>>(cases));

  @override
  Future<Either<CustomFailure, List<CaseEntity>>> getOwnedCasesPage({
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) => _handle<List<CaseEntity>>(
    () => _dataSource.getOwnedCasesPage(startAfter: startAfter, limit: limit),
  );

  @override
  Future<Either<CustomFailure, CaseEntity>> getCaseById(String caseId) =>
      _handle<CaseEntity>(() => _dataSource.getCaseById(caseId));

  @override
  Future<Either<CustomFailure, CaseEntity>> saveDraftCase({
    required CaseEntity draft,
  }) async {
    return _handle<CaseEntity>(() async {
      final p = await _dataSource.getProfile();
      if (p.status != BeneficiaryStatus.approved) {
        throw 'Approval is required first.';
      }
      return _dataSource.saveDraftCase(draft: CaseModel.fromEntity(draft));
    });
  }

  @override
  Future<Either<CustomFailure, CaseEntity>> submitCaseForReview({
    required String caseId,
  }) async {
    return _handle<CaseEntity>(() async {
      final p = await _dataSource.getProfile();
      if (p.status != BeneficiaryStatus.approved) {
        throw 'Approval is required first.';
      }
      return _dataSource.submitCaseForReview(caseId: caseId);
    });
  }
}
