import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:dartz/dartz.dart';

class GetBeneficiaryProfile {
  final BeneficiaryRepo _repo;

  GetBeneficiaryProfile(this._repo);

  Future<Either<CustomFailure, BeneficiaryEntity>> call() {
    return _repo.getProfile();
  }
}
