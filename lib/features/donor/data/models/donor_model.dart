import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final double totalDonated;
  final int donationsCount;
  final int casesSupportedCount;
  final String? paymentType;
  final String? vodafoneNumber;
  final String? cardToken;
  final DateTime createdAt;

  const DonorModel({
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

  factory DonorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonorModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      totalDonated: (data['totalDonated'] ?? 0).toDouble(),
      donationsCount: data['donationsCount'] ?? 0,
      casesSupportedCount: data['casesSupportedCount'] ?? 0,
      paymentType: data['paymentType'],
      vodafoneNumber: data['vodafoneNumber'],
      cardToken: data['cardToken'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'phoneNumber': phoneNumber,
    'totalDonated': totalDonated,
    'donationsCount': donationsCount,
    'casesSupportedCount': casesSupportedCount,
    'paymentType': paymentType,
    'vodafoneNumber': vodafoneNumber,
    'cardToken': cardToken,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory DonorModel.fromEntity(DonorEntity entity) => DonorModel(
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
