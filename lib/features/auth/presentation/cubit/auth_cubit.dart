import 'dart:developer';

import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Handles all authentication logic through [AuthRepo].
/// Uses dartz Either for functional error handling.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit({required AuthRepo authRepo})
    : _authRepo = authRepo,
      super(AuthInitial());

  String _currentPhone = '';
  String _verificationId = '';

  /// Sends OTP to the given phone number.
  Future<void> submitPhone(String phone) async {
    emit(AuthLoading());

    final result = await _authRepo.verifyPhone(phone: phone);

    result.fold((failure) => emit(AuthError(failure.errMessage)), (
      verificationId,
    ) {
      _currentPhone = phone;
      _verificationId = verificationId;
      log('Code sent for $phone', name: 'AuthCubit');
      emit(AuthCodeSent(verificationId: _verificationId, phone: _currentPhone));
    });
  }

  /// Verifies the OTP code entered by the user.
  Future<void> verifyOTP(String otp) async {
    emit(AuthLoading());

    final result = await _authRepo.verifySmsCode(
      verificationId: _verificationId,
      smsCode: otp,
    );

    await result.fold((failure) async => emit(AuthError(failure.errMessage)), (
      uid,
    ) async {
      log('OTP verified, uid=$uid', name: 'AuthCubit');
      // Check if user already has a role
      final roleResult = await _authRepo.getUserRole(uid: uid);
      roleResult.fold((failure) => emit(AuthOTPVerified(uid: uid)), (role) {
        if (role != null) {
          emit(AuthRoleSelected(role));
        } else {
          emit(AuthOTPVerified(uid: uid));
        }
      });
    });
  }

  /// Resends the OTP code to the current phone number.
  Future<void> resendCode() async {
    if (_currentPhone.isEmpty) return;
    await submitPhone(_currentPhone);
  }

  /// Saves the selected role to Firestore.
  Future<void> selectRole(String role) async {
    emit(AuthLoading());

    final uid = _authRepo.currentUserId;
    if (uid == null) {
      emit(AuthError('User session expired. Please login again.'));
      return;
    }

    final result = await _authRepo.saveUserRole(
      uid: uid,
      role: role,
      phone: _currentPhone,
    );

    result.fold((failure) => emit(AuthError(failure.errMessage)), (_) {
      log('Role "$role" saved for $uid', name: 'AuthCubit');
      emit(AuthRoleSelected(role));
    });
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _authRepo.signOut();
    emit(AuthSignedOut());
  }
}
