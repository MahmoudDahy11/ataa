import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/upload/domain/entities/upload_file.dart';

sealed class UploadState {
  final UploadFile? file;
  final String? pendingType;
  const UploadState({this.file, this.pendingType});
}

class UploadInitial extends UploadState {
  const UploadInitial({super.file});
}

class UploadLoading extends UploadState {
  const UploadLoading({super.file, super.pendingType});
}

class UploadInProgress extends UploadState {
  final double progress;
  const UploadInProgress({
    super.file,
    super.pendingType,
    required this.progress,
  });
}

class UploadSuccess extends UploadState {
  final String fileKey;
  final DocumentEntity document;
  const UploadSuccess({
    super.file,
    super.pendingType,
    required this.fileKey,
    required this.document,
  });
}

class UploadFailure extends UploadState {
  final String message;
  final String? fileKey;
  final bool canRetryConfirm;

  const UploadFailure({
    super.file,
    super.pendingType,
    required this.message,
    this.fileKey,
    this.canRetryConfirm = false,
  });
}
