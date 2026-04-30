enum DonationStatus { success, pending, failed }

class DonationHistoryEntity {
  final String donationId;
  final String caseTitle;
  final double amount;
  final DateTime date;
  final DonationStatus status;

  const DonationHistoryEntity({
    required this.donationId,
    required this.caseTitle,
    required this.amount,
    required this.date,
    required this.status,
  });

  String get statusLabel {
    switch (status) {
      case DonationStatus.success:
        return 'ناجح';
      case DonationStatus.pending:
        return 'قيد المعالجة';
      case DonationStatus.failed:
        return 'فشل';
    }
  }
}
