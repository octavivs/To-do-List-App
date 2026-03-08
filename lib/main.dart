// ---
// MAIN ENTRY POINT
// ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/logic/providers/task_provider.dart';
import 'package:to_do_list_app/presentation/screens/task_list_screen.dart';
import 'package:to_do_list_app/core/constants/app_colors.dart';

void main() {
  // FLUTTER CONCEPT: App Initialization with Provider
  // We wrap our entire app in a ChangeNotifierProvider so the state
  // is globally available to any widget that requests it.
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

      // ---
      // GLOBAL THEME CONFIGURATION
      // ---
      theme: ThemeData(
        // Generates a cohesive palette based on our primary color
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        // Sets the default background color for all screens
        scaffoldBackgroundColor: AppColors.background,

        // Globally configures all AppBars in the application
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
