import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/router/app_router.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/core/widgets/custom_textfield.dart';
import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_profile_cubit.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      body: BlocConsumer<DonorProfileCubit, DonorProfileState>(
        listener: (context, state) {
          if (state is DonorNameUpdated) {
            showSnakBar(context, 'تم تحديث الاسم بنجاح');
          } else if (state is DonorSignedOut) {
            context.go(AppRouter.phoneInputRoute);
          }
        },
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
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<DonorProfileCubit>().loadProfile(),
      child: CustomScrollView(
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
      ),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text(
                  'تسجيل الخروج',
                  style: AppTextStyles.titleMedium,
                ),
                content: const Text(
                  'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                  style: AppTextStyles.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'إلغاء',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<DonorProfileCubit>().signOut();
                    },
                    child: Text(
                      'خروج',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    donor.name,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () => _showEditNameDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: donor.name);
    final cubit = context.read<DonorProfileCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('تعديل الاسم', style: AppTextStyles.titleMedium),
        content: CustomTextField(
          hintText: 'الاسم الجديد',
          controller: controller,
          prefixIcon: Icons.person_outline,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                cubit.updateName(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(
              'حفظ',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
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
