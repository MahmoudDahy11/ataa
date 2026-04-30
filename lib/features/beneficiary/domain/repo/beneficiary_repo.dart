import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

abstract class BeneficiaryRepo {
  Future<Either<CustomFailure, BeneficiaryEntity>> registerBeneficiary({
    required BeneficiaryEntity beneficiary,
  });

  Future<Either<CustomFailure, BeneficiaryEntity>> getProfile();

  Future<Either<CustomFailure, BeneficiaryEntity>> updateProfile({
    required BeneficiaryEntity beneficiary,
  });

  Stream<Either<CustomFailure, List<CaseEntity>>> watchOwnedCases({
    int limit = 10,
  });

  Future<Either<CustomFailure, List<CaseEntity>>> getOwnedCasesPage({
    DocumentSnapshot<Object?>? startAfter,
    int limit = 10,
  });

  Future<Either<CustomFailure, CaseEntity>> getCaseById(String caseId);

  Future<Either<CustomFailure, CaseEntity>> saveDraftCase({
    required CaseEntity draft,
  });

  Future<Either<CustomFailure, CaseEntity>> submitCaseForReview({
    required String caseId,
  });
}
