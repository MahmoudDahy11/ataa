import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/splash/presentation/cubit/splash_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashCubit extends Cubit<SplashState> {
  final FirebaseAuth _auth;
  final AuthRepo _authRepo;

  SplashCubit(this._auth, this._authRepo) : super(SplashInitial());

  void checkFirstTimeLaunch() async {
    await Future.delayed(const Duration(seconds: 2));

    final box = Hive.box('app_config');
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await user.reload();
        final currentUser = _auth.currentUser;

        if (currentUser == null) {
          throw 'User no longer exists';
        }

        // If authenticated but not registered locally, check if they have a role
        final isRegistered = box.get('is_registered', defaultValue: false);
        final roleResult = await _authRepo.getUserRole(uid: currentUser.uid);
        final role = roleResult.fold((_) => null, (r) => r);

        if (isRegistered) {
          // User completed setup — go to their profile
          if (role == AppStrings.donorRole) {
            emit(SplashNavigateHome()); // Donor profile
          } else {
            emit(SplashNavigateToProfile()); // Beneficiary profile
          }
          return;
        }

        if (role == null) {
          emit(SplashNavigateToOnboarding()); // Go pick a role
        } else if (role == AppStrings.beneficiaryRole) {
          emit(SplashNavigateToRegister()); // Go complete registration
        } else if (role == AppStrings.donorRole) {
          emit(SplashNavigateToDonorSetup()); // Donor needs setup
        } else {
          emit(SplashNavigateHome());
        }
      } catch (e) {
        await _auth.signOut();
        await box.put('is_registered', false);
        final isFirstTime = box.get('is_first_time', defaultValue: true);
        if (isFirstTime) {
          emit(SplashNavigateToOnboarding());
        } else {
          emit(SplashNavigateToAuth());
        }
      }
    } else {
      final isFirstTime = box.get('is_first_time', defaultValue: true);
      if (isFirstTime) {
        emit(SplashNavigateToOnboarding());
      } else {
        emit(SplashNavigateToAuth());
      }
    }
  }
}
