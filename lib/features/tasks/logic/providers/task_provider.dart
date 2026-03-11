// ---
// STATE MANAGEMENT: task_provider.dart
// ---
import 'package:flutter/material.dart';
import 'package:to_do_list_app/features/tasks/data/models/category.dart';
import 'package:to_do_list_app/features/tasks/data/models/task.dart';
import 'package:to_do_list_app/features/tasks/data/repositories/local_storage_repository.dart';

class TaskProvider extends ChangeNotifier {
  final LocalStorageRepository _repository = LocalStorageRepository();
  List<Task> _tasks = [];

  // ---
  // CATEGORIES DATA (MOCK)
  // ---
  final List<Category> _categories = [
    Category(id: 'cat_1', name: 'Work', colorHex: '#FF5733'),
    Category(id: 'cat_2', name: 'Personal', colorHex: '#33FF57'),
    Category(id: 'cat_3', name: 'Motorcycles', colorHex: '#3357FF'),
  ];

  // ---
  // FILTER STATE
  // ---
  // A variable to store the ID of the currently selected category.
  // If it's null, it means "All Categories" are selected.
  String? _selectedFilterCategoryId;

  String? get selectedFilterCategoryId => _selectedFilterCategoryId;

  // Method to update the filter from the UI
  void setFilterCategory(String? categoryId) {
    _selectedFilterCategoryId = categoryId;
    notifyListeners(); // Tells the UI to rebuild with the new filter
  }

  List<Category> get categories => _categories;

  Category getCategoryById(String categoryId) {
    return _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => _categories.first,
    );
  }

  // ---
  // ADVANCED GETTERS (Combined Filtering)
  // ---
  // First, we create a private getter that filters by category (if one is selected)
  List<Task> get _filteredByCategory {
    if (_selectedFilterCategoryId == null) {
      return _tasks; // No category filter applied
    }
    return _tasks
        .where((task) => task.categoryId == _selectedFilterCategoryId)
        .toList();
  }

  // Then, our public getters use the already filtered list instead of the raw _tasks list.
  // This allows the TabBar (status) and the Chips (category) to work together seamlessly!
  List<Task> get allTasks => _filteredByCategory;
  List<Task> get pendingTasks =>
      _filteredByCategory.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks =>
      _filteredByCategory.where((task) => task.isCompleted).toList();

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _tasks = await _repository.loadTasks();
    notifyListeners();
  }

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

  int deleteTask(Task task) {
    final index = _tasks.indexOf(task);
    if (index != -1) {
      _tasks.removeAt(index);
      _syncWithStorage();
    }
    return index;
  }

  void undoDelete(int index, Task task) {
    if (index >= 0 && index <= _tasks.length) {
      _tasks.insert(index, task);
      _syncWithStorage();
    }
  }

  void _syncWithStorage() {
    _repository.saveTasks(_tasks);
    notifyListeners();
  }
}
