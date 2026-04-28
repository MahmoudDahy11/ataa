import 'dart:async';
import 'dart:developer';

import 'package:ataa/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  @override
  Future<String> verifyPhone({required String phone}) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (FirebaseAuthException e) {
        log('verifyPhone failed: ${e.code}', name: 'AuthDataSource');
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        log('OTP code sent', name: 'AuthDataSource');
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future<UserCredential> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> saveUserRole({
    required String uid,
    required String role,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String?> getUserRole({required String uid}) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['role'] as String?;
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentUserPhone => _auth.currentUser?.phoneNumber;
}
