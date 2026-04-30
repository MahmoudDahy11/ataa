import 'package:ataa/features/donor/data/models/donation_history_model.dart';
import 'package:ataa/features/donor/data/models/donor_model.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';

abstract class DonorRemoteDataSource {
  Future<void> saveDonorProfile(DonorModel donor);
  Future<DonorModel> getDonorProfile(String uid);
  Future<void> savePaymentMethod({
    required String uid,
    required PaymentMethodEntity paymentMethod,
  });
  Future<List<DonationHistoryModel>> getDonationHistory(String uid);
}
