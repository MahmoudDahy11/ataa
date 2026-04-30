import 'dart:async';

import 'package:ataa/core/constants/app_strings.dart';
import 'package:ataa/features/beneficiary/data/data_source/beneficiary_remote_data_source.dart';
import 'package:ataa/features/beneficiary/data/models/beneficiary.dart';
import 'package:ataa/features/beneficiary/data/models/case_model.dart';
import 'package:ataa/features/beneficiary/domain/entities/beneficiary_enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BeneficiaryRemoteDataSourceImpl implements BeneficiaryRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  BeneficiaryRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  String get _uid => _auth.currentUser?.uid ?? '';

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

    return getProfile();
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

  @override
  Stream<List<CaseModel>> watchOwnedCases({int limit = 10}) {
    return _firestore
        .collection(AppStrings.casesCollection)
        .where('beneficiaryId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => CaseModel.fromJson(d.data(), id: d.id))
              .toList(),
        );
  }

  @override
  Future<List<CaseModel>> getOwnedCasesPage({
    DocumentSnapshot<Object?>? startAfter,
    int limit = 10,
  }) async {
    var query = _firestore
        .collection(AppStrings.casesCollection)
        .where('beneficiaryId', isEqualTo: _uid)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snapshot = await query.get();
    return snapshot.docs
        .map((d) => CaseModel.fromJson(d.data(), id: d.id))
        .toList();
  }

  @override
  Future<CaseModel> getCaseById(String caseId) async {
    final s = await _firestore
        .collection(AppStrings.casesCollection)
        .doc(caseId)
        .get();
    return CaseModel.fromJson(s.data() ?? {}, id: s.id);
  }

  @override
  Future<CaseModel> saveDraftCase({required CaseModel draft}) async {
    final data = draft.toJson()
      ..addAll({
        'beneficiaryId': _uid,
        'status': CaseLifecycle.draft,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': draft.createdAt ?? FieldValue.serverTimestamp(),
      });
    final docRef = draft.id.isEmpty
        ? _firestore.collection(AppStrings.casesCollection).doc()
        : _firestore.collection(AppStrings.casesCollection).doc(draft.id);
    await docRef.set(data, SetOptions(merge: true));
    return getCaseById(docRef.id);
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
    return getCaseById(caseId);
  }
}
