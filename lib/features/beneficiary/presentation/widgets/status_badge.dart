import 'package:ataa/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;

  const StatusBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'approved' || 'collecting' || 'completed' || 'paid' => AppColors.primary,
      'rejected' => AppColors.error,
      _ => AppColors.gold,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
