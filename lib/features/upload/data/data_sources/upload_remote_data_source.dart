import 'package:ataa/features/beneficiary/data/models/document_model.dart';
import 'package:ataa/features/upload/data/models/confirm_upload_request.dart';
import 'package:ataa/features/upload/data/models/presigned_upload_model.dart';

abstract class UploadRemoteDataSource {
  Future<PresignedUploadModel> initUpload({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
  });

  Future<void> uploadBytes({
    required String url,
    required List<int> bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  });

  Future<DocumentModel> confirmUpload(ConfirmUploadRequest request);
}
