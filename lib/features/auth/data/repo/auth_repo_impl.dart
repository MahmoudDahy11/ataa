import 'dart:developer';

import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Concrete implementation of [AuthRepo].
/// Delegates to [AuthRemoteDataSource] and maps exceptions to [AuthFailure].
class AuthRepoImpl implements AuthRepo {
  final AuthRemoteDataSource _dataSource;

  AuthRepoImpl({required AuthRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Either<AuthFailure, String>> verifyPhone({
    required String phone,
  }) async {
    try {
      final verificationId = await _dataSource.verifyPhone(phone: phone);
      return Right(verificationId);
    } on FirebaseAuthException catch (e) {
      log('verifyPhone error: ${e.code}', name: 'AuthRepo');
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      log('verifyPhone unexpected: $e', name: 'AuthRepo');
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, String>> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = await _dataSource.verifySmsCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return Right(credential.user?.uid ?? '');
    } on FirebaseAuthException catch (e) {
      log('verifySmsCode error: ${e.code}', name: 'AuthRepo');
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      log('verifySmsCode unexpected: $e', name: 'AuthRepo');
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> saveUserRole({
    required String uid,
    required String role,
    required String phone,
  }) async {
    try {
      await _dataSource.saveUserRole(uid: uid, role: role, phone: phone);
      return const Right(unit);
    } catch (e) {
      log('saveUserRole error: $e', name: 'AuthRepo');
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<Either<AuthFailure, String?>> getUserRole({
    required String uid,
  }) async {
    try {
      final role = await _dataSource.getUserRole(uid: uid);
      return Right(role);
    } catch (e) {
      log('getUserRole error: $e', name: 'AuthRepo');
      return Left(AuthFailure.fromGenericError(e));
    }
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<String?> getIdToken() => _dataSource.getIdToken();

  @override
  String? get currentUserId => _dataSource.currentUserId;

  @override
  String? get currentUserPhone => _dataSource.currentUserPhone;
}
