import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'data/local/adapters/hive_adapters.dart';
import 'data/local/models/lesson_record.dart';

void main() async {
  // Ensure Flutter binding is initialized before async setup.
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load Environment Variables (.env)
  await dotenv.load(fileName: 'assets/.env');

  // 2. Initialize Hive local database
  await Hive.initFlutter();
  
  // Register custom TypeAdapters before opening boxes
  registerHiveAdapters();
  
  // Open lessons Hive box
  await Hive.openBox<LessonRecord>(AppConstants.lessonsBox);

  // 3. Configure Dependency Injection (get_it + injectable)
  await configureDependencies();

  // 4. Run the App
  runApp(const FlutterAiTutorApp());
}

class FlutterAiTutorApp extends StatelessWidget {
  const FlutterAiTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter AI Tutor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Flutter & AI Tutor Ready!'),
        ),
      ),
    );
  }
}