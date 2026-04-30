import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:dartz/dartz.dart';

abstract class DonorRepo {
  Future<Either<CustomFailure, void>> saveDonorProfile(DonorEntity donor);

  Future<Either<CustomFailure, DonorEntity>> getDonorProfile(String uid);

  Future<Either<CustomFailure, void>> savePaymentMethod({
    required String uid,
    required PaymentMethodEntity paymentMethod,
  });

  Future<Either<CustomFailure, PaymentMethodEntity?>> getCachedPaymentMethod();

  Future<Either<CustomFailure, List<DonationHistoryEntity>>> getDonationHistory(
    String uid,
  );
}
