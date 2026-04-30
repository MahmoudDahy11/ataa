import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';

class DonorEntity {
  final String uid;
  final String name;
  final String phoneNumber;
  final double totalDonated;
  final int donationsCount;
  final int casesSupportedCount;
  final PaymentMethodEntity? paymentMethod;
  final DateTime createdAt;

  const DonorEntity({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    this.totalDonated = 0,
    this.donationsCount = 0,
    this.casesSupportedCount = 0,
    this.paymentMethod,
    required this.createdAt,
  });

  String get avatarInitials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name
        .trim()
        .substring(0, name.trim().length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  DonorEntity copyWith({
    String? name,
    double? totalDonated,
    int? donationsCount,
    int? casesSupportedCount,
    PaymentMethodEntity? paymentMethod,
  }) {
    return DonorEntity(
      uid: uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber,
      totalDonated: totalDonated ?? this.totalDonated,
      donationsCount: donationsCount ?? this.donationsCount,
      casesSupportedCount: casesSupportedCount ?? this.casesSupportedCount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt,
    );
  }
}
