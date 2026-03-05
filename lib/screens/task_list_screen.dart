import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// IMPORTANT: Make sure these import paths match your actual project structure!
import '../models/task.dart';
// import '../data/mock_data.dart'; // Only needed if you want to load mock data initially

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // We start with an empty list. It will be populated from the device's storage.
  List<Task> tasks = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // ---
  // LIFECYCLE: initState
  // ---
  @override
  void initState() {
    super.initState();
    _loadTasksFromDevice();
  }

  // ---
  // DATA PERSISTENCE: LOAD (READ)
  // ---
  Future<void> _loadTasksFromDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJsonString = prefs.getString('cbtis47_tasks_key');

    if (tasksJsonString != null) {
      List<dynamic> decodedJsonList = jsonDecode(tasksJsonString);
      setState(() {
        tasks = decodedJsonList
            .map((jsonItem) => Task.fromJson(jsonItem))
            .toList();
      });
    }
  }

  // ---
  // DATA PERSISTENCE: SAVE (WRITE)
  // ---
  Future<void> _saveTasksToDevice() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = tasks
        .map((task) => task.toJson())
        .toList();
    String tasksString = jsonEncode(jsonList);
    await prefs.setString('cbtis47_tasks_key', tasksString);
  }

  // ---
  // MODAL BOTTOM SHEET (ANDROID KEYBOARD FIX)
  // ---
  void _showTaskModal(BuildContext context, [Task? existingTask]) {
    if (existingTask != null) {
      _titleController.text = existingTask.title;
      _descriptionController.text = existingTask.description;
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // 1. Allows the modal to take up full screen height if needed
      builder: (BuildContext ctx) {
        // 2. NOTICE 'ctx' HERE! This is the modal's specific context.

        // FLUTTER BUG FIX: Context Scope & Widget Hierarchy
        // To fix the Android keyboard overlap, the structure MUST be:
        // Padding (Keyboard) -> SingleChildScrollView -> Padding (Visual) -> Column
        return Padding(
          // 3. We use 'ctx' instead of 'context' to listen to the keyboard correctly
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              // 4. This is just the visual spacing for the UI elements
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existingTask != null ? 'Edit Task' : 'Add New Task',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                    autofocus: true,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            // Here 'context' is fine for the SnackBar
                            const SnackBar(
                              content: Text('Task title cannot be empty!'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          if (existingTask != null) {
                            existingTask.title = _titleController.text.trim();
                            existingTask.description = _descriptionController
                                .text
                                .trim();
                          } else {
                            final newTask = Task(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                              createdAt: DateTime.now(),
                              appUserId: 'user_001',
                              categoryId: 'cat_1',
                            );
                            tasks.insert(0, newTask);
                          }
                        });

                        _saveTasksToDevice();
                        Navigator.pop(
                          ctx,
                        ); // Close the modal using its specific context
                      },
                      child: Text(
                        existingTask != null ? 'Update Task' : 'Save Task',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---
  // REUSABLE UI COMPONENT (DRY PRINCIPLE)
  // ---
  // OOP CONCEPT: Method Extraction
  // Instead of writing the ListView code three times for our three tabs,
  // we create a function that takes a specific list of tasks and builds the UI.
  Widget _buildTaskList(List<Task> filteredTasks) {
    if (filteredTasks.isEmpty) {
      return const Center(
        child: Text(
          'No tasks found in this section.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];

        return Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            final deletedTask = task;

            // To undo safely across filtered lists, we find the original index
            final originalIndex = tasks.indexWhere(
              (t) => t.id == deletedTask.id,
            );

            setState(() {
              tasks.removeWhere((t) => t.id == deletedTask.id);
            });

            _saveTasksToDevice();

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task "${deletedTask.title}" deleted.'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    setState(() {
                      tasks.insert(originalIndex, deletedTask);
                    });
                    _saveTasksToDevice();
                  },
                ),
              ),
            );
          },
          child: ListTile(
            onLongPress: () => _showTaskModal(context, task),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? newValue) {
                setState(() {
                  task.isCompleted = newValue ?? false;
                });
                _saveTasksToDevice();
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isCompleted ? Colors.grey : Colors.black87,
              ),
            ),
            subtitle: task.description.isNotEmpty
                ? Text(task.description)
                : null,
          ),
        );
      },
    );
  }

  // ---
  // MAIN UI BUILDER WITH TABS
  // ---
  @override
  Widget build(BuildContext context) {
    // FLUTTER CONCEPT: DefaultTabController
    // Wraps our Scaffold and automatically syncs the TabBar with the TabBarView.
    return DefaultTabController(
      length: 3, // We will have 3 tabs: All, Pending, Completed
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My To-Do List'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          // FLUTTER CONCEPT: TabBar
          // The visual buttons at the bottom of the AppBar
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),

        // FLUTTER CONCEPT: TabBarView
        // The content that changes when you swipe or tap a tab.
        // The order of children MUST match the order of the tabs above.
        body: TabBarView(
          children: [
            // TAB 1: ALL TASKS
            _buildTaskList(tasks),

            // TAB 2: PENDING TASKS ONLY
            // We use .where() to filter the list dynamically
            _buildTaskList(tasks.where((task) => !task.isCompleted).toList()),

            // TAB 3: COMPLETED TASKS ONLY
            _buildTaskList(tasks.where((task) => task.isCompleted).toList()),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTaskModal(context),
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
