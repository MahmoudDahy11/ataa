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

class OtpVerificationView extends StatelessWidget {
  final String verificationId;
  final String phone;

  const OtpVerificationView({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: OtpVerificationViewBody(
        verificationId: verificationId,
        phone: phone,
      ),
    );
  }
}

class OtpVerificationViewBody extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OtpVerificationViewBody({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<OtpVerificationViewBody> createState() =>
      _OtpVerificationViewBodyState();
}

class _OtpVerificationViewBodyState extends State<OtpVerificationViewBody> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: _onStateChange,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Verify OTP',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                CustomTextField(
                  hintText: 'OTP Code',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: 16),
                _buildResendButton(context),
                const Spacer(),
                CustomGradientButton(
                  text: 'Verify',
                  isLoading: state is AuthLoading,
                  onPressed: () => _onVerify(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter OTP Code',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter the 6-digit code sent to ${widget.phone}',
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildResendButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.read<AuthCubit>().resendCode();
          showSnakBar(context, AppStrings.codeResent);
        },
        child: const Text(
          'Resend Code',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, AuthState state) {
    if (state is AuthError) {
      showSnakBar(context, state.message, isError: true);
    } else if (state is AuthOTPVerified) {
      showSnakBar(context, AppStrings.otpVerified);
      context.go(AppRouter.roleSelectionRoute);
    } else if (state is AuthRoleSelected) {
      showSnakBar(context, 'Welcome back as ${state.role}!');
      if (state.role == AppStrings.beneficiaryRole) {
        context.go(AppRouter.beneficiaryDashboardRoute);
      } else if (state.role == AppStrings.donorRole) {
        context.go(AppRouter.donorProfileRoute);
      }
    }
  }

  void _onVerify(BuildContext context) {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      showSnakBar(context, AppStrings.otpEmpty, isError: true);
      return;
    }
    context.read<AuthCubit>().verifyOTP(otp);
  }
}
