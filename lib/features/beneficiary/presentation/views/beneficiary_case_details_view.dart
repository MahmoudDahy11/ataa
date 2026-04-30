import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficiaryCaseDetailsView extends StatelessWidget {
  final String caseId;

  const BeneficiaryCaseDetailsView({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>()..loadCaseDetails(caseId),
      child: const _BeneficiaryCaseDetailsBody(),
    );
  }
}

class _BeneficiaryCaseDetailsBody extends StatelessWidget {
  const _BeneficiaryCaseDetailsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BeneficiaryCubit, BeneficiaryState>(
      builder: (context, state) {
        final item = state.selectedCase;
        if (item == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final progress = item.targetAmount == 0
            ? 0.0
            : (item.collectedAmount / item.targetAmount).clamp(0, 1).toDouble();
        return Scaffold(
          appBar: AppBar(title: const Text('Case Details')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(child: Text(item.title)),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.description),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: progress, minHeight: 10),
              const SizedBox(height: 8),
              Text('EGP ${item.collectedAmount} of ${item.targetAmount}'),
            ],
          ),
        );
      },
    );
  }
}
