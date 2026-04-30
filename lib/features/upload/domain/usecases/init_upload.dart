import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/upload/domain/entities/presigned_upload.dart';
import 'package:ataa/features/upload/domain/entities/upload_file.dart';
import 'package:ataa/features/upload/domain/repositories/upload_repository.dart';
import 'package:dartz/dartz.dart';

class InitUpload {
  final UploadRepository _repository;

  InitUpload(this._repository);

  Future<Either<CustomFailure, PresignedUpload>> call(UploadFile file) {
    return _repository.initUpload(
      fileName: file.name,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
    );
  }
}
