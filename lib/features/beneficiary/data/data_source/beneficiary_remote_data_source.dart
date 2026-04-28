import 'dart:typed_data';

import 'package:ataa/features/beneficiary/data/models/beneficiary.dart';
import 'package:ataa/features/beneficiary/data/models/case_model.dart';
import 'package:ataa/features/beneficiary/data/models/document_model.dart';
import 'package:ataa/features/beneficiary/domain/entities/upload_entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BeneficiaryRemoteDataSource {
  Future<BeneficiaryModel> register({required BeneficiaryModel beneficiary});

  Future<BeneficiaryModel> getProfile();

  Future<BeneficiaryModel> updateProfile({required BeneficiaryModel beneficiary});

  Stream<List<CaseModel>> watchOwnedCases({int limit = 10});

  Future<List<CaseModel>> getOwnedCasesPage({
    DocumentSnapshot<Object?>? startAfter,
    int limit = 10,
  });

  Future<CaseModel> getCaseById(String caseId);

  Future<CaseModel> saveDraftCase({required CaseModel draft});

  Future<CaseModel> submitCaseForReview({required String caseId});

  Future<UploadSession> initUpload({required UploadRequest request});

  Future<void> uploadBytes({
    required UploadSession session,
    required Uint8List bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  });

  Future<DocumentModel> confirmUpload({
    required String uploadId,
    required String ownerId,
    required String type,
  });

  Future<UploadSession> getUploadSession(String uploadId);
}
