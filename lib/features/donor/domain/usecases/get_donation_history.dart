import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:dartz/dartz.dart';

import '../repositories/donor_repository.dart';

class GetDonationHistory {
  final DonorRepo _repo;

  const GetDonationHistory(this._repo);

  Future<Either<CustomFailure, List<DonationHistoryEntity>>> call(String uid) {
    return _repo.getDonationHistory(uid);
  }
}
