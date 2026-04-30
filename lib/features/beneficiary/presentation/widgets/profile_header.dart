import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final BeneficiaryEntity profile;
  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAvatar(),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        StatusBadge(status: profile.status),
      ],
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.gold.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              profile.fullName.isEmpty
                  ? '?'
                  : profile.fullName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
