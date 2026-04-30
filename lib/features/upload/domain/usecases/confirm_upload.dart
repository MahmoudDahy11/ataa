import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/upload/domain/entities/upload_file.dart';
import 'package:ataa/features/upload/domain/repositories/upload_repository.dart';
import 'package:dartz/dartz.dart';

class ConfirmUpload {
  final UploadRepository _repository;

  ConfirmUpload(this._repository);

  Future<Either<CustomFailure, DocumentEntity>> call({
    required String fileKey,
    required String type,
    required UploadFile file,
  }) {
    return _repository.confirmUpload(
      fileKey: fileKey,
      type: type,
      fileName: file.name,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
    );
  }
}
