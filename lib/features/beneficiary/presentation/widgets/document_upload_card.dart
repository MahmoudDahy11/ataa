import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_state.dart';
import 'package:ataa/features/upload/presentation/widgets/upload_preview.dart';
import 'package:flutter/material.dart';

class DocumentUploadCard extends StatelessWidget {
  final String label;
  final String helperText;
  final String? uploadedFileName;
  final bool isUploaded;
  final UploadState state;
  final VoidCallback onPick;
  final VoidCallback onUpload;
  final VoidCallback onRetry;

  const DocumentUploadCard({
    super.key,
    required this.label,
    required this.helperText,
    required this.uploadedFileName,
    required this.isUploaded,
    required this.state,
    required this.onPick,
    required this.onUpload,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final busy = state is UploadLoading || state is UploadInProgress;
    final progress =
        state is UploadInProgress ? (state as UploadInProgress).progress : null;
    final fileName = state.file?.name ?? uploadedFileName ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUploaded || state is UploadSuccess
              ? AppColors.primary.withValues(alpha: 0.55)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UploadPreview(
            file: state.file,
            isUploaded: isUploaded || state is UploadSuccess,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (helperText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              helperText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (fileName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(fileName, style: AppTextStyles.bodyMedium),
          ],
          if (busy) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress == 0 ? null : progress,
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : onPick,
                  icon: const Icon(Icons.attach_file_rounded),
                  label: Text(
                    state.file == null ? 'اختيار ملف' : 'تغيير الملف',
                  ),
                ),
              ),
              if (state.file != null && state is! UploadSuccess) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : onUpload,
                    child: const Text('رفع الملف'),
                  ),
                ),
              ],
            ],
          ),
          if (state is UploadFailure) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}
