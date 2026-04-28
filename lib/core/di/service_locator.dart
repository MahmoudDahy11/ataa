import 'package:ataa/features/auth/data/data_source/auth_remote_data_source.dart';
import 'package:ataa/features/auth/data/data_source/auth_remote_data_source_impl.dart';
import 'package:ataa/features/auth/data/repo/auth_repo_impl.dart';
import 'package:ataa/features/auth/domain/repo/auth_repo.dart';
import 'package:ataa/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Firebase Instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(dataSource: sl<AuthRemoteDataSource>()),
  );

  // Cubits
  sl.registerLazySingleton(() => AuthCubit(authRepo: sl<AuthRepo>()));
}
