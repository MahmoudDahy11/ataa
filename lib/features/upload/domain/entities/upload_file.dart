import 'dart:typed_data';

class UploadFile {
  final String name;
  final String mimeType;
  final Uint8List bytes;

  const UploadFile({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });

  int get sizeBytes => bytes.length;
  bool get isImage => mimeType.startsWith('image/');
  bool get isPdf => mimeType == 'application/pdf';
}
