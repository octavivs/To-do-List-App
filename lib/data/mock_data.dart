// ---
// MOCK DATA FILE: mock_data.dart
// ---
// This file simulates a database response. It contains "dummy" or "mock" data
// that we can use to build and test our User Interface (UI) before connecting
// a real database.

// IMPORTANT: In a real project, we would import our model files here.
import 'package:to_do_list_app/data/models/app_user.dart';
import 'package:to_do_list_app/data/models/category.dart';
import 'package:to_do_list_app/data/models/task.dart';

class MockData {
  // 1. INSTANTIATING A USER
  // We create a single 'AppUser' object. This represents the person logged in.
  static AppUser currentUser = AppUser(
    id: 'user_001',
    name: 'Octavio Sanchez',
    email: 'octavio@example.com',
  );

  // 2. INSTANTIATING CATEGORIES
  // We create a 'List' (an array) of Category objects to organize our tasks.
  static List<Category> categories = [
    Category(id: 'cat_1', name: 'Work', colorHex: '#FF5733'),
    Category(id: 'cat_2', name: 'Personal', colorHex: '#33FF57'),
    Category(id: 'cat_3', name: 'Motorcycles', colorHex: '#3357FF'),
  ];

  // 3. INSTANTIATING TASKS
  // Here we create a List of Task objects. Notice how we use the IDs from
  // the user and categories above to establish the "Foreign Key" relationships!
  static List<Task> myTasks = [
    // Object 1: A pending work task
    Task(
      id: 'task_001',
      title: 'Prepare Flutter Class',
      description: 'Review OOP and classes for the students at CBTis 47.',
      isCompleted: false, // This task is currently pending
      createdAt: DateTime.now(), // Records the exact current time
      appUserId: 'user_001',
      categoryId: 'cat_1', // Linked to the "Work" category
    ),

    // Object 2: A completed personal task
    Task(
      id: 'task_002',
      title: 'Study Session',
      description:
          'Help my son review math for his secondary school entrance exam.',
      isCompleted: true, // This task is already done!
      createdAt: DateTime.now().subtract(
        const Duration(days: 2),
      ), // Created 2 days ago
      appUserId: 'user_001',
      categoryId: 'cat_2', // Linked to the "Personal" category
    ),

    // Object 3: A pending motorcycle task
    Task(
      id: 'task_003',
      title: 'Sell old motorcycle',
      description:
          'Take high-quality photos of the Italika Blackbird 250 and post them online.',
      isCompleted: false,
      createdAt: DateTime.now(),
      appUserId: 'user_001',
      categoryId: 'cat_3', // Linked to the "Motorcycles" category
    ),

    // Object 4: Another pending motorcycle task
    Task(
      id: 'task_004',
      title: 'Motorcycle maintenance',
      description:
          'Check the tire pressure and brakes on the Pulsar N250 UG before commuting to Orizaba.',
      isCompleted: false,
      createdAt: DateTime.now(),
      appUserId: 'user_001',
      categoryId: 'cat_3',
    ),
  ];
}
