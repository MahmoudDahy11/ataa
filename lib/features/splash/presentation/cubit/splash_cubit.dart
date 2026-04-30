import 'package:ataa/features/splash/presentation/cubit/splash_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashCubit extends Cubit<SplashState> {
  final FirebaseAuth _auth;

  SplashCubit(this._auth) : super(SplashInitial());

  void checkFirstTimeLaunch() async {
    await Future.delayed(const Duration(seconds: 2));

    final box = Hive.box('app_config');
    final isRegistered = box.get('is_registered', defaultValue: false);
    final user = _auth.currentUser;

    if (user != null && isRegistered) {
      emit(SplashNavigateToProfile());
    } else {
      emit(SplashNavigateToOnboarding());
    }
  }
}
