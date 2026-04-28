import 'package:ataa/core/api/api_service.dart';
import 'package:ataa/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:ataa/features/auth/data/data_source/auth_remote_data_source_impl.dart';
import 'package:ataa/features/auth/data/repo/auth_repo_impl.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ataa/features/beneficiary/data/data_source/beneficiary_remote_data_source.dart';
import 'package:ataa/features/beneficiary/data/data_source/beneficiary_remote_data_source_impl.dart';
import 'package:ataa/features/beneficiary/data/repo/beneficiary_repo_impl.dart';
import 'package:ataa/features/beneficiary/domain/repo/beneficiary_repo.dart';
import 'package:ataa/features/beneficiary/domain/usecases/get_beneficiary_profile.dart';
import 'package:ataa/features/beneficiary/domain/usecases/register_beneficiary.dart';
import 'package:ataa/features/beneficiary/domain/usecases/save_beneficiary_case.dart';
import 'package:ataa/features/beneficiary/domain/usecases/upload_beneficiary_document.dart';
import 'package:ataa/features/beneficiary/presentation/cubit/beneficiary_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Firebase Instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<ApiService>(ApiService.new);

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<BeneficiaryRemoteDataSource>(
    () => BeneficiaryRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
      apiService: sl<ApiService>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(dataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<BeneficiaryRepo>(
    () => BeneficiaryRepoImpl(dataSource: sl<BeneficiaryRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => RegisterBeneficiary(sl<BeneficiaryRepo>()));
  sl.registerLazySingleton(() => GetBeneficiaryProfile(sl<BeneficiaryRepo>()));
  sl.registerLazySingleton(() => SaveBeneficiaryCase(sl<BeneficiaryRepo>()));
  sl.registerLazySingleton(
    () => UploadBeneficiaryDocument(sl<BeneficiaryRepo>()),
  );

  // Cubits
  sl.registerLazySingleton(() => AuthCubit(authRepo: sl<AuthRepo>()));
  sl.registerFactory(
    () => BeneficiaryCubit(
      repo: sl<BeneficiaryRepo>(),
      authRepo: sl<AuthRepo>(),
    ),
  );
}
