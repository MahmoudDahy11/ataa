import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/document_upload_widget.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficiaryCaseCreateView extends StatelessWidget {
  const BeneficiaryCaseCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>()..loadProfile(),
      child: const _BeneficiaryCaseCreateBody(),
    );
  }
}

class _BeneficiaryCaseCreateBody extends StatelessWidget {
  const _BeneficiaryCaseCreateBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          showSnakBar(context, state.errorMessage!, isError: true);
        } else if (state.successMessage != null) {
          showSnakBar(context, state.successMessage!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<BeneficiaryCubit>();
        final draft = state.caseDraft;
        final canCreate = cubit.canCreateCase();
        return Scaffold(
          appBar: AppBar(title: const Text('Create Case')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (!canCreate)
                const Text(
                  'Case creation is locked until beneficiary approval is complete.',
                ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Title',
                initialValue: draft.title,
                onChanged: (value) =>
                    cubit.saveDraftCase(draft.copyWith(title: value)),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Category',
                initialValue: draft.category,
                onChanged: (value) =>
                    cubit.saveDraftCase(draft.copyWith(category: value)),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Target amount',
                initialValue: draft.targetAmount == 0
                    ? ''
                    : draft.targetAmount.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => cubit.saveDraftCase(
                  draft.copyWith(targetAmount: double.tryParse(value) ?? 0),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Description',
                initialValue: draft.description,
                maxLines: 5,
                onChanged: (value) =>
                    cubit.saveDraftCase(draft.copyWith(description: value)),
              ),
              const SizedBox(height: 16),
              BlocProvider<UploadCubit>(
                create: (_) => sl<UploadCubit>(),
                child: DocumentUploadWidget(
                  documentType: 'case_media',
                  label: 'Upload case attachment',
                  helperText: 'JPG, PNG, or PDF up to 5 MB',
                  onUploaded: cubit.saveUploadedDocument,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: canCreate ? cubit.persistCaseDraft : null,
                    child: const Text('Save draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomGradientButton(
                    text: 'Submit',
                    isLoading: state.isSavingCase,
                    onPressed: canCreate ? cubit.submitCase : () {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
