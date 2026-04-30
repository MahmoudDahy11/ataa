import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/features/beneficiary/domain/entities/document_entity.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/document_upload_card.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_cubit.dart';
import 'package:ataa/features/upload/presentation/cubit/upload_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentUploadWidget extends StatelessWidget {
  final String label;
  final String helperText;
  final String documentType;
  final bool isUploaded;
  final String? uploadedFileName;
  final ValueChanged<DocumentEntity> onUploaded;

  const DocumentUploadWidget({
    super.key,
    required this.documentType,
    required this.onUploaded,
    this.label = 'Upload document',
    this.helperText = '',
    this.isUploaded = false,
    this.uploadedFileName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadCubit, UploadState>(
      listener: (context, state) {
        if (state is UploadSuccess) {
          showSnakBar(context, 'تم رفع الملف بنجاح');
          onUploaded(state.document);
        }
        if (state is UploadFailure) {
          showSnakBar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        final cubit = context.read<UploadCubit>();
        return DocumentUploadCard(
          label: label,
          helperText: helperText,
          uploadedFileName:
              (state is UploadSuccess) ? state.document.fileName : uploadedFileName,
          isUploaded: isUploaded || state is UploadSuccess,
          state: state,
          onPick: cubit.pickFile,
          onUpload: () => cubit.upload(documentType),
          onRetry: cubit.retry,
        );
      },
    );
  }
}
