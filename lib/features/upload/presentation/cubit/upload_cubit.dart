import 'package:ataa/features/upload/domain/entities/upload_file.dart';
import 'package:ataa/features/upload/domain/repositories/upload_repository.dart';
import 'package:ataa/features/upload/domain/usecases/confirm_upload.dart';
import 'package:ataa/features/upload/domain/usecases/init_upload.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_file_helpers.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadCubit extends Cubit<UploadState> {
  final InitUpload _initUpload;
  final ConfirmUpload _confirmUpload;
  final UploadRepository _repository;

  UploadCubit(this._initUpload, this._confirmUpload, this._repository)
    : super(const UploadInitial());

  Future<void> pickFile() async {
    final file = await pickUploadFile();
    if (file != null) emit(UploadInitial(file: file));
  }

  void selectFile(UploadFile file) => emit(UploadInitial(file: file));

  Future<void> upload(String type) async {
    final file = state.file;
    if (file == null) return _fail('اختر ملفًا أولًا', type: type);
    final error = validateUploadFile(file);
    if (error != null) return _fail(error, type: type);

    emit(UploadLoading(file: file, pendingType: type));

    final initResult = await _initUpload(file);
    await initResult.fold(
      (failure) async => _fail(failure.errMessage, type: type),
      (upload) async {
        final sent = await _repository.uploadBytes(
          url: upload.url,
          bytes: file.bytes,
          mimeType: file.mimeType,
          onProgress: (p) => emit(
            UploadInProgress(file: file, pendingType: type, progress: p),
          ),
        );
        await sent.fold(
          (f) async => _fail(f.errMessage, type: type),
          (_) => _confirm(type: type, file: file, fileKey: upload.fileKey),
        );
      },
    );
  }

  Future<void> retry() async {
    final s = state;
    if (s is! UploadFailure || s.pendingType == null || s.file == null) return;
    if (s.canRetryConfirm && s.fileKey != null) {
      return _confirm(type: s.pendingType!, file: s.file!, fileKey: s.fileKey!);
    }
    await upload(s.pendingType!);
  }

  Future<void> _confirm({
    required String type,
    required UploadFile file,
    required String fileKey,
  }) async {
    final result = await _confirmUpload(
      fileKey: fileKey,
      type: type,
      file: file,
    );
    result.fold(
      (f) => _fail(f.errMessage, type: type, fileKey: fileKey, canRetry: true),
      (doc) => emit(
        UploadSuccess(
          file: file,
          pendingType: type,
          fileKey: fileKey,
          document: doc,
        ),
      ),
    );
  }

  void _fail(
    String msg, {
    required String type,
    String? fileKey,
    bool canRetry = false,
  }) {
    emit(
      UploadFailure(
        file: state.file,
        pendingType: type,
        message: msg,
        fileKey: fileKey,
        canRetryConfirm: canRetry,
      ),
    );
  }
}
