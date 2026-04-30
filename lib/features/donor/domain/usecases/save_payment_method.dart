import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:dartz/dartz.dart';

import '../repositories/donor_repository.dart';

class SavePaymentMethod {
  final DonorRepo _repo;

  const SavePaymentMethod(this._repo);

  Future<Either<CustomFailure, void>> call({
    required String uid,
    required PaymentMethodEntity paymentMethod,
  }) {
    return _repo.savePaymentMethod(uid: uid, paymentMethod: paymentMethod);
  }
}
