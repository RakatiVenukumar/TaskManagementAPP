import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:task_manager_app/database/database_helper.dart';
import 'package:task_manager_app/screens/task_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  }

  if (!kIsWeb) {
    try {
      await DatabaseHelper.instance.database.timeout(const Duration(seconds: 8));
    } catch (error, stackTrace) {
      debugPrint('Database init failed at startup: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B6E4F),
      brightness: Brightness.light,
    );
    final textTheme = ThemeData.light().textTheme.copyWith(
      headlineSmall: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );

    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}
