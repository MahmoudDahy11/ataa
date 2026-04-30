import 'dart:convert';

import 'package:ataa/core/api/api_service.dart';
import 'package:ataa/core/env/app_env.dart';
import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/data/models/document_model.dart';
import 'package:ataa/features/upload/data/data_sources/upload_remote_data_source.dart';
import 'package:ataa/features/upload/data/models/confirm_upload_request.dart';
import 'package:ataa/features/upload/data/models/presigned_upload_model.dart';

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  final ApiService _apiService;

  UploadRemoteDataSourceImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<PresignedUploadModel> initUpload({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    final response = await _apiService.postJson(
      url: '${AppEnv.uploadBaseUrl}/upload/init',
      body: {
        'fileName': fileName,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
      },
    );
    return PresignedUploadModel.fromJson(_asMap(response.data));
  }

  @override
  Future<void> uploadBytes({
    required String url,
    required List<int> bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    await _apiService.putBytes(
      url: url,
      bytes: bytes,
      mimeType: mimeType,
      onProgress: onProgress,
    );
  }

  @override
  Future<DocumentModel> confirmUpload(ConfirmUploadRequest request) async {
    final response = await _apiService.postJson(
      url: '${AppEnv.uploadBaseUrl}/upload/confirm',
      body: request.toJson(),
    );
    return DocumentModel.fromJson(_asMap(response.data));
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        throw ServerFailure(errMessage: data);
      }
      throw ServerFailure(errMessage: 'Invalid JSON response from upload API.');
    }
    throw ServerFailure(
      errMessage: 'Unexpected response from upload API: ${data.runtimeType}',
    );
  }
}
