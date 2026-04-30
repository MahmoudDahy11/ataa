import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:hive/hive.dart';

part 'donor_hive_model.g.dart';

@HiveType(typeId: 10)
class DonorHiveModel extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final double totalDonated;

  @HiveField(4)
  final int donationsCount;

  @HiveField(5)
  final int casesSupportedCount;

  @HiveField(6)
  final String? paymentType;

  @HiveField(7)
  final String? vodafoneNumber;

  @HiveField(8)
  final String? cardToken;

  @HiveField(9)
  final DateTime createdAt;

  DonorHiveModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.totalDonated,
    required this.donationsCount,
    required this.casesSupportedCount,
    this.paymentType,
    this.vodafoneNumber,
    this.cardToken,
    required this.createdAt,
  });

  factory DonorHiveModel.fromEntity(DonorEntity entity) {
    return DonorHiveModel(
      uid: entity.uid,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      totalDonated: entity.totalDonated,
      donationsCount: entity.donationsCount,
      casesSupportedCount: entity.casesSupportedCount,
      paymentType: entity.paymentMethod?.type.name,
      vodafoneNumber: entity.paymentMethod?.vodafoneNumber,
      cardToken: entity.paymentMethod?.cardToken,
      createdAt: entity.createdAt,
    );
  }

  DonorEntity toEntity() {
    PaymentMethodEntity? payment;
    if (paymentType != null) {
      final type = PaymentType.values.firstWhere((e) => e.name == paymentType);
      payment = PaymentMethodEntity(
        type: type,
        vodafoneNumber: vodafoneNumber,
        cardToken: cardToken,
      );
    }
    return DonorEntity(
      uid: uid,
      name: name,
      phoneNumber: phoneNumber,
      totalDonated: totalDonated,
      donationsCount: donationsCount,
      casesSupportedCount: casesSupportedCount,
      paymentMethod: payment,
      createdAt: createdAt,
    );
  }
}
