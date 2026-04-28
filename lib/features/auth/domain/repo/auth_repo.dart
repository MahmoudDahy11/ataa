import 'package:ataa/core/error/failure.dart';
import 'package:dartz/dartz.dart';

/// Abstract repository defining all authentication contracts.
/// All methods return `Either<AuthFailure, T>` for functional error handling.
abstract class AuthRepo {
  /// Sends OTP to the given phone number.
  /// Returns Right(verificationId) on success, Left(AuthFailure) on error.
  Future<Either<AuthFailure, String>> verifyPhone({required String phone});

  /// Verifies the SMS code against the verificationId.
  /// Returns Right(uid) on success, Left(AuthFailure) on error.
  Future<Either<AuthFailure, String>> verifySmsCode({
    required String verificationId,
    required String smsCode,
  });

  /// Saves the user's selected role to Firestore.
  /// Returns Right(unit) on success, Left(AuthFailure) on error.
  Future<Either<AuthFailure, Unit>> saveUserRole({
    required String uid,
    required String role,
    required String phone,
  });

  /// Gets the user's role from Firestore.
  /// Returns Right(role) or Right(null) if not found, Left on error.
  Future<Either<AuthFailure, String?>> getUserRole({required String uid});

  /// Signs the current user out.
  Future<void> signOut();

  /// Returns the current user's UID, or null if not signed in.
  String? get currentUserId;

  /// Returns the verified phone number for the signed-in user, if available.
  String? get currentUserPhone;
}
