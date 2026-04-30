import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/upload/domain/entities/upload_file.dart';

enum UploadStatus { idle, loading, progress, success, error, retry }

class UploadState {
  final UploadStatus status;
  final UploadFile? file;
  final double progress;
  final String? errorMessage;
  final String? pendingType;
  final String? fileKey;
  final bool retryConfirm;
  final DocumentEntity? document;

  const UploadState({
    this.status = UploadStatus.idle,
    this.file,
    this.progress = 0,
    this.errorMessage,
    this.pendingType,
    this.fileKey,
    this.retryConfirm = false,
    this.document,
  });

  UploadState copyWith({
    UploadStatus? status,
    UploadFile? file,
    double? progress,
    String? errorMessage,
    String? pendingType,
    String? fileKey,
    bool? retryConfirm,
    DocumentEntity? document,
    bool clearError = false,
    bool clearFileKey = false,
    bool clearDocument = false,
  }) {
    return UploadState(
      status: status ?? this.status,
      file: file ?? this.file,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingType: pendingType ?? this.pendingType,
      fileKey: clearFileKey ? null : fileKey ?? this.fileKey,
      retryConfirm: retryConfirm ?? this.retryConfirm,
      document: clearDocument ? null : document ?? this.document,
    );
  }
}
