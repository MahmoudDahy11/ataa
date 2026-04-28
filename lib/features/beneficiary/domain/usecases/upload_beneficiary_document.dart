import 'dart:typed_data';

import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/domain/entities/upload_entities.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:dartz/dartz.dart';

class UploadBeneficiaryDocument {
  final BeneficiaryRepo _repo;

  UploadBeneficiaryDocument(this._repo);

  Future<Either<CustomFailure, DocumentEntity>> call({
    required UploadRequest request,
    required Uint8List bytes,
    required String ownerId,
    required String type,
    void Function(double progress)? onProgress,
  }) async {
    final sessionResult = await _repo.initUpload(request: request);
    if (sessionResult.isLeft()) {
      return sessionResult.fold(Left.new, (_) => throw StateError('Unreachable'));
    }
    final session = sessionResult.getOrElse(
      () => throw StateError('Upload session initialization failed'),
    );
    return _repo.retryUpload(
      uploadId: session.uploadId,
      ownerId: ownerId,
      type: type,
      bytes: bytes,
      mimeType: request.mimeType,
      onProgress: onProgress,
    );
  }
}
