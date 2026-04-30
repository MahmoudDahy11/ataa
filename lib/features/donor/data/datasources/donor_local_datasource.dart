import 'package:ataa/features/donor/data/models/donor_hive_model.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:hive/hive.dart';

abstract class DonorLocalDataSource {
  Future<void> cacheDonorProfile(DonorHiveModel donor);
  Future<DonorHiveModel?> getCachedDonorProfile();
  Future<void> cachePaymentMethod(PaymentMethodEntity paymentMethod);
  Future<PaymentMethodEntity?> getCachedPaymentMethod();
  Future<void> clearDonorCache();
}

class DonorLocalDataSourceImpl implements DonorLocalDataSource {
  final Box _box;

  const DonorLocalDataSourceImpl({required Box box}) : _box = box;

  static const _donorKey = 'cached_donor';
  static const _paymentTypeKey = 'cached_payment_type';
  static const _paymentVodafoneKey = 'cached_payment_vodafone';

  @override
  Future<void> cacheDonorProfile(DonorHiveModel donor) async {
    await _box.put(_donorKey, donor);
  }

  @override
  Future<DonorHiveModel?> getCachedDonorProfile() async {
    return _box.get(_donorKey) as DonorHiveModel?;
  }

  @override
  Future<void> cachePaymentMethod(PaymentMethodEntity paymentMethod) async {
    await _box.put(_paymentTypeKey, paymentMethod.type.name);
    if (paymentMethod.vodafoneNumber != null) {
      await _box.put(_paymentVodafoneKey, paymentMethod.vodafoneNumber);
    }
  }

  @override
  Future<PaymentMethodEntity?> getCachedPaymentMethod() async {
    final typeStr = _box.get(_paymentTypeKey) as String?;
    if (typeStr == null) return null;
    final type = PaymentType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => PaymentType.visa,
    );
    return PaymentMethodEntity(
      type: type,
      vodafoneNumber: _box.get(_paymentVodafoneKey) as String?,
    );
  }

  @override
  Future<void> clearDonorCache() async {
    await _box.deleteAll([_donorKey, _paymentTypeKey, _paymentVodafoneKey]);
  }
}
