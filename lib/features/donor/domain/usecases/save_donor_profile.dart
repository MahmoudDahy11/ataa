import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:dartz/dartz.dart';

import '../repositories/donor_repository.dart';

class SaveDonorProfile {
  final DonorRepo _repo;

  const SaveDonorProfile(this._repo);

  Future<Either<CustomFailure, void>> call(DonorEntity donor) {
    return _repo.saveDonorProfile(donor);
  }
}
