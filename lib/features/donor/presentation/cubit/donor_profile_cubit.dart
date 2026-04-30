import 'package:ataa/features/donor/domain/usecases/get_donation_history.dart';
import 'package:ataa/features/donor/domain/usecases/get_donor_profile.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DonorProfileCubit extends Cubit<DonorProfileState> {
  final GetDonorProfile _getDonorProfile;
  final GetDonationHistory _getDonationHistory;
  final FirebaseAuth _auth;

  DonorProfileCubit({
    required GetDonorProfile getDonorProfile,
    required GetDonationHistory getDonationHistory,
    required FirebaseAuth auth,
  }) : _getDonorProfile = getDonorProfile,
       _getDonationHistory = getDonationHistory,
       _auth = auth,
       super(DonorProfileInitial());

  Future<void> loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    emit(DonorProfileLoading());

    final profileResult = await _getDonorProfile(uid);

    profileResult.fold(
      (failure) => emit(DonorProfileError(failure.errMessage)),
      (donor) async {
        final historyResult = await _getDonationHistory(uid);
        historyResult.fold(
          (failure) => emit(DonorProfileError(failure.errMessage)),
          (history) => emit(DonorProfileLoaded(donor: donor, history: history)),
        );
      },
    );
  }
}
