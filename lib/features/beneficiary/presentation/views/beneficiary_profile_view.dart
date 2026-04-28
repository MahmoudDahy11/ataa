import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/beneficiary_display_utils.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/restriction_banner.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficiaryProfileView extends StatelessWidget {
  const BeneficiaryProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>()..loadProfile()..loadDashboard(),
      child: const _BeneficiaryProfileBody(),
    );
  }
}

class _BeneficiaryProfileBody extends StatelessWidget {
  const _BeneficiaryProfileBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          showSnakBar(context, state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final age = calculateAge(profile.dateOfBirth);
        final payoutValue = profile.payoutMethod == PayoutMethodOption.bank
            ? '${profile.bankName ?? '-'} • ${maskPayoutValue(profile.accountNumber ?? '')}'
            : maskPayoutValue(profile.payoutAccount ?? '');
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      profile.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  StatusBadge(label: profile.status),
                ],
              ),
              if (profile.status != BeneficiaryStatus.approved) ...[
                const SizedBox(height: 16),
                const RestrictionBanner(
                  message: 'Account under review. Sensitive actions stay disabled until approval.',
                ),
              ],
              const SizedBox(height: 24),
              _Section(
                title: 'Personal Info',
                children: [
                  _InfoTile(label: 'National ID', value: maskNationalId(profile.nationalId)),
                  _InfoTile(label: 'Phone', value: maskPhone(profile.phone)),
                  _InfoTile(
                    label: 'Date of birth',
                    value: profile.dateOfBirth == null
                        ? '-'
                        : profile.dateOfBirth!.toIso8601String().split('T').first,
                  ),
                  _InfoTile(label: 'Age', value: age?.toString() ?? '-'),
                ],
              ),
              _Section(
                title: 'Family & Income',
                children: [
                  _InfoTile(label: 'Family size', value: profile.familySize.toString()),
                  _InfoTile(
                    label: 'Income status',
                    value: formatEnumLabel(profile.incomeStatus),
                  ),
                ],
              ),
              _Section(
                title: 'Health',
                children: [
                  _InfoTile(
                    label: 'Condition',
                    value: formatEnumLabel(profile.healthCondition),
                  ),
                  if (profile.healthDetails.trim().isNotEmpty)
                    _InfoTile(label: 'Details', value: profile.healthDetails),
                ],
              ),
              _Section(
                title: 'Financial',
                children: [
                  _InfoTile(label: 'Debt info', value: profile.debtInfo),
                  _InfoTile(
                    label: 'Monthly expenses',
                    value: profile.monthlyExpenses?.toStringAsFixed(0) ?? '-',
                  ),
                  _InfoTile(
                    label: 'Has loans',
                    value: profile.hasLoans ? 'Yes' : 'No',
                  ),
                  _InfoTile(
                    label: 'Payout method',
                    value: formatEnumLabel(profile.payoutMethod),
                  ),
                  _InfoTile(label: 'Payout details', value: payoutValue),
                ],
              ),
              _Section(
                title: 'Documents',
                children: RequiredDocumentType.all.map((type) {
                  final doc = state.uploadedDocumentsByType[type];
                  return _InfoTile(
                    label: documentLabel(type),
                    value: doc == null ? 'Missing' : doc.status,
                  );
                }).toList(),
              ),
              _Section(
                title: 'Cases Summary',
                children: [
                  _InfoTile(label: 'Total cases', value: state.totalCases.toString()),
                  _InfoTile(label: 'Active cases', value: state.activeCases.toString()),
                  _InfoTile(
                    label: 'Completed cases',
                    value: state.completedCases.toString(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label)),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
