import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:dartz/dartz.dart';

class RegisterBeneficiary {
  final BeneficiaryRepo _repo;

  RegisterBeneficiary(this._repo);

  Future<Either<CustomFailure, BeneficiaryEntity>> call(
    BeneficiaryEntity beneficiary,
  ) {
    return _repo.registerBeneficiary(beneficiary: beneficiary);
  }
}
