import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_profile_cubit.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_setup_cubit.dart';
import 'package:ataa/features/donor/presentation/cubit/payment_method_cubit.dart';
import 'package:ataa/features/donor/presentation/screens/donor_profile_screen.dart';
import 'package:ataa/features/donor/presentation/screens/donor_setup_screen.dart';
import 'package:ataa/features/donor/presentation/screens/payment_method_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/otp_verification_view.dart';
import '../../features/auth/presentation/views/phone_input_view.dart';
import '../../features/auth/presentation/views/role_selection_view.dart';
import '../../features/beneficiary/presentation/views/beneficiary_access_gate.dart';
import '../../features/beneficiary/presentation/views/beneficiary_case_create_view.dart';
import '../../features/beneficiary/presentation/views/beneficiary_case_details_view.dart';
import '../../features/beneficiary/presentation/views/beneficiary_dashboard_view.dart';
import '../../features/beneficiary/presentation/views/beneficiary_documents_view.dart';
import '../../features/beneficiary/presentation/views/beneficiary_edit_profile_view.dart';
import '../../features/beneficiary/presentation/views/beneficiary_profile_view.dart';
import '../../features/beneficiary/presentation/views/beneficiary_register_view.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/splash/presentation/views/splash_view.dart';

class AppRouter {
  AppRouter._();

  // Route paths
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String phoneInputRoute = '/phone-input';
  static const String otpRoute = '/otp';
  static const String roleSelectionRoute = '/role-selection';
  static const String beneficiaryRegisterRoute = '/beneficiary/register';
  static const String beneficiaryDashboardRoute = '/beneficiary/dashboard';
  static const String beneficiaryProfileRoute = '/beneficiary/profile';
  static const String beneficiaryCaseCreateRoute = '/beneficiary/case/create';
  static const String beneficiaryDocumentsRoute = '/beneficiary/documents';
  static const String beneficiaryEditProfileRoute = '/beneficiary/profile/edit';

  // Donor routes
  static const String donorSetupRoute = '/donor/setup';
  static const String donorPaymentMethodRoute = '/donor/payment-method';
  static const String donorProfileRoute = '/donor/profile';

  static final router = GoRouter(
    initialLocation: splashRoute,
    routes: [
      GoRoute(
        path: splashRoute,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: onboardingRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const OnboardingView()),
      ),
      GoRoute(
        path: phoneInputRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const PhoneInputView()),
      ),
      GoRoute(
        path: otpRoute,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return _slidePage(
            state: state,
            child: OtpVerificationView(
              verificationId: extra['verificationId'] ?? '',
              phone: extra['phone'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: roleSelectionRoute,
        pageBuilder: (context, state) =>
            _slidePage(state: state, child: const RoleSelectionView()),
      ),
      GoRoute(
        path: beneficiaryRegisterRoute,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const BeneficiaryAccessGate(child: BeneficiaryRegisterView()),
        ),
      ),
      GoRoute(
        path: beneficiaryDashboardRoute,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const BeneficiaryAccessGate(child: BeneficiaryDashboardView()),
        ),
      ),
      GoRoute(
        path: beneficiaryProfileRoute,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const BeneficiaryAccessGate(child: BeneficiaryProfileView()),
        ),
      ),
      GoRoute(
        path: beneficiaryCaseCreateRoute,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const BeneficiaryAccessGate(
            requireApproved: true,
            child: BeneficiaryCaseCreateView(),
          ),
        ),
      ),
      GoRoute(
        path: '/beneficiary/case/:id',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BeneficiaryAccessGate(
            child: BeneficiaryCaseDetailsView(
              caseId: state.pathParameters['id'] ?? '',
            ),
          ),
        ),
      ),
      GoRoute(
        path: beneficiaryDocumentsRoute,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const BeneficiaryAccessGate(child: BeneficiaryDocumentsView()),
        ),
      ),
      GoRoute(
        path: beneficiaryEditProfileRoute,
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: const BeneficiaryAccessGate(
            child: BeneficiaryEditProfileView(),
          ),
        ),
      ),

      // ── Donor Routes ───────────────────────────────────────────
      GoRoute(
        path: donorSetupRoute,
        name: 'donor_setup',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<DonorSetupCubit>(),
            child: const DonorSetupScreen(),
          ),
        ),
      ),
      GoRoute(
        path: donorPaymentMethodRoute,
        name: 'payment_method',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<PaymentMethodCubit>(),
            child: const PaymentMethodScreen(),
          ),
        ),
      ),
      GoRoute(
        path: donorProfileRoute,
        name: 'donor_profile',
        pageBuilder: (context, state) => _slidePage(
          state: state,
          child: BlocProvider(
            create: (_) => sl<DonorProfileCubit>(),
            child: const DonorProfileScreen(),
          ),
        ),
      ),
    ],
  );

  static Page _slidePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeIn)),
          ),
          child: child,
        );
      },
    );
  }
}
