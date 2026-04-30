import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:dartz/dartz.dart';

import '../repositories/donor_repository.dart';

class GetDonorProfile {
  final DonorRepo _repo;

  const GetDonorProfile(this._repo);

  Future<Either<CustomFailure, DonorEntity>> call(String uid) {
    return _repo.getDonorProfile(uid);
  }
}
