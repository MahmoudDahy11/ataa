import 'dart:async';
import 'dart:typed_data';

import 'package:ataa/core/api/api_service.dart';
import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/core/env/app_env.dart';
import 'package:ataa/features/beneficiary/data/data_source/beneficiary_remote_data_source.dart';
import 'package:ataa/features/beneficiary/data/models/beneficiary.dart';
import 'package:ataa/features/beneficiary/data/models/case_model.dart';
import 'package:ataa/features/beneficiary/data/models/document_model.dart';
import 'package:ataa/features/beneficiary/data/models/upload_models.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:ataa/features/beneficiary/domain/entities/upload_entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BeneficiaryRemoteDataSourceImpl implements BeneficiaryRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final ApiService _apiService;
  final Map<String, UploadSession> _uploadSessions = {};

  BeneficiaryRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required ApiService apiService,
  }) : _auth = auth,
       _firestore = firestore,
       _apiService = apiService;

  String get _uid => _auth.currentUser?.uid ?? '';

  Future<String> get _token async =>
      await _auth.currentUser?.getIdToken() ?? '';

  @override
  Future<BeneficiaryModel> register({
    required BeneficiaryModel beneficiary,
  }) async {
    final uid = _uid;
    final now = FieldValue.serverTimestamp();
    await _firestore.collection(AppStrings.usersCollection).doc(uid).set({
      'role': AppStrings.beneficiaryRole,
      'phone': beneficiary.phone,
      'beneficiaryStatus': beneficiary.status,
      'schemaVersion': AppStrings.schemaVersion,
      'updatedAt': now,
    }, SetOptions(merge: true));
    final data = beneficiary.toJson()
      ..addAll({'updatedAt': now, 'createdAt': beneficiary.createdAt ?? now});
    await _firestore
        .collection(AppStrings.beneficiariesCollection)
        .doc(uid)
        .set(data, SetOptions(merge: true));
    final snapshot = await _firestore
        .collection(AppStrings.beneficiariesCollection)
        .doc(uid)
        .get();
    return BeneficiaryModel.fromJson(snapshot.data() ?? {}, id: snapshot.id);
  }

  @override
  Future<BeneficiaryModel> getProfile() async {
    final snapshot = await _firestore
        .collection(AppStrings.beneficiariesCollection)
        .doc(_uid)
        .get();
    return BeneficiaryModel.fromJson(snapshot.data() ?? {}, id: snapshot.id);
  }

  @override
  Future<BeneficiaryModel> updateProfile({
    required BeneficiaryModel beneficiary,
  }) async {
    await _firestore
        .collection(AppStrings.beneficiariesCollection)
        .doc(_uid)
        .set(
          beneficiary.toJson()..['updatedAt'] = FieldValue.serverTimestamp(),
          SetOptions(merge: true),
        );
    return getProfile();
  }

  Query<Map<String, dynamic>> _casesBaseQuery() {
    return _firestore
        .collection(AppStrings.casesCollection)
        .where('beneficiaryId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true);
  }

  @override
  Stream<List<CaseModel>> watchOwnedCases({int limit = 10}) {
    return _casesBaseQuery().limit(limit).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CaseModel.fromJson(doc.data(), id: doc.id))
          .toList();
    });
  }

  @override
  Future<List<CaseModel>> getOwnedCasesPage({
    DocumentSnapshot<Object?>? startAfter,
    int limit = 10,
  }) async {
    var query = _casesBaseQuery().limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CaseModel.fromJson(doc.data(), id: doc.id))
        .toList();
  }

  @override
  Future<CaseModel> getCaseById(String caseId) async {
    final snapshot = await _firestore
        .collection(AppStrings.casesCollection)
        .doc(caseId)
        .get();
    return CaseModel.fromJson(snapshot.data() ?? {}, id: snapshot.id);
  }

  @override
  Future<CaseModel> saveDraftCase({required CaseModel draft}) async {
    final data = draft.toJson()
      ..addAll({
        'beneficiaryId': _uid,
        'status': CaseLifecycle.draft,
        'collectedAmount': draft.collectedAmount,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': draft.createdAt ?? FieldValue.serverTimestamp(),
      });
    final collection = _firestore.collection(AppStrings.casesCollection);
    final docRef = draft.id.isEmpty
        ? collection.doc()
        : collection.doc(draft.id);
    await docRef.set(data, SetOptions(merge: true));
    final snapshot = await docRef.get();
    return CaseModel.fromJson(snapshot.data() ?? {}, id: snapshot.id);
  }

  @override
  Future<CaseModel> submitCaseForReview({required String caseId}) async {
    final docRef = _firestore
        .collection(AppStrings.casesCollection)
        .doc(caseId);
    await docRef.update({
      'status': CaseLifecycle.pendingReview,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final snapshot = await docRef.get();
    return CaseModel.fromJson(snapshot.data() ?? {}, id: snapshot.id);
  }

  @override
  Future<UploadSession> initUpload({required UploadRequest request}) async {
    final response = await _apiService.post(
      url: '${AppEnv.uploadBaseUrl}/init-upload',
      contentType: 'application/json',
      body: {
        'fileName': request.fileName,
        'mimeType': request.mimeType,
        'sizeBytes': request.sizeBytes,
        'scope': request.scope,
        'schemaVersion': AppStrings.schemaVersion,
      },
      token: await _token,
      headers: {'x-user-id': _uid},
    );
    final session = UploadSessionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    _uploadSessions[session.uploadId] = session;
    return session;
  }

  @override
  Future<void> uploadBytes({
    required UploadSession session,
    required Uint8List bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    await _apiService.putBytes(
      url: session.signedUrl,
      bytes: bytes,
      contentType: mimeType,
      headers: session.headers,
      onSendProgress: (sent, total) {
        if (total <= 0 || onProgress == null) {
          return;
        }
        onProgress(sent / total);
      },
    );
  }

  @override
  Future<DocumentModel> confirmUpload({
    required String uploadId,
    required String ownerId,
    required String type,
  }) async {
    final response = await _apiService.post(
      url: '${AppEnv.uploadBaseUrl}/confirm-upload',
      contentType: 'application/json',
      body: {
        'uploadId': uploadId,
        'ownerId': ownerId,
        'type': type,
        'schemaVersion': AppStrings.schemaVersion,
      },
      token: await _token,
      headers: {'x-user-id': _uid},
    );
    final data = response.data as Map<String, dynamic>;
    data['displayName'] ??= RequiredDocumentType.labels[type] ?? type;
    data['type'] ??= type;
    final document = DocumentModel.fromJson(
      data,
      id: data['id'] as String? ?? '',
    );
    await _firestore
        .collection(AppStrings.documentsCollection)
        .doc(document.id)
        .set(document.toJson(), SetOptions(merge: true));
    return document;
  }

  @override
  Future<UploadSession> getUploadSession(String uploadId) async {
    final session = _uploadSessions[uploadId];
    if (session == null) {
      throw StateError('Upload session not found');
    }
    return session;
  }
}
