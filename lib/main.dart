import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'data/local/adapters/hive_adapters.dart';
import 'data/local/models/user_progress_record.dart';
import 'features/ai_tutor/bloc/ai_assistant_settings_cubit.dart';
import 'features/curriculum/bloc/curriculum_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  // Ensure Flutter binding is initialized before async setup.
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive local database
  await Hive.initFlutter();

  // Register custom TypeAdapters before opening boxes
  registerHiveAdapters();

  // Open all Hive boxes used by the application
  await Hive.openBox<UserProgressRecord>(AppConstants.progressBox);

  // 2. Configure Dependency Injection (get_it + injectable)
  await configureDependencies();

  // Preload AI assistant settings before the UI renders.
  await getIt<AiAssistantSettingsCubit>().loadSettings();

  // 3. Run the App
  runApp(const FlutterAiTutorApp());
}

class FlutterAiTutorApp extends StatelessWidget {
  const FlutterAiTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CurriculumBloc>()..add(CurriculumLoadRequested()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Flutter AI Tutor',
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: Color(0XFFffffff),
            elevation: 4,
            shadowColor: Colors.grey.shade200,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Color(0xFF005cad),
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF005cad),
            size: context.responsiveTextTheme.headlineMedium?.fontSize,
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Color(0xFF005cad)),
              iconSize: WidgetStatePropertyAll(
                context.responsiveTextTheme.headlineLarge?.fontSize,
              ),
            ),
          ),
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF005cad),
            onPrimary: Color(0xFFffffff),
            primaryContainer: Color(0xFF0275d8),
            onPrimaryContainer: Color(0xFFfefcff),
            secondary: Color(0xFF5b00df),
            onSecondary: Color(0xFFffffff),
            secondaryContainer: Color(0xFF7531ff),
            onSecondaryContainer: Color(0xFFeadfff),
            tertiary: Color(0xFF005f9f),
            onTertiary: Color(0xFFffffff),
            tertiaryContainer: Color(0xFF0d78c5),
            onTertiaryContainer: Color(0xFFfdfcff),
            error: Color(0xFFba1a1a),
            onError: Color(0xFFffffff),
            errorContainer: Color(0xFFffdad6),
            onErrorContainer: Color(0xFF93000a),
            surface: Color(0xFFf2f4f6), // surface-container-low in Stitch
            onSurface: Color(0xFF191c1e),
            surfaceContainerHighest: Color(0xFFe0e3e5),
            onSurfaceVariant: Color(0xFF414753),
            outline: Color(0xFF717784),
            outlineVariant: Color(0xFFc1c6d5),
          ),
        ),
        routerConfig: getIt<AppRouter>().router,
        builder: (context, child) {
          // Calculate responsive text scale factor
          final mediaQueryData = MediaQuery.of(context);
          final screenWidth = mediaQueryData.size.width;
          double textScaleFactor = 0.9;

          if (screenWidth >= 600) {
            // Tablet portrait or landscape
            textScaleFactor = 1.5;
          } else if (screenWidth <= 360) {
            // Small phones
            textScaleFactor = 0.6;
          }
          return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
