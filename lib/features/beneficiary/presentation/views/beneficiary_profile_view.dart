import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/beneficiary_display_utils.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/profile_skeleton.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficiaryProfileView extends StatelessWidget {
  const BeneficiaryProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>()..loadProfile(),
      child: const _BeneficiaryProfileBody(),
    );
  }
}

class _BeneficiaryProfileBody extends StatelessWidget {
  const _BeneficiaryProfileBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Settings logic
            },
          ),
        ],
      ),
      body: BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            showSnakBar(context, state.errorMessage!, isError: true);
          }
        },
        builder: (context, state) {
          final profile = state.profile;
          if (state.isLoading && profile == null) {
            return const ProfileSkeleton();
          }

          if (profile == null) {
            return RefreshIndicator(
              onRefresh: () => context.read<BeneficiaryCubit>().loadProfile(),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text('لا توجد بيانات حالياً')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<BeneficiaryCubit>().loadProfile(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Header Section
                _ProfileHeader(profile: profile),
                const SizedBox(height: 24),

                // 2. Application Status Card
                _StatusCard(status: profile.status),
                const SizedBox(height: 20),

                // 3. Profile Completion (Mocked)
                const _CompletionCard(percentage: 0.85),
                const SizedBox(height: 20),

                // 4. Personal Info Card
                _InfoCard(
                  title: 'المعلومات الشخصية',
                  icon: Icons.person_outline,
                  children: [
                    _InfoRow(label: 'الرقم القومي', value: maskNationalId(profile.nationalId)),
                    _InfoRow(label: 'رقم الهاتف', value: profile.phone),
                    _InfoRow(label: 'المدينة', value: profile.city),
                    _InfoRow(label: 'المحافظة', value: profile.governorate),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Financial Info Card
                _InfoCard(
                  title: 'الحالة المادية',
                  icon: Icons.account_balance_wallet_outlined,
                  children: [
                    _InfoRow(label: 'الدخل الشهري', value: formatEnumLabel(profile.incomeStatus)),
                    _InfoRow(
                      label: 'طريقة الاستلام',
                      value: formatEnumLabel(profile.payoutMethod),
                    ),
                    _InfoRow(label: 'قيمة المصاريف', value: '${profile.monthlyExpenses ?? 0} ج.م'),
                  ],
                ),
                const SizedBox(height: 16),

                // 6. Documents Card
                _InfoCard(
                  title: 'المستندات المرفوعة',
                  icon: Icons.description_outlined,
                  children: RequiredDocumentType.all.map((type) {
                    final doc = state.uploadedDocumentsByType[type];
                    final isUploaded = doc != null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            isUploaded ? Icons.check_circle : Icons.error_outline,
                            color: isUploaded ? Colors.green : Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(RequiredDocumentType.labels[type] ?? type),
                          const Spacer(),
                          Text(
                            isUploaded ? 'مكتمل' : 'مطلوب',
                            style: TextStyle(
                              color: isUploaded ? AppColors.textSecondary : Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Last Updated
                Center(
                  child: Text(
                    'آخر تحديث: ${DateTime.now().hour}:${DateTime.now().minute}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.gold.withValues(alpha: 0.5)],
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  profile.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 20, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        StatusBadge(status: profile.status),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final explanation = BeneficiaryStatus.explanations[status] ?? 'جاري مراجعة طلبك.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('حالة الطلب', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final double percentage;
  const _CompletionCard({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'اكتمال الملف',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
