// ---
// STATE MANAGEMENT: task_provider.dart
// ---
import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/data/repositories/local_storage_repository.dart';

// OOP CONCEPT: INHERITANCE
// By extending 'ChangeNotifier', this class gains the ability to broadcast
// messages (notifications) to any Widget that is listening to it.
class TaskProvider extends ChangeNotifier {
  // 1. REPOSITORY INSTANCE
  // The provider handles the business logic, so it needs to talk to the data layer.
  final LocalStorageRepository _repository = LocalStorageRepository();

  // 2. INTERNAL STATE (Encapsulation)
  // We make the list private (using the underscore '_') so external files
  // cannot modify it directly without using our specific methods.
  List<Task> _tasks = [];

  // 3. GETTERS
  // Expose the state to the UI in a read-only manner.
  List<Task> get allTasks => _tasks;
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  // ---
  // INITIALIZATION
  // ---
  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _repository.loadTasks();
    // CRITICAL: Tells all listening UI components to rebuild!
    notifyListeners();
  }

  // ---
  // CRUD OPERATIONS & BUSINESS LOGIC
  // ---

  void addTask(Task task) {
    _tasks.insert(0, task);
    _syncWithStorage();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _syncWithStorage();
    }
  }

  void toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    _syncWithStorage();
  }

  // Returns the original index so the UI can offer an "Undo" feature.
  int deleteTask(Task task) {
    final index = _tasks.indexOf(task);
    if (index != -1) {
      _tasks.removeAt(index);
      _syncWithStorage();
    }
    return index;
  }

  void undoDelete(int index, Task task) {
    // Safety check to ensure we don't insert out of bounds
    if (index >= 0 && index <= _tasks.length) {
      _tasks.insert(index, task);
      _syncWithStorage();
    }
  }

  // Centralized method to save changes and notify the UI
  void _syncWithStorage() {
    _repository.saveTasks(_tasks);
    notifyListeners();
  }
}
