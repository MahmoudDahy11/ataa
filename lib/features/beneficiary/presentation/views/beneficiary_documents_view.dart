import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/helper/show_snak_bar.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_state.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/beneficiary_display_utils.dart';
import 'package:ataa/features/beneficiary/presentation/widgets/document_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BeneficiaryDocumentsView extends StatelessWidget {
  const BeneficiaryDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BeneficiaryCubit>()..loadProfile(),
      child: const _BeneficiaryDocumentsBody(),
    );
  }
}

class _BeneficiaryDocumentsBody extends StatelessWidget {
  const _BeneficiaryDocumentsBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BeneficiaryCubit, BeneficiaryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          showSnakBar(context, state.errorMessage!, isError: true);
        } else if (state.successMessage != null) {
          showSnakBar(context, state.successMessage!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<BeneficiaryCubit>();
        return Scaffold(
          appBar: AppBar(title: const Text('Documents')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ...RequiredDocumentType.all.map((type) {
                final item = state.uploadedDocumentsByType[type];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DocumentUploadWidget(
                        label: documentLabel(type),
                        helperText: item == null
                            ? 'Required upload'
                            : item.fileName,
                        isUploaded: item != null,
                        isUploading:
                            state.isUploading && state.activeUploadType == type,
                        progress: state.activeUploadType == type
                            ? state.uploadProgress
                            : 0,
                        onFileSelected: (file) {
                          cubit.startUpload(
                            fileName: file.fileName,
                            mimeType: file.mimeType,
                            bytes: file.bytes,
                            scope: 'beneficiary_document',
                            documentType: type,
                          );
                        },
                      ),
                      if (item != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.description_outlined),
                          title: Text(item.fileName),
                          subtitle: Text(item.status),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
