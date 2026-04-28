import 'package:ataa/features/splash/presentation/cubit/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void checkFirstTimeLaunch() async {
    await Future.delayed(const Duration(seconds: 2));
    final box = Hive.box('app_config');
    final isFirstTime = box.get('is_first_time', defaultValue: true);

    if (isFirstTime) {
      emit(SplashNavigateToOnboarding());
    } else {
      emit(SplashNavigateToAuth());
    }
  }
}
