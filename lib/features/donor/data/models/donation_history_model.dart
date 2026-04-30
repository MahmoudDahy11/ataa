import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationHistoryModel {
  final String donationId;
  final String caseTitle;
  final double amount;
  final DateTime date;
  final String status;

  const DonationHistoryModel({
    required this.donationId,
    required this.caseTitle,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory DonationHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationHistoryModel(
      donationId: doc.id,
      caseTitle: data['caseTitle'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  DonationHistoryEntity toEntity() {
    return DonationHistoryEntity(
      donationId: donationId,
      caseTitle: caseTitle,
      amount: amount,
      date: date,
      status: DonationStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => DonationStatus.pending,
      ),
    );
  }
}
