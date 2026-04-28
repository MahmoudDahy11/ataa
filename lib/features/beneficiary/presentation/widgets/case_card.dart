import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/features/beneficiary/domain/entities/case_entity.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class CaseCard extends StatelessWidget {
  final CaseEntity item;
  final VoidCallback onTap;

  const CaseCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = item.targetAmount == 0
        ? 0.0
        : (item.collectedAmount / item.targetAmount).clamp(0, 1).toDouble();
    return Card(
      color: AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(item.title, style: AppTextStyles.titleLarge),
                  ),
                  StatusBadge(label: item.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
              ),
              const SizedBox(height: 8),
              Text(
                'EGP ${item.collectedAmount.toStringAsFixed(0)} / ${item.targetAmount.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
