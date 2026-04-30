import 'package:ataa/features/donor/data/datasources/donor_remote_datasource.dart';
import 'package:ataa/features/donor/data/models/donation_history_model.dart';
import 'package:ataa/features/donor/data/models/donor_model.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonorRemoteDataSourceImpl implements DonorRemoteDataSource {
  final FirebaseFirestore _firestore;

  static const _donorsCollection = 'donors';
  static const _donationsCollection = 'donations';

  const DonorRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<void> saveDonorProfile(DonorModel donor) async {
    await _firestore
        .collection(_donorsCollection)
        .doc(donor.uid)
        .set(donor.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<DonorModel> getDonorProfile(String uid) async {
    final doc = await _firestore.collection(_donorsCollection).doc(uid).get();
    if (!doc.exists) throw Exception('Donor profile not found');
    return DonorModel.fromFirestore(doc);
  }

  @override
  Future<void> savePaymentMethod({
    required String uid,
    required PaymentMethodEntity paymentMethod,
  }) async {
    await _firestore.collection(_donorsCollection).doc(uid).update({
      'paymentType': paymentMethod.type.name,
      'vodafoneNumber': paymentMethod.vodafoneNumber,
      'cardToken': paymentMethod.cardToken,
    });
  }

  @override
  Future<List<DonationHistoryModel>> getDonationHistory(String uid) async {
    final snapshot = await _firestore
        .collection(_donorsCollection)
        .doc(uid)
        .collection(_donationsCollection)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map(DonationHistoryModel.fromFirestore).toList();
  }
}
