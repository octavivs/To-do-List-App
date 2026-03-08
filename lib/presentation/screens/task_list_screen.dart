import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/logic/providers/task_provider.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Notice: No more initState, no more local List<Task>, no more Repository!

  // ---
  // MODAL BOTTOM SHEET
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
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
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
                            const SnackBar(
                              content: Text('Task title cannot be empty!'),
                            ),
                          );
                          return;
                        }

                        // FLUTTER CONCEPT: context.read()
                        // We use .read() here instead of .watch() because we are inside a callback (onPressed).
                        // We just want to trigger an action, not listen for UI changes.
                        final provider = context.read<TaskProvider>();

                        if (existingTask != null) {
                          existingTask.title = _titleController.text.trim();
                          existingTask.description = _descriptionController.text
                              .trim();
                          provider.updateTask(existingTask);
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
                          provider.addTask(newTask);
                        }

                        Navigator.pop(ctx);
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
  // REUSABLE UI COMPONENT
  // ---
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
            // Use Provider to delete and get the original index
            final provider = context.read<TaskProvider>();
            final originalIndex = provider.deleteTask(task);

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task "${task.title}" deleted.'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Use Provider to undo the deletion
                    provider.undoDelete(originalIndex, task);
                  },
                ),
              ),
            );
          },
          child: ListTile(
            onLongPress: () => _showTaskModal(context, task),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                // Provider handles the toggle and persistence automatically
                context.read<TaskProvider>().toggleTaskCompletion(task);
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

  @override
  Widget build(BuildContext context) {
    // FLUTTER CONCEPT: context.watch()
    // This makes the entire build method reactive. Whenever notifyListeners()
    // is called inside TaskProvider, this screen will rebuild with fresh data.
    final taskProvider = context.watch<TaskProvider>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TaskFlow'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
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
        body: TabBarView(
          children: [
            // We directly pass the filtered getters from the provider
            _buildTaskList(taskProvider.allTasks),
            _buildTaskList(taskProvider.pendingTasks),
            _buildTaskList(taskProvider.completedTasks),
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
