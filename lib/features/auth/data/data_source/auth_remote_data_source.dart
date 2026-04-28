import 'package:firebase_auth/firebase_auth.dart';

/// Abstract data source defining raw Firebase Auth operations.
abstract class AuthRemoteDataSource {
  /// Sends OTP and returns the verificationId.
  Future<String> verifyPhone({required String phone});

  /// Verifies the SMS code and returns the UserCredential.
  Future<UserCredential> verifySmsCode({
    required String verificationId,
    required String smsCode,
  });

  /// Saves user role to Firestore.
  Future<void> saveUserRole({
    required String uid,
    required String role,
    required String phone,
  });

  /// Gets user role from Firestore. Returns null if not found.
  Future<String?> getUserRole({required String uid});

  /// Signs out the current user.
  Future<void> signOut();

  /// Returns the current user's UID, or null.
  String? get currentUserId;

  /// Returns the current user's verified phone number, or null.
  String? get currentUserPhone;
}
