// ---
// MAIN ENTRY POINT (Updated for Firebase Initialization)
// ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/features/tasks/logic/providers/task_provider.dart';
import 'package:to_do_list_app/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:to_do_list_app/core/constants/app_colors.dart';

// ---
// NEW FIREBASE IMPORTS
// ---
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_list_app/firebase_options.dart';

// OOP CONCEPT: Asynchronous Main Function
// Since initializing Firebase requires native communication with the OS,
// we must change main() to be async and wait for the setup to complete.
void main() async {
  // FLUTTER CONCEPT: Binding Initialization
  // This line is absolutely mandatory before using any native plugins (like Firebase)
  // prior to calling runApp(). It ensures the framework is ready to talk to the device.
  WidgetsFlutterBinding.ensureInitialized();

  // ---
  // FIREBASE INITIALIZATION
  // ---
  // We use the auto-generated options file to provide the correct API keys
  // depending on whether the app is running on Android or iOS.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          centerTitle: true,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}
