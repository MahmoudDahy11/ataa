import 'package:ataa/core/di/service_locator.dart';
import 'package:ataa/core/router/app_router.dart';
import 'package:ataa/core/theme/app_theme.dart';
import 'package:ataa/features/donor/data/models/donor_hive_model.dart';
import 'package:ataa/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Load Environment Variables
  await dotenv.load(fileName: '.env');
  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 3. Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DonorHiveModelAdapter());
  await Hive.openBox('app_config');
  await Hive.openBox('donor_box');
  // 4. Setup Service Locator
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ataa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
