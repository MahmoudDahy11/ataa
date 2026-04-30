import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:flutter/material.dart';

class DonationHistoryItem extends StatelessWidget {
  final DonationHistoryEntity donation;

  const DonationHistoryItem({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          _StatusBadge(status: donation.status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(donation.caseTitle, style: AppTextStyles.titleMedium),
                Text(
                  _formatDate(donation.date),
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${donation.amount.toStringAsFixed(0)} ج',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final DonationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DonationStatus.success => Colors.green,
      DonationStatus.pending => Colors.orange,
      DonationStatus.failed => Colors.red,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
