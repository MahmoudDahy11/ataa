import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/core/router/app_router.dart';
import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:ataa/features/splash/presentation/cubit/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SplashCubit>()..checkFirstTimeLaunch(),
      child: const SplashViewBody(),
    );
  }
}

class SplashViewBody extends StatelessWidget {
  const SplashViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToOnboarding) {
          context.go(AppRouter.onboardingRoute);
          showSnakBar(
            context,
            'Welcome to Ataa! Let\'s get started with onboarding.',
          );
        } else if (state is SplashNavigateToAuth) {
          context.go(AppRouter.phoneInputRoute);
          showSnakBar(context, 'Welcome back! Please sign in to continue.');
        } else if (state is SplashNavigateToProfile) {
          context.go(AppRouter.beneficiaryProfileRoute);
          showSnakBar(context, 'Redirecting to your profile...');
        } else if (state is SplashNavigateToRegister) {
          context.go(AppRouter.beneficiaryRegisterRoute);
          showSnakBar(context, 'برجاء إكمال بيانات التسجيل...');
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.volunteer_activism_rounded,
                size: 100,
                color: AppColors.primary,
              ),
              SizedBox(height: 24),
              Text(
                'Ataa Platform',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
