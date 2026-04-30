import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/registration_steps.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/step_header.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BeneficiaryRegisterView extends StatelessWidget {
  const BeneficiaryRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>(),
      child: const _BeneficiaryRegisterBody(),
    );
  }
}

class _BeneficiaryRegisterBody extends StatelessWidget {
  const _BeneficiaryRegisterBody();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            showSnakBar(context, state.errorMessage!, isError: true);
          } else if (state.successMessage != null) {
            showSnakBar(context, state.successMessage!);
            if (state.profile != null) {
              context.go('/beneficiary/dashboard');
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<BeneficiaryCubit>();
          final canContinue =
              cubit.canContinueRegistration() &&
              !state.isSubmittingRegistration;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('تسجيل مستفيد')),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                children: [
                  StepIndicator(currentStep: state.currentStep, totalSteps: 5),
                  const SizedBox(height: 18),
                  StepHeader(step: state.currentStep),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    child: RegistrationStep(
                      key: ValueKey(state.currentStep),
                      state: state,
                      onDraftChanged: cubit.saveRegistrationStep,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.96),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (state.currentStep > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              cubit.goToStep(state.currentStep - 1),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('رجوع'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    if (state.currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomGradientButton(
                        text: state.currentStep == 4 ? 'إرسال الطلب' : 'التالي',
                        isLoading: state.isSubmittingRegistration,
                        onPressed: canContinue
                            ? cubit.continueRegistration
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
