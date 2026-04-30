import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/router/app_router.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ataa/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PhoneInputView extends StatelessWidget {
  const PhoneInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: const PhoneInputViewBody(),
    );
  }
}

class PhoneInputViewBody extends StatefulWidget {
  const PhoneInputViewBody({super.key});

  @override
  State<PhoneInputViewBody> createState() => _PhoneInputViewBodyState();
}

class _PhoneInputViewBodyState extends State<PhoneInputViewBody> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showSnakBar(context, state.message, isError: true);
        } else if (state is AuthCodeSent) {
          showSnakBar(context, AppStrings.codeSent);
          context.push(
            AppRouter.otpRoute,
            extra: {
              'verificationId': state.verificationId,
              'phone': state.phone,
            },
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Login',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your phone number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We will send you a 6-digit OTP code to verify your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  hintText: 'Phone Number (e.g. +201XXXXXXXXX)',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_rounded,
                ),
                const Spacer(),
                CustomGradientButton(
                  text: 'Continue',
                  isLoading: state is AuthLoading,
                  onPressed: () => _onSubmit(context),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        context.go(AppRouter.beneficiaryDashboardRoute),
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSubmit(BuildContext context) {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showSnakBar(context, AppStrings.phoneEmpty, isError: true);
      return;
    }
    context.read<AuthCubit>().submitPhone(phone);
  }
}
