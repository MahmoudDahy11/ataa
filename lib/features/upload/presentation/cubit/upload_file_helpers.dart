import 'package:ataa/core/env/app_env.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/upload/domain/entities/upload_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<UploadFile?> pickUploadFile() async {
  final result = await FilePicker.platform.pickFiles(
    withData: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  );
  final file = result?.files.single;
  if (file?.bytes == null) return null;
  final mimeType = mimeTypeFromExtension(file!.extension ?? '');
  final bytes = await compressUploadFile(file.path, mimeType, file.bytes!);
  return UploadFile(name: file.name, mimeType: mimeType, bytes: bytes);
}

String? validateUploadFile(UploadFile file) {
  if (!AllowedUploadTypes.all.contains(file.mimeType)) {
    return 'نوع الملف غير مدعوم';
  }
  if (file.sizeBytes > AppEnv.uploadMaxBytes) {
    return 'حجم الملف أكبر من 5 ميجابايت';
  }
  return null;
}

Future<Uint8List> compressUploadFile(
  String? path,
  String mimeType,
  Uint8List bytes,
) async {
  if (kIsWeb || path == null || !mimeType.startsWith('image/')) return bytes;
  final compressed = await FlutterImageCompress.compressWithFile(
    path,
    minWidth: 1280,
    minHeight: 1280,
    quality: 80,
  );
  return compressed == null ? bytes : Uint8List.fromList(compressed);
}

String mimeTypeFromExtension(String extension) {
  switch (extension.toLowerCase()) {
    case 'png':
      return AllowedUploadTypes.imagePng;
    case 'pdf':
      return AllowedUploadTypes.pdf;
    default:
      return AllowedUploadTypes.imageJpeg;
  }
}
