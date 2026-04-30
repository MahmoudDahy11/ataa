import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/profile_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/edit_profile_sections.dart';

class BeneficiaryEditProfileView extends StatelessWidget {
  const BeneficiaryEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<BeneficiaryCubit>()..loadProfile(),
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody();

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            showSnakBar(context, state.successMessage!);
            context.pop();
          } else if (state.errorMessage != null) {
            showSnakBar(context, state.errorMessage!, isError: true);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const ProfileSkeleton();
          }
          final draft = state.registrationDraft;

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      PersonalInfoSection(
                        draft: draft,
                        onChanged: (d) => context
                            .read<BeneficiaryCubit>()
                            .saveRegistrationStep(d),
                      ),
                      const Divider(height: 40),
                      FinancialInfoSection(
                        draft: draft,
                        onChanged: (d) => context
                            .read<BeneficiaryCubit>()
                            .saveRegistrationStep(d),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                _buildSubmitButton(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, BeneficiaryState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: CustomGradientButton(
        text: 'حفظ التغييرات',
        isLoading: state.isSubmittingRegistration,
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            context.read<BeneficiaryCubit>().updateProfile();
          }
        },
      ),
    );
  }
}
