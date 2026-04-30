import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/domain/usecases/save_donor_profile.dart';
import 'package:ataa/features/donor/presentation/cubit/donor_setup_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DonorSetupCubit extends Cubit<DonorSetupState> {
  final SaveDonorProfile _saveDonorProfile;
  final FirebaseAuth _auth;

  // ValueNotifiers for local UI state
  final nameController = TextEditingController();
  final ValueNotifier<String> initialsNotifier = ValueNotifier('');
  final ValueNotifier<bool> isButtonEnabledNotifier = ValueNotifier(false);

  DonorSetupCubit({
    required SaveDonorProfile saveDonorProfile,
    required FirebaseAuth auth,
  }) : _saveDonorProfile = saveDonorProfile,
       _auth = auth,
       super(DonorSetupInitial()) {
    nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final trimmed = nameController.text.trim();
    initialsNotifier.value = _generateInitials(trimmed);
    isButtonEnabledNotifier.value = trimmed.length >= 2;
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    emit(DonorSetupLoading());

    final donor = DonorEntity(
      uid: user.uid,
      name: nameController.text.trim(),
      phoneNumber: user.phoneNumber ?? '',
      createdAt: DateTime.now(),
    );

    final result = await _saveDonorProfile(donor);
    result.fold(
      (failure) => emit(DonorSetupError(failure.errMessage)),
      (_) => emit(DonorSetupSuccess()),
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    initialsNotifier.dispose();
    isButtonEnabledNotifier.dispose();
    return super.close();
  }
}
