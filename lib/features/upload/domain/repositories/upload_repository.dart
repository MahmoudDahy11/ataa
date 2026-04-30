import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/upload/domain/entities/presigned_upload.dart';
import 'package:dartz/dartz.dart';

abstract class UploadRepository {
  Future<Either<CustomFailure, PresignedUpload>> initUpload({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  });

  Future<Either<CustomFailure, Unit>> uploadBytes({
    required String url,
    required List<int> bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  });

  Future<Either<CustomFailure, DocumentEntity>> confirmUpload({
    required String fileKey,
    required String type,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  });
}
