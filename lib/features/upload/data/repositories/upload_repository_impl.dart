import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/upload/data/data_sources/upload_remote_data_source.dart';
import 'package:ataa/features/upload/data/models/confirm_upload_request.dart';
import 'package:ataa/features/upload/domain/entities/presigned_upload.dart';
import 'package:ataa/features/upload/domain/repositories/upload_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class UploadRepositoryImpl implements UploadRepository {
  final UploadRemoteDataSource _remoteDataSource;

  UploadRepositoryImpl({required UploadRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<CustomFailure, PresignedUpload>> initUpload({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    try {
      return Right(
        await _remoteDataSource.initUpload(
          fileName: fileName,
          mimeType: mimeType,
          sizeBytes: sizeBytes,
        ),
      );
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error, requestStage: 'init'));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, Unit>> uploadBytes({
    required String url,
    required List<int> bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    try {
      await _remoteDataSource.uploadBytes(
        url: url,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: onProgress,
      );
      return const Right(unit);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioException(error, requestStage: 'put'));
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }

  @override
  Future<Either<CustomFailure, DocumentEntity>> confirmUpload({
    required String fileKey,
    required String type,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    try {
      return Right(
        await _remoteDataSource.confirmUpload(
          ConfirmUploadRequest(
            fileKey: fileKey,
            type: type,
            fileName: fileName,
            mimeType: mimeType,
            sizeBytes: sizeBytes,
          ),
        ),
      );
    } on DioException catch (error) {
      return Left(
        ServerFailure.fromDioException(error, requestStage: 'confirm'),
      );
    } catch (error) {
      return Left(AuthFailure.fromGenericError(error));
    }
  }
}
