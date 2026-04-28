import 'package:flutter/material.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// OTP code has been sent, holds the verificationId for later use.
class AuthCodeSent extends AuthState {
  final String verificationId;
  final String phone;
  AuthCodeSent({required this.verificationId, required this.phone});
}

/// OTP verified successfully, user is authenticated.
class AuthOTPVerified extends AuthState {
  final String uid;
  AuthOTPVerified({required this.uid});
}

/// User already has a role assigned — skip role selection.
class AuthRoleSelected extends AuthState {
  final String role;
  AuthRoleSelected(this.role);
}

/// Authentication error occurred.
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// User signed out.
class AuthSignedOut extends AuthState {}
