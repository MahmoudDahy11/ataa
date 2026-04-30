import 'package:ataa/core/theme/app_colors.dart';
import 'package:ataa/core/theme/app_text_styles.dart';
import 'package:ataa/features/upload/domain/entities/upload_file.dart';
import 'package:flutter/material.dart';

class UploadPreview extends StatelessWidget {
  final UploadFile? file;
  final bool isUploaded;

  const UploadPreview({
    super.key,
    required this.file,
    required this.isUploaded,
  });

  @override
  Widget build(BuildContext context) {
    if (file?.isImage == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 1.55,
          child: Image.memory(file!.bytes, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      height: 174,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            file?.isPdf == true
                ? Icons.picture_as_pdf_rounded
                : Icons.upload_file_rounded,
            color: AppColors.primary,
            size: 34,
          ),
          const Spacer(),
          Text(
            file?.name ?? 'اختر صورة أو ملف PDF',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleLarge,
          ),
          if (isUploaded)
            Text(
              'تم الرفع بنجاح',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
