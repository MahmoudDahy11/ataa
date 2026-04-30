import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SelectionOption<T> {
  final T value;
  final String title;
  final String subtitle;
  final IconData icon;

  const SelectionOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class SelectionGrid<T> extends StatelessWidget {
  final String title;
  final T? value;
  final List<SelectionOption<T>> options;
  final Function(T) onChanged;

  const SelectionGrid({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...options.map(
          (opt) => _SelectionCard<T>(
            option: opt,
            isSelected: opt.value == value,
            onTap: () => onChanged(opt.value),
          ),
        ),
      ],
    );
  }
}

class _SelectionCard<T> extends StatelessWidget {
  final SelectionOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
