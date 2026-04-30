import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/domain/usecases/get_donation_history.dart';
import 'package:ataa/features/donor/domain/usecases/get_donor_profile.dart';
import 'package:ataa/features/donor/domain/usecases/save_donor_profile.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DonorProfileCubit extends Cubit<DonorProfileState> {
  final GetDonorProfile _getDonorProfile;
  final GetDonationHistory _getDonationHistory;
  final SaveDonorProfile _saveDonorProfile;
  final FirebaseAuth _auth;

  DonorProfileCubit({
    required GetDonorProfile getDonorProfile,
    required GetDonationHistory getDonationHistory,
    required SaveDonorProfile saveDonorProfile,
    required FirebaseAuth auth,
  }) : _getDonorProfile = getDonorProfile,
       _getDonationHistory = getDonationHistory,
       _saveDonorProfile = saveDonorProfile,
       _auth = auth,
       super(DonorProfileInitial());

  DonorEntity? _currentDonor;

  Future<void> loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    emit(DonorProfileLoading());

    final profileResult = await _getDonorProfile(uid);

    profileResult.fold(
      (failure) => emit(DonorProfileError(failure.errMessage)),
      (donor) async {
        _currentDonor = donor;
        final historyResult = await _getDonationHistory(uid);
        historyResult.fold(
          (failure) => emit(DonorProfileError(failure.errMessage)),
          (history) => emit(DonorProfileLoaded(donor: donor, history: history)),
        );
      },
    );
  }

  Future<void> updateName(String newName) async {
    if (_currentDonor == null) return;

    final updated = _currentDonor!.copyWith(name: newName);
    emit(DonorProfileLoading());

    final result = await _saveDonorProfile(updated);
    result.fold((failure) => emit(DonorProfileError(failure.errMessage)), (_) {
      _currentDonor = updated;
      emit(DonorNameUpdated());
      loadProfile(); // Reload to refresh UI
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await Hive.box('app_config').put('is_registered', false);
    emit(DonorSignedOut());
  }
}
