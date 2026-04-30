import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      BeneficiaryStatus.approved || 'collecting' || 'completed' || 'paid' => (
        Colors.green,
        BeneficiaryStatus.labels[BeneficiaryStatus.approved] ?? 'Approved',
      ),
      BeneficiaryStatus.rejected => (
        AppColors.error,
        BeneficiaryStatus.labels[BeneficiaryStatus.rejected] ?? 'Rejected',
      ),
      BeneficiaryStatus.pendingReview => (
        Colors.orange,
        BeneficiaryStatus.labels[BeneficiaryStatus.pendingReview] ?? 'Pending',
      ),
      BeneficiaryStatus.actionRequired => (
        Colors.blue,
        BeneficiaryStatus.labels[BeneficiaryStatus.actionRequired] ??
            'Action Required',
      ),
      BeneficiaryStatus.verified => (
        AppColors.primary,
        BeneficiaryStatus.labels[BeneficiaryStatus.verified] ?? 'Verified',
      ),
      _ => (AppColors.gold, status.replaceAll('_', ' ')),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
