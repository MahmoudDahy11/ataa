import 'package:ataa/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  void completeOnboarding() async {
    final box = Hive.box('app_config');
    await box.put('is_first_time', false);
    emit(OnboardingCompleted());
  }
}
