// ---
// REPOSITORY: local_storage_repository.dart
// ---
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/features/tasks/data/models/task.dart';

// OOP CONCEPT: SINGLE RESPONSIBILITY PRINCIPLE (SRP)
// This class has exactly one job: managing data persistence.
// It abstracts away the complexity of shared_preferences from the UI.
class LocalStorageRepository {
  // We define the key as a constant so we don't misspell it in different methods.
  static const String _storageKey = 'cbtis47_tasks_key';

  // ---
  // DATA PERSISTENCE: LOAD (READ)
  // ---
  // Returns a Future containing a List of Tasks.
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJsonString = prefs.getString(_storageKey);

    if (tasksJsonString != null) {
      List<dynamic> decodedJsonList = jsonDecode(tasksJsonString);
      return decodedJsonList
          .map((jsonItem) => Task.fromJson(jsonItem))
          .toList();
    }

    // If no data is found, return an empty list instead of null.
    return [];
  }

  // ---
  // DATA PERSISTENCE: SAVE (WRITE)
  // ---
  // Takes the current list of tasks and saves it to the device.
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = tasks
        .map((task) => task.toJson())
        .toList();

    String tasksString = jsonEncode(jsonList);
    await prefs.setString(_storageKey, tasksString);
  }
}
