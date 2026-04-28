import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:dartz/dartz.dart';

class SaveBeneficiaryCase {
  final BeneficiaryRepo _repo;

  SaveBeneficiaryCase(this._repo);

  Future<Either<CustomFailure, CaseEntity>> call(CaseEntity draft) {
    return _repo.saveDraftCase(draft: draft);
  }
}
