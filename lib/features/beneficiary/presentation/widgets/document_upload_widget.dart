import 'dart:typed_data';

import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/selected_upload_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class DocumentUploadWidget extends StatelessWidget {
  final bool isUploading;
  final double progress;
  final ValueChanged<SelectedUploadFile> onFileSelected;
  final String label;
  final String helperText;
  final bool isUploaded;

  const DocumentUploadWidget({
    super.key,
    required this.isUploading,
    required this.progress,
    required this.onFileSelected,
    this.label = 'Upload document',
    this.helperText = '',
    this.isUploaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleLarge),
        if (helperText.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(helperText, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: isUploading ? null : () => _pickFile(),
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(isUploaded ? 'Replace file' : 'Select file'),
        ),
        if (isUploading) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% uploaded',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) {
      return;
    }
    final mimeType = _mimeTypeFromExtension(file.extension ?? '');
    final bytes = await _compressIfNeeded(file.path, mimeType, file.bytes!);
    onFileSelected(
      SelectedUploadFile(fileName: file.name, mimeType: mimeType, bytes: bytes),
    );
  }

  Future<Uint8List> _compressIfNeeded(
    String? path,
    String mimeType,
    Uint8List bytes,
  ) async {
    if (!mimeType.startsWith('image/') || path == null) {
      return bytes;
    }
    final compressed = await FlutterImageCompress.compressWithFile(
      path,
      minHeight: 1280,
      minWidth: 1280,
      quality: 80,
    );
    return compressed == null ? bytes : Uint8List.fromList(compressed);
  }

  String _mimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/pdf';
    }
  }
}
