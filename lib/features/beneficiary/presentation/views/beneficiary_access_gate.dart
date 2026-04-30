import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/error/failure.dart';
import 'package:ataa/core/router/app_router.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BeneficiaryAccessGate extends StatelessWidget {
  final Widget child;
  final bool requireApproved;

  const BeneficiaryAccessGate({
    super.key,
    required this.child,
    this.requireApproved = false,
  });

  @override
  Widget build(BuildContext context) {
    final authRepo = sl<AuthRepo>();
    final uid = authRepo.currentUserId;
    if (uid == null) {
      return _AccessMessage(
        title: 'تسجيل الدخول مطلوب',
        message: 'برجاء تسجيل الدخول أولاً للوصول إلى أدوات المحتاجين.',
        cta: 'ذهاب لتسجيل الدخول',
        onPressed: () => context.go(AppRouter.phoneInputRoute),
      );
    }
    return FutureBuilder(
      future: Future.wait([
        authRepo.getUserRole(uid: uid),
        sl<BeneficiaryRepo>().getProfile(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final results = snapshot.data as List<dynamic>;
        final role = results[0].fold((_) => null, (value) => value);
        final profileResult =
            results[1] as Either<CustomFailure, BeneficiaryEntity>;
        final profile = profileResult.fold((_) => null, (value) => value);

        // 1. Role Check
        if (role != AppStrings.beneficiaryRole) {
          return _AccessMessage(
            title: 'دخول مقيد',
            message: 'هذا المسار مخصص فقط لحسابات المحتاجين.',
            cta: 'اختار دورك',
            onPressed: () => context.go(AppRouter.roleSelectionRoute),
          );
        }

        // 2. Profile Existence Check
        final isRegistering =
            GoRouterState.of(context).matchedLocation ==
            AppRouter.beneficiaryRegisterRoute;
        final profileExists = profile != null && profile.fullName.isNotEmpty;

        if (!profileExists && !isRegistering) {
          return _AccessMessage(
            title: 'إكمال التسجيل مطلوب',
            message: 'برجاء إكمال بياناتك الشخصية أولاً للوصول إلى هذه الصفحة.',
            cta: 'اذهب للتسجيل',
            onPressed: () => context.go(AppRouter.beneficiaryRegisterRoute),
          );
        }

        if (profileExists && isRegistering) {
          // Already registered, don't show registration form again
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRouter.beneficiaryDashboardRoute);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 3. Approval Check (if required)
        if (requireApproved && profile?.status != BeneficiaryStatus.approved) {
          return _AccessMessage(
            title: 'الموافقة مطلوبة',
            message:
                'يجب مراجعة حسابك والموافقة عليه قبل الوصول إلى هذا المسار.',
            cta: 'اذهب للوحة التحكم',
            onPressed: () => context.go(AppRouter.beneficiaryDashboardRoute),
          );
        }

        return child;
      },
    );
  }
}

class _AccessMessage extends StatelessWidget {
  final String title;
  final String message;
  final String cta;
  final VoidCallback onPressed;

  const _AccessMessage({
    required this.title,
    required this.message,
    required this.cta,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              CustomGradientButton(text: cta, onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}
