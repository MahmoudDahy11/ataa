import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ataa/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: const RoleSelectionViewBody(),
    );
  }
}

class RoleSelectionViewBody extends StatefulWidget {
  const RoleSelectionViewBody({super.key});

  @override
  State<RoleSelectionViewBody> createState() => _RoleSelectionViewBodyState();
}

class _RoleSelectionViewBodyState extends State<RoleSelectionViewBody> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showSnakBar(context, state.message, isError: true);
        } else if (state is AuthRoleSelected) {
          showSnakBar(context, 'Welcome as ${state.role}!');
          // Navigate to Home Feed or Dashboard based on role
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Select Your Role',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            automaticallyImplyLeading: false, // Don't let user go back to OTP
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How would you like to use Ataa?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose your primary role. This cannot be changed later for this phone number.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                _buildRoleCard(
                  title: 'Donor',
                  description:
                      'I want to browse cases and donate to those in need.',
                  icon: Icons.volunteer_activism_rounded,
                  value: 'Donor',
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  title: 'Beneficiary',
                  description:
                      'I am seeking support and want to register my case.',
                  icon: Icons.handshake_rounded,
                  value: 'Beneficiary',
                ),
                const Spacer(),
                CustomGradientButton(
                  text: 'Complete Setup',
                  isLoading: state is AuthLoading,
                  onPressed: () {
                    if (_selectedRole == null) {
                      showSnakBar(
                        context,
                        AppStrings.selectRoleMsg,
                        isError: true,
                      );
                      return;
                    }
                    context.read<AuthCubit>().selectRole(_selectedRole!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textHint.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
