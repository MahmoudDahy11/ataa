import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StepHeader extends StatelessWidget {
  final int step;

  const StepHeader({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final data = _StepCopy.items[step];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  data.helper,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${step + 1}/5',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCopy {
  final String title;
  final String helper;
  final IconData icon;

  const _StepCopy({
    required this.title,
    required this.helper,
    required this.icon,
  });

  static const items = <_StepCopy>[
    _StepCopy(
      title: 'بياناتك الأساسية',
      helper: 'نراجع الهوية بدون تعقيد أو أسئلة زائدة',
      icon: Icons.person_search_rounded,
    ),
    _StepCopy(
      title: 'العنوان',
      helper: 'اختيارات واضحة تساعد فريق المراجعة',
      icon: Icons.location_on_outlined,
    ),
    _StepCopy(
      title: 'الأسرة والدخل',
      helper: 'اختر الأقرب لوضعك الحالي بضغطة واحدة',
      icon: Icons.family_restroom_rounded,
    ),
    _StepCopy(
      title: 'الحالة الصحية',
      helper: 'بدون كتابة تفاصيل حساسة، اختيارات محترمة فقط',
      icon: Icons.health_and_safety_outlined,
    ),
    _StepCopy(
      title: 'التحقق من الهوية',
      helper: 'مستند واحد فقط: بطاقة الرقم القومي',
      icon: Icons.verified_outlined,
    ),
  ];
}
