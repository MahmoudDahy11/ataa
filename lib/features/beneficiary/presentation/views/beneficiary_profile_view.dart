import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/router/app_router.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/beneficiary_display_utils.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/profile_completion_card.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/profile_header.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/profile_info_card.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/profile_skeleton.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/profile_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context),
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
          if (profile == null) return _buildEmptyState(context);

          return RefreshIndicator(
            onRefresh: () => context.read<BeneficiaryCubit>().loadProfile(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                ProfileHeader(profile: profile),
                const SizedBox(height: 24),
                ProfileStatusCard(status: profile.status),
                const SizedBox(height: 20),
                const ProfileCompletionCard(percentage: 0.85),
                const SizedBox(height: 20),
                _buildPersonalInfo(profile),
                const SizedBox(height: 16),
                _buildFinancialInfo(profile),
                const SizedBox(height: 16),
                _buildDocumentsInfo(state),
                const SizedBox(height: 32),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildPersonalInfo(dynamic p) {
    return ProfileInfoCard(
      title: 'المعلومات الشخصية',
      icon: Icons.person_outline,
      children: [
        ProfileInfoRow(
          label: 'الرقم القومي',
          value: maskNationalId(p.nationalId),
        ),
        ProfileInfoRow(label: 'رقم الهاتف', value: p.phone),
        ProfileInfoRow(label: 'المدينة', value: p.city),
        ProfileInfoRow(label: 'المحافظة', value: p.governorate),
      ],
    );
  }

  Widget _buildFinancialInfo(dynamic p) {
    return ProfileInfoCard(
      title: 'الحالة المادية',
      icon: Icons.account_balance_wallet_outlined,
      children: [
        ProfileInfoRow(
          label: 'الدخل الشهري',
          value: formatEnumLabel(p.incomeStatus),
        ),
        ProfileInfoRow(
          label: 'طريقة الاستلام',
          value: formatEnumLabel(p.payoutMethod),
        ),
        ProfileInfoRow(
          label: 'رقم فودافون كاش',
          value: (p.payoutAccount != null && p.payoutAccount!.isNotEmpty) ? p.payoutAccount! : p.phone,
          valueColor: AppColors.primary,
        ),
        ProfileInfoRow(
          label: 'قيمة المصاريف',
          value: '${p.monthlyExpenses ?? 0} ج.م',
        ),
      ],
    );
  }

  Widget _buildDocumentsInfo(BeneficiaryState state) {
    return ProfileInfoCard(
      title: 'المستندات المرفوعة',
      icon: Icons.description_outlined,
      children: RequiredDocumentType.all.map((type) {
        final isUploaded = state.uploadedDocumentsByType.containsKey(type);
        return ProfileInfoRow(
          label: RequiredDocumentType.labels[type] ?? type,
          value: isUploaded ? 'مكتمل' : 'مطلوب',
          valueColor: isUploaded ? Colors.green : Colors.orange,
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'تاريخ التحديث: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        style: const TextStyle(color: AppColors.textHint, fontSize: 12),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              title: const Text('تعديل الملف الشخصي'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRouter.beneficiaryEditProfileRoute);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () async {
                await sl<AuthRepo>().signOut();
                await Hive.box('app_config').put('is_registered', false);
                if (context.mounted) context.go(AppRouter.onboardingRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}
