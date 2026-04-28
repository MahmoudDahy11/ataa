import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/case_card.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/restriction_banner.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BeneficiaryDashboardView extends StatelessWidget {
  const BeneficiaryDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>()..loadProfile()..loadDashboard(),
      child: const _BeneficiaryDashboardBody(),
    );
  }
}

class _BeneficiaryDashboardBody extends StatelessWidget {
  const _BeneficiaryDashboardBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          showSnakBar(context, state.errorMessage!, isError: true);
        }
      },
      builder: (context, state) {
        final cubit = context.read<BeneficiaryCubit>();
        final profile = state.profile;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Beneficiary Dashboard'),
            actions: [
              IconButton(
                onPressed: () => context.push('/beneficiary/profile'),
                icon: const Icon(Icons.person_outline_rounded),
              ),
              IconButton(
                onPressed: () => context.push('/beneficiary/documents'),
                icon: const Icon(Icons.folder_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: cubit.canCreateCase()
                ? () => context.push('/beneficiary/case/create')
                : null,
            label: const Text('New case'),
            icon: const Icon(Icons.add_rounded),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await cubit.loadProfile();
              await cubit.loadDashboard();
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (profile != null) ...[
                  StatusBadge(label: profile.status),
                  const SizedBox(height: 12),
                  Text(profile.fullName, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (profile.status != BeneficiaryStatus.approved) ...[
                    const RestrictionBanner(
                      message: 'Account under review. Case creation stays disabled until approval.',
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    cubit.canCreateCase()
                        ? 'Your account is approved. You can save drafts and submit cases.'
                        : 'Approval is still required before you can create cases.',
                  ),
                  const SizedBox(height: 24),
                ],
                ...state.ownedCases.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CaseCard(
                      item: item,
                      onTap: () => context.push('/beneficiary/case/${item.id}'),
                    ),
                  );
                }),
                if (state.ownedCases.isEmpty && !state.isLoading)
                  const Text('No cases yet. Start by creating your first draft.'),
                if (state.hasMoreCases)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CustomGradientButton(
                      text: 'Load more',
                      onPressed: () => cubit.loadDashboard(startAfter: state.lastCaseCursor),
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
