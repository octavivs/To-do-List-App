// ---
// MAIN ENTRY POINT
// ---
import 'package:flutter/material.dart';
import 'package:to_do_list_app/presentation/screens/task_list_screen.dart';

// FLUTTER CONCEPT: The main() function
// This is the very first function that Dart runs when the app starts.
void main() {
  // runApp() takes our root widget and inflates it onto the screen.
  runApp(const TodoApp());
}

// OOP & FLUTTER CONCEPT: StatelessWidget
// The root of our app doesn't change its state directly. It just configures
// global settings like the theme, the title, and the first screen to load.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FLUTTER CONCEPT: MaterialApp
    // This widget wraps a number of widgets that are commonly required for
    // Material Design applications. It handles routing and themes globally.
    return MaterialApp(
      // The title of the app (used by the device's task switcher)
      title: 'TaskFlow',

      // UI DETAIL: Hides the little "DEBUG" banner in the top right corner
      debugShowCheckedModeBanner: false,

      // FLUTTER CONCEPT: ThemeData
      // Defines the default colors and typography for the entire app.
      // We base it on the blueAccent color we used in our buttons.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true, // Uses the latest Material Design guidelines
      ),

      // FLUTTER CONCEPT: Home
      // This is the first screen the user will see when they open the app.
      // We point it to the TaskListScreen we created in the previous steps.
      home: const TaskListScreen(),
    );
  }
}
