import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/otp_verification_view.dart';
import '../../features/auth/presentation/views/phone_input_view.dart';
import '../../features/auth/presentation/views/role_selection_view.dart';
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
