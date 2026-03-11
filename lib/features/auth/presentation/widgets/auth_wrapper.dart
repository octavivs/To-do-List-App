// ---
// WIDGET: auth_wrapper.dart
// PATH: lib/features/auth/presentation/widgets/auth_wrapper.dart
// ---
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/features/auth/logic/providers/auth_provider.dart';
import 'package:to_do_list_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:to_do_list_app/features/tasks/presentation/screens/task_list_screen.dart';

// OOP CONCEPT: State Router Widget
// This widget doesn't display much UI of its own. Instead, it reacts to the
// AuthProvider's state and intelligently routes the user to the correct screen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to the AuthProvider to determine the current authentication state.
    final authProvider = context.watch<AuthProvider>();

    // Scenario 1: Still checking the session state (App just opened)
    if (authProvider.isCheckingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Scenario 2: User is successfully authenticated
    // We route them directly to their tasks.
    if (authProvider.isAuthenticated) {
      return const TaskListScreen();
    }

    // Scenario 3: User is not authenticated
    // We route them to the Login / Registration screen.
    return const AuthScreen();
  }
}
