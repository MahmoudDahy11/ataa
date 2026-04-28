import 'dart:typed_data';

class SelectedUploadFile {
  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  const SelectedUploadFile({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });
}
