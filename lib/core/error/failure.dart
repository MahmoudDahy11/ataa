import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*
 * CustomException class
 * represents a custom exception with an error message
 */
class CustomFailure {
  final String errMessage;
  CustomFailure({required this.errMessage});
}

/*
 * ServerFailure class
 * extends CustomFailure
 * includes factory constructors to create instances from DioException and HTTP response
 */

class ServerFailure extends CustomFailure {
  ServerFailure({required super.errMessage});

  factory ServerFailure.fromDioException(
    DioException dioException, {
    String? requestStage,
  }) {
    log('---------------------------------------------------');
    log('CURRENT UID: ${FirebaseAuth.instance.currentUser?.uid}');
    log('RAW RESPONSE DATA: ${dioException.response?.data}');
    log('STATUS CODE: ${dioException.response?.statusCode}');
    log('REQUEST URL: ${dioException.requestOptions.baseUrl}');
    log('FULL PATH: ${dioException.requestOptions.path}');
    log('---------------------------------------------------');

    final url = dioException.requestOptions.uri.toString();
    final method = dioException.requestOptions.method;

    final isStorjRequest = method == 'PUT' || url.contains('storj');

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure(
          errMessage: '[$requestStage] Connection timeout with API',
        );

      case DioExceptionType.sendTimeout:
        return ServerFailure(
          errMessage: '[$requestStage] Failed to send request to API',
        );

      case DioExceptionType.receiveTimeout:
        return ServerFailure(
          errMessage: '[$requestStage] Failed to receive response from API',
        );

      case DioExceptionType.badCertificate:
        return ServerFailure(
          errMessage: '[$requestStage] Bad certificate received',
        );

      case DioExceptionType.cancel:
        return ServerFailure(
          errMessage: '[$requestStage] Request was cancelled',
        );

      case DioExceptionType.connectionError:
        return ServerFailure(
          errMessage: '[$requestStage] Internet connection failed',
        );

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final data = dioException.response?.data;

        /// 🔴 مهم: مفيش response أصلاً
        if (data == null) {
          return isStorjRequest
              ? ServerFailure(
                  errMessage:
                      '[$requestStage] Storage upload failed (no response)',
                )
              : ServerFailure(
                  errMessage: '[$requestStage] Server returned empty response',
                );
        }

        return ServerFailure.fromResponse(
          statusCode ?? 0,
          data,
          requestStage: requestStage,
        );

      case DioExceptionType.unknown:
        return ServerFailure(
          errMessage: '[$requestStage] Unexpected error occurred',
        );
    }
  }

  factory ServerFailure.fromResponse(
    int statusCode,
    dynamic responseData, {
    String? requestStage,
  }) {
    final data = _asMap(responseData);
    final code = _extractCode(data);

    /// 🔴 مهم: مفيش error code أصلاً
    if (code == null) {
      return ServerFailure(
        errMessage:
            '[$requestStage] Unexpected server response (no error code)',
      );
    }

    final message = _messageFromCode(code);

    if (statusCode == 500) {
      return ServerFailure(errMessage: '[$requestStage] Server error occurred');
    }

    return ServerFailure(errMessage: '[$requestStage] $message');
  }

  /// استخراج الكود بشكل قوي (كل الحالات)
  static String? _extractCode(Map<String, dynamic> data) {
    final error = data['error'];

    if (error is String) {
      // Try to extract from XML if present
      final codeMatch = RegExp(r'<Code>(.*?)</Code>').firstMatch(error);
      if (codeMatch != null) return codeMatch.group(1);
      return error;
    }

    if (error is Map) {
      final map = Map<String, dynamic>.from(error);
      return map['code']?.toString();
    }

    if (data['code'] is String) {
      return data['code'] as String;
    }

    return null;
  }

  /// تحويل أي response بشكل آمن
  static Map<String, dynamic> _asMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String) {
      try {
        final decoded = jsonDecode(responseData);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }

        return {'error': decoded.toString()};
      } catch (_) {
        /// 🔴 مش JSON (HTML / XML / plain text)
        return {'error': responseData};
      }
    }

    return {};
  }

  static String _messageFromCode(String? code) {
    switch (code) {
      case 'INVALID_FILE_TYPE':
        return 'نوع الملف غير مدعوم.';

      case 'FILE_TOO_LARGE':
        return 'حجم الملف أكبر من الحد المسموح.';

      case 'UNAUTHORIZED':
        return 'يجب تسجيل الدخول قبل رفع الملفات.';

      case 'UPLOAD_SESSION_NOT_FOUND':
        return 'جلسة الرفع غير موجودة.';

      case 'UPLOAD_SESSION_EXPIRED':
        return 'انتهت صلاحية جلسة الرفع. حاول مرة أخرى.';

      case 'UPLOAD_ALREADY_CONFIRMED':
        return 'تم تأكيد هذا الملف بالفعل.';

      case 'SignatureDoesNotMatch':
        return 'خطأ في التوقيع الرقمي للملف. تم إصلاح هذا المشكلة، يرجى المحاولة مرة أخرى.';

      case 'AccessDenied':
        return 'تم رفض الوصول إلى وحدة التخزين.';

      default:
        return 'خطأ غير معروف من السيرفر.';
    }
  }
}

/*
 * AuthFailure class
 * extends CustomFailure
 * includes factory constructors to handle FirebaseAuthException with specific error codes
 * maps Firebase auth errors to clear, user-friendly messages
 */
class AuthFailure extends CustomFailure {
  AuthFailure({required super.errMessage});

  factory AuthFailure.fromFirebaseAuthException(
    FirebaseAuthException authException,
  ) {
    final code = authException.code.toLowerCase().trim();

    switch (code) {
      case 'user-not-found':
        return AuthFailure(
          errMessage: 'No account found with this email. Please sign up first.',
        );
      case 'wrong-password':
        return AuthFailure(errMessage: 'Incorrect password. Please try again.');
      case 'invalid-email':
        return AuthFailure(
          errMessage: 'Invalid email address. Please check and try again.',
        );
      case 'user-disabled':
        return AuthFailure(
          errMessage:
              'This account has been disabled. Contact support for help.',
        );
      case 'too-many-requests':
        return AuthFailure(
          errMessage: 'Too many login attempts. Please try again later.',
        );
      case 'operation-not-allowed':
        return AuthFailure(
          errMessage: 'This operation is not allowed. Please contact support.',
        );
      case 'email-already-in-use':
        return AuthFailure(
          errMessage: 'Email already in use. Please use a different email.',
        );
      case 'weak-password':
        return AuthFailure(
          errMessage: 'Password is too weak. Please use a stronger password.',
        );
      case 'requires-recent-login':
        return AuthFailure(errMessage: 'Please log in again to continue.');
      case 'account-exists-with-different-credential':
        return AuthFailure(
          errMessage: 'An account already exists with this email.',
        );
      case 'invalid-credential':
        return AuthFailure(
          errMessage:
              'Invalid credentials provided. Please check and try again.',
        );
      case 'network-request-failed':
        return AuthFailure(
          errMessage: 'Network error. Please check your internet connection.',
        );
      case 'session-cookie-expired':
        return AuthFailure(errMessage: 'Session expired. Please log in again.');
      case 'uid-already-exists':
        return AuthFailure(
          errMessage: 'User ID already exists. Please try again.',
        );
      default:
        return AuthFailure(
          errMessage:
              'Authentication failed. ${authException.message ?? 'Please try again.'}',
        );
    }
  }

  factory AuthFailure.fromGenericError(dynamic error) {
    return AuthFailure(
      errMessage: error.toString().isNotEmpty
          ? error.toString()
          : 'Authentication error occurred. Please try again.',
    );
  }
}
