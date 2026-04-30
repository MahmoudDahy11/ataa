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
    : super(const UploadState());

  Future<void> pickFile() async {
    final file = await pickUploadFile();
    if (file != null) selectFile(file);
  }

  void selectFile(UploadFile file) {
    emit(UploadState(file: file));
  }

  Future<void> upload(String type) async {
    final file = state.file;
    final error = file == null ? 'اختر ملفًا أولًا' : validateUploadFile(file);
    if (error != null || file == null) return _fail(error!, type: type);
    emit(
      state.copyWith(
        status: UploadStatus.loading,
        progress: 0,
        pendingType: type,
        clearError: true,
        clearFileKey: true,
        clearDocument: true,
      ),
    );
    final initResult = await _initUpload(file);
    await initResult.fold(
      (failure) async => _fail(failure.errMessage, type: type),
      (upload) async {
        final sent = await _repository.uploadBytes(
          url: upload.url,
          bytes: file.bytes,
          mimeType: file.mimeType,
          onProgress: (progress) => emit(
            state.copyWith(status: UploadStatus.progress, progress: progress),
          ),
        );
        await sent.fold(
          (failure) async => _fail(failure.errMessage, type: type),
          (_) => _confirm(type: type, file: file, fileKey: upload.fileKey),
        );
      },
    );
  }

  Future<void> retry() async {
    final type = state.pendingType;
    final file = state.file;
    if (type == null || file == null) {
      return;
    }
    if (state.retryConfirm && state.fileKey != null) {
      return _confirm(type: type, file: file, fileKey: state.fileKey!);
    }
    await upload(type);
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
      (failure) => _fail(
        failure.errMessage,
        type: type,
        fileKey: fileKey,
        retryConfirm: true,
      ),
      (document) => emit(
        state.copyWith(
          status: UploadStatus.success,
          progress: 1,
          fileKey: fileKey,
          pendingType: type,
          retryConfirm: false,
          document: document,
          clearError: true,
        ),
      ),
    );
  }

  void _fail(
    String message, {
    required String type,
    String? fileKey,
    bool retryConfirm = false,
  }) {
    emit(
      state.copyWith(
        status: retryConfirm ? UploadStatus.retry : UploadStatus.error,
        errorMessage: message,
        pendingType: type,
        fileKey: fileKey,
        retryConfirm: retryConfirm,
      ),
    );
  }
}
