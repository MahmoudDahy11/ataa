import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_setup_cubit.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_setup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DonorSetupScreen extends StatelessWidget {
  const DonorSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DonorSetupCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حسابك', style: AppTextStyles.bodyLarge),
        centerTitle: true,
      ),
      body: BlocListener<DonorSetupCubit, DonorSetupState>(
        listener: (context, state) {
          if (state is DonorSetupError) {
            showSnakBar(context, state.message, isError: true);
          } else if (state is DonorSetupSuccess) {
            context.pushNamed('payment_method');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarPreview(initialsNotifier: cubit.initialsNotifier),
              const SizedBox(height: 32),
              const Text('ما اسمك؟', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 12),
              CustomTextField(
                controller: cubit.nameController,
                hintText: 'أدخل اسمك',
              ),
              const Spacer(),
              _SubmitButton(cubit: cubit),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final ValueNotifier<String> initialsNotifier;
  const _AvatarPreview({required this.initialsNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: initialsNotifier,
      builder: (_, initials, _) => CircleAvatar(
        radius: 48,
        backgroundColor: AppColors.primary,
        child: Text(
          initials.isEmpty ? '؟' : initials,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final DonorSetupCubit cubit;
  const _SubmitButton({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DonorSetupCubit, DonorSetupState>(
      builder: (context, state) {
        final isLoading = state is DonorSetupLoading;
        return ValueListenableBuilder<bool>(
          valueListenable: cubit.isButtonEnabledNotifier,
          builder: (_, isEnabled, _) => CustomGradientButton(
            text: 'التالي',
            isLoading: isLoading,
            onPressed: (isEnabled && !isLoading) ? cubit.saveProfile : null,
          ),
        );
      },
    );
  }
}
