import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/registration_draft.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/beneficiary_display_utils.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/document_upload_widget.dart';
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
    return BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
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
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Beneficiary Registration')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              StepIndicator(currentStep: state.currentStep, totalSteps: 7),
              const SizedBox(height: 24),
              _StepTitle(step: state.currentStep),
              const SizedBox(height: 20),
              _RegistrationStep(
                state: state,
                onDraftChanged: cubit.saveRegistrationStep,
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (state.currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => cubit.goToStep(state.currentStep - 1),
                      child: const Text('Back'),
                    ),
                  ),
                if (state.currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: CustomGradientButton(
                    text: state.currentStep == 6 ? 'Submit' : 'Next',
                    isLoading: state.isSubmittingRegistration,
                    onPressed: cubit.continueRegistration,
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

class _StepTitle extends StatelessWidget {
  final int step;

  const _StepTitle({required this.step});

  @override
  Widget build(BuildContext context) {
    const titles = <String>[
      'Personal Information',
      'Address',
      'Family & Income',
      'Health Condition',
      'Financial Situation',
      'Payout Method',
      'Documents Upload',
    ];
    return Text(titles[step], style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _RegistrationStep extends StatelessWidget {
  final BeneficiaryState state;
  final ValueChanged<RegistrationDraft> onDraftChanged;

  const _RegistrationStep({required this.state, required this.onDraftChanged});

  @override
  Widget build(BuildContext context) {
    final draft = state.registrationDraft;
    switch (state.currentStep) {
      case 0:
        return Column(
          children: [
            CustomTextField(
              hintText: 'Full name',
              initialValue: draft.fullName,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(fullName: value)),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'National ID',
              initialValue: draft.nationalId,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(nationalId: value)),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date of birth'),
              subtitle: Text(
                draft.dateOfBirth == null
                    ? 'Select date'
                    : draft.dateOfBirth!.toIso8601String().split('T').first,
              ),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () => _pickDate(context, draft),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Verified phone',
              initialValue: draft.phone,
              readOnly: true,
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            CustomTextField(
              hintText: 'Address',
              initialValue: draft.address,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(address: value)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: draft.governorate.isEmpty
                  ? null
                  : draft.governorate,
              decoration: const InputDecoration(labelText: 'Governorate'),
              items: BeneficiaryOptions.governorates
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) {
                final nextGovernorate = value ?? '';
                final nextCityOptions =
                    BeneficiaryOptions.citiesByGovernorate[nextGovernorate] ??
                    const [];
                final nextCity = nextCityOptions.contains(draft.city)
                    ? draft.city
                    : '';
                onDraftChanged(
                  draft.copyWith(governorate: nextGovernorate, city: nextCity),
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: draft.city.isEmpty ? null : draft.city,
              decoration: const InputDecoration(labelText: 'City'),
              items:
                  (BeneficiaryOptions.citiesByGovernorate[draft.governorate] ??
                          const [])
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(city: value ?? '')),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            CustomTextField(
              hintText: 'Family size',
              initialValue: draft.familySize.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) => onDraftChanged(
                draft.copyWith(familySize: int.tryParse(value) ?? 1),
              ),
            ),
            const SizedBox(height: 16),
            _RadioGroup(
              title: 'Income status',
              value: draft.incomeStatus,
              values: IncomeStatusOption.all,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(incomeStatus: value)),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _RadioGroup(
              title: 'Health condition',
              value: draft.healthCondition,
              values: HealthConditionOption.all,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(healthCondition: value)),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Health details (optional)',
              initialValue: draft.healthDetails,
              maxLines: 4,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(healthDetails: value)),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            CustomTextField(
              hintText: 'Debt information',
              initialValue: draft.debtInfo,
              maxLines: 4,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(debtInfo: value)),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Monthly expenses (optional)',
              initialValue: draft.monthlyExpenses?.toString() ?? '',
              keyboardType: TextInputType.number,
              onChanged: (value) => onDraftChanged(
                draft.copyWith(monthlyExpenses: double.tryParse(value)),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: draft.hasLoans,
              title: const Text('Has active loans'),
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(hasLoans: value)),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            _RadioGroup(
              title: 'Payout method',
              value: draft.payoutMethod,
              values: PayoutMethodOption.all,
              onChanged: (value) =>
                  onDraftChanged(draft.copyWith(payoutMethod: value)),
            ),
            const SizedBox(height: 16),
            if (draft.payoutMethod == PayoutMethodOption.vodafoneCash)
              CustomTextField(
                hintText: 'Vodafone Cash number',
                initialValue: draft.payoutAccount,
                keyboardType: TextInputType.phone,
                onChanged: (value) =>
                    onDraftChanged(draft.copyWith(payoutAccount: value)),
              ),
            if (draft.payoutMethod == PayoutMethodOption.bank) ...[
              DropdownButtonFormField<String>(
                initialValue: draft.bankName.isEmpty ? null : draft.bankName,
                decoration: const InputDecoration(labelText: 'Bank name'),
                items: BeneficiaryOptions.bankNames
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) =>
                    onDraftChanged(draft.copyWith(bankName: value ?? '')),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Account number',
                initialValue: draft.accountNumber,
                onChanged: (value) =>
                    onDraftChanged(draft.copyWith(accountNumber: value)),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Account holder name',
                initialValue: draft.accountHolderName,
                onChanged: (value) =>
                    onDraftChanged(draft.copyWith(accountHolderName: value)),
              ),
            ],
          ],
        );
      default:
        return Column(
          children: RequiredDocumentType.all.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: DocumentUploadWidget(
                label: documentLabel(type),
                helperText: 'Required document type',
                isUploaded: state.uploadedDocumentsByType.containsKey(type),
                isUploading:
                    state.isUploading && state.activeUploadType == type,
                progress: state.activeUploadType == type
                    ? state.uploadProgress
                    : 0,
                onFileSelected: (file) {
                  context.read<BeneficiaryCubit>().startUpload(
                    fileName: file.fileName,
                    mimeType: file.mimeType,
                    bytes: file.bytes,
                    scope: 'beneficiary_document',
                    documentType: type,
                  );
                },
              ),
            );
          }).toList(),
        );
    }
  }

  Future<void> _pickDate(BuildContext context, RegistrationDraft draft) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialDate: draft.dateOfBirth ?? DateTime(2000),
    );
    if (selected != null && context.mounted) {
      onDraftChanged(draft.copyWith(dateOfBirth: selected));
    }
  }
}

class _RadioGroup extends StatelessWidget {
  final String title;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _RadioGroup({
    required this.title,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (item) => ChoiceChip(
                  label: Text(formatEnumLabel(item)),
                  selected: value == item,
                  onSelected: (_) => onChanged(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
