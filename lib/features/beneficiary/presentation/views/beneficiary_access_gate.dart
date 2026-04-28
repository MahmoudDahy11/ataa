import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/router/app_router.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/widgets/custom_gradient_button.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
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
        title: 'Sign in required',
        message: 'Please sign in before opening beneficiary tools.',
        cta: 'Go to login',
        onPressed: () => context.go(AppRouter.phoneInputRoute),
      );
    }
    return FutureBuilder(
      future: authRepo.getUserRole(uid: uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final role = snapshot.data!.fold((_) => null, (value) => value);
        if (role != AppStrings.beneficiaryRole) {
          return _AccessMessage(
            title: 'Restricted route',
            message: 'This route is only available for beneficiary accounts.',
            cta: 'Choose role',
            onPressed: () => context.go(AppRouter.roleSelectionRoute),
          );
        }
        if (!requireApproved) {
          return child;
        }
        return FutureBuilder(
          future: sl<BeneficiaryRepo>().getProfile(),
          builder: (context, profileSnapshot) {
            if (!profileSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final profile = profileSnapshot.data!.fold((_) => null, (value) => value);
            if (profile?.status != BeneficiaryStatus.approved) {
              return _AccessMessage(
                title: 'Approval required',
                message:
                    'Your account must be approved before you can access this route.',
                cta: 'Go to dashboard',
                onPressed: () => context.go(AppRouter.beneficiaryDashboardRoute),
              );
            }
            return child;
          },
        );
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
