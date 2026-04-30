import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_profile_cubit.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/donation_history_item.dart';
import '../widgets/donor_stat_card.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DonorProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DonorProfileCubit, DonorProfileState>(
        builder: (context, state) {
          if (state is DonorProfileLoading || state is DonorProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DonorProfileError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<DonorProfileCubit>().loadProfile(),
            );
          }
          if (state is DonorProfileLoaded) {
            return _ProfileContent(donor: state.donor, history: state.history);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final DonorEntity donor;
  final List<DonationHistoryEntity> history;

  const _ProfileContent({required this.donor, required this.history});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ProfileAppBar(donor: donor),
        SliverToBoxAdapter(child: _StatsSection(donor: donor)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text('سجل التبرعات', style: AppTextStyles.titleMedium),
          ),
        ),
        history.isEmpty
            ? const SliverFillRemaining(child: _EmptyHistory())
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => DonationHistoryItem(donation: history[i]),
                  childCount: history.length,
                ),
              ),
      ],
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  final DonorEntity donor;
  const _ProfileAppBar({required this.donor});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.primary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text(
                  donor.avatarInitials,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                donor.name,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final DonorEntity donor;
  const _StatsSection({required this.donor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          DonorStatCard(
            label: 'إجمالي التبرعات',
            value: '${donor.totalDonated} ج',
          ),
          const SizedBox(width: 12),
          DonorStatCard(
            label: 'عدد التبرعات',
            value: '${donor.donationsCount}',
          ),
          const SizedBox(width: 12),
          DonorStatCard(
            label: 'حالات مدعومة',
            value: '${donor.casesSupportedCount}',
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.volunteer_activism_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'لم تقم بأي تبرع بعد',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
