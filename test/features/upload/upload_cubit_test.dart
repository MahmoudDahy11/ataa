import 'dart:typed_data';

import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/upload/domain/entities/presigned_upload.dart';
import 'package:ataa/features/upload/domain/entities/upload_file.dart';
import 'package:ataa/features/upload/domain/repositories/upload_repository.dart';
import 'package:ataa/features/upload/domain/usecases/confirm_upload.dart';
import 'package:ataa/features/upload/domain/usecases/init_upload.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UploadCubit', () {
    test('rejects unsupported file type locally', () async {
      final cubit = UploadCubit(
        InitUpload(_FakeUploadRepository()),
        ConfirmUpload(_FakeUploadRepository()),
        _FakeUploadRepository(),
      )..selectFile(_file(name: 'note.txt', mimeType: 'text/plain'));

      await cubit.upload('id_card');

      expect(cubit.state.status, UploadStatus.error);
      expect(cubit.state.errorMessage, contains('غير مدعوم'));
    });

    test('uploads and confirms successfully', () async {
      final repository = _FakeUploadRepository();
      final cubit = UploadCubit(
        InitUpload(repository),
        ConfirmUpload(repository),
        repository,
      )..selectFile(_file());

      await cubit.upload('id_card');

      expect(cubit.state.status, UploadStatus.success);
      expect(cubit.state.fileKey, 'users/uid/documents/file.jpg');
      expect(cubit.state.document?.type, 'id_card');
    });

    test('keeps fileKey for confirm retry', () async {
      final repository = _FakeUploadRepository(confirmShouldFailOnce: true);
      final cubit = UploadCubit(
        InitUpload(repository),
        ConfirmUpload(repository),
        repository,
      )..selectFile(_file());

      await cubit.upload('id_card');
      expect(cubit.state.status, UploadStatus.retry);
      expect(cubit.state.retryConfirm, isTrue);

      await cubit.retry();
      expect(cubit.state.status, UploadStatus.success);
    });
  });
}

UploadFile _file({String name = 'id.jpg', String mimeType = 'image/jpeg'}) {
  return UploadFile(
    name: name,
    mimeType: mimeType,
    bytes: Uint8List.fromList(List.filled(8, 1)),
  );
}

class _FakeUploadRepository implements UploadRepository {
  _FakeUploadRepository({this.confirmShouldFailOnce = false});

  final bool confirmShouldFailOnce;
  bool _confirmFailed = false;

  @override
  Future<Either<CustomFailure, DocumentEntity>> confirmUpload({
    required String fileKey,
    required String type,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  }) async {
    if (confirmShouldFailOnce && !_confirmFailed) {
      _confirmFailed = true;
      return Left(ServerFailure(errMessage: 'UPLOAD_SESSION_EXPIRED'));
    }
    return Right(
      DocumentEntity(
        id: 'doc-1',
        ownerId: 'uid-1',
        type: type,
        displayName: 'ID',
        fileName: fileName,
        mimeType: mimeType,
        sizeBytes: sizeBytes,
        storageKey: fileKey,
        status: 'stored',
        uploadId: null,
        isDeleted: false,
        schemaVersion: 1,
        createdAt: null,
        updatedAt: null,
      ),
    );
  }

  @override
  Future<Either<CustomFailure, PresignedUpload>> initUpload({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  }) async => const Right(
    PresignedUpload(
      url: 'https://upload.test',
      fileKey: 'users/uid/documents/file.jpg',
    ),
  );

  @override
  Future<Either<CustomFailure, Unit>> uploadBytes({
    required String url,
    required List<int> bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.5);
    onProgress?.call(1);
    return const Right(unit);
  }
}
