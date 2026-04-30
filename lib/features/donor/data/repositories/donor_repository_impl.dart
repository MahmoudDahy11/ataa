import 'package:ataa/core/error/failure.dart';
import 'package:ataa/features/donor/data/datasources/donor_local_datasource.dart';
import 'package:ataa/features/donor/data/datasources/donor_remote_datasource.dart';
import 'package:ataa/features/donor/data/models/donor_hive_model.dart';
import 'package:ataa/features/donor/data/models/donor_model.dart';
import 'package:ataa/features/donor/domain/entities/donation_history_entity.dart';
import 'package:ataa/features/donor/domain/entities/donor_entity.dart';
import 'package:ataa/features/donor/domain/entities/payment_method_entity.dart';
import 'package:dartz/dartz.dart';

import '../../domain/repositories/donor_repository.dart';

class DonorRepoImpl implements DonorRepo {
  final DonorRemoteDataSource _remote;
  final DonorLocalDataSource _local;

  const DonorRepoImpl({
    required DonorRemoteDataSource remote,
    required DonorLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  @override
  Future<Either<CustomFailure, void>> saveDonorProfile(
    DonorEntity donor,
  ) async {
    try {
      final model = DonorModel.fromEntity(donor);
      await _remote.saveDonorProfile(model);
      await _local.cacheDonorProfile(DonorHiveModel.fromEntity(donor));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, DonorEntity>> getDonorProfile(String uid) async {
    try {
      final cached = await _local.getCachedDonorProfile();
      if (cached != null) return Right(cached.toEntity());
      final model = await _remote.getDonorProfile(uid);
      await _local.cacheDonorProfile(
        DonorHiveModel.fromEntity(model.toEntity()),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> savePaymentMethod({
    required String uid,
    required PaymentMethodEntity paymentMethod,
  }) async {
    try {
      await _remote.savePaymentMethod(uid: uid, paymentMethod: paymentMethod);
      await _local.cachePaymentMethod(paymentMethod);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, PaymentMethodEntity?>>
  getCachedPaymentMethod() async {
    try {
      final cached = await _local.getCachedPaymentMethod();
      return Right(cached);
    } catch (e) {
      return Left(ServerFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, List<DonationHistoryEntity>>> getDonationHistory(
    String uid,
  ) async {
    try {
      final models = await _remote.getDonationHistory(uid);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(errMessage: e.toString()));
    }
  }
}
