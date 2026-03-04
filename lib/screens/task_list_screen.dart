import 'package:flutter/material.dart';
import '../models/task.dart';
import '../data/mock_data.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Bring the list of tasks from our MockData class
  final List<Task> tasks = MockData.myTasks;

  // FLUTTER CONCEPT: TextEditingController
  // These controllers act like a bridge between the UI (the text fields)
  // and our logic. They allow us to read what the user types in real-time.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // ---
  // MODAL BOTTOM SHEET METHOD (USER STORY #1)
  // ---
  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to resize when the keyboard appears
      builder: (BuildContext ctx) {
        // UI CONCEPT: Padding & MediaQuery (The Keyboard Trick)
        // We add dynamic padding to the bottom exactly equal to the keyboard's height.
        // This pushes the entire modal up so the input fields are never hidden!
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Takes only the vertical space it needs
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
                autofocus: true, // UX DETAIL: Automatically opens the keyboard
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              const SizedBox(height: 16), // Visual spacing
              // SAVE BUTTON
              SizedBox(
                width: double.infinity, // Makes the button stretch full-width
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // ACCEPTANCE CRITERIA 3: Empty task prevention
                    // We use '.trim()' to remove accidental blank spaces.
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task title cannot be empty!'),
                        ),
                      );
                      return; // Stops the function execution here
                    }

                    // ACCEPTANCE CRITERIA 2: Saving the task
                    // We instantiate a new Task object using the OOP principles.
                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch
                          .toString(), // Simple unique ID
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      createdAt: DateTime.now(),
                      appUserId: 'user_001', // Linked to our mock user
                      categoryId: 'cat_1', // Default category for now
                    );

                    // UPDATE THE STATE (UI)
                    setState(() {
                      // We use insert(0, ...) to add the new task at the top of the list!
                      tasks.insert(0, newTask);
                    });

                    // CLEAN UP: Clear text fields for the next time it opens
                    _titleController.clear();
                    _descriptionController.clear();

                    // Close the modal
                    Navigator.pop(context);
                  },
                  child: const Text('Save Task'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // FLUTTER CONCEPT: ListView.builder
      // This is the most efficient way to create a list in Flutter.
      // It only renders the items that are visible on the screen!
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          // We get the specific task object for this position (index)
          final task = tasks[index];

          // ---
          // USER STORY #3: TASK DELETION (SWIPE TO DELETE)
          // ---
          // FLUTTER CONCEPT: Dismissible
          // A widget that can be dismissed by dragging in the indicated direction.
          return Dismissible(
            // FLUTTER CONCEPT: Keys
            // When widgets move around or get deleted, Flutter needs a unique ID
            // to know exactly WHICH widget is being interacted with.
            key: ValueKey(task.id),

            // UI CONCEPT: Swipe Direction
            // We restrict the swipe to only work from right to left (endToStart).
            direction: DismissDirection.endToStart,

            // UI CONCEPT: Background
            // This is what shows UP BEHIND the list item when you start swiping.
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            // EVENT: onDismissed
            // This code runs AFTER the user finishes the swipe gesture.
            onDismissed: (direction) {
              // 1. TEMPORARY MEMORY: We save the task and its position before deleting it.
              // This is crucial for the "Undo" functionality.
              final deletedTask = task;
              final deletedIndex = index;

              // 2. STATE UPDATE: Remove the item from our list so the UI updates.
              setState(() {
                tasks.removeAt(index);
              });

              // 3. USER EXPERIENCE (UX): ScaffoldMessenger & SnackBar
              // We show a temporary pop-up message at the bottom of the screen.
              ScaffoldMessenger.of(
                context,
              ).clearSnackBars(); // Clears any existing snackbars
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task "${deletedTask.title}" deleted.'),
                  duration: const Duration(seconds: 4), // Grace period
                  // USER STORY #3: ACCEPTANCE CRITERIA 3 & 4 (UNDO ACTION)
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // If the user clicks "Undo", we put the task back exactly
                      // where it was before using insert().
                      setState(() {
                        tasks.insert(deletedIndex, deletedTask);
                      });
                    },
                  ),
                ),
              );
            },

            // UI CONCEPT: ListTile
            // A pre-built widget perfect for lists with a title, subtitle, and icons.
            // Now wrapped securely inside the Dismissible.
            child: ListTile(
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? newValue) {
                  // OOP & FLUTTER CONCEPT: setState
                  // This function tells Flutter: "Something changed in the data,
                  // please redraw the screen so the user can see it!"
                  setState(() {
                    task.isCompleted = newValue ?? false;
                  });
                },
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  // USER STORY #2: Visual indicator for completion
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isCompleted ? Colors.grey : Colors.black87,
                ),
              ),
              subtitle: Text(task.description),
              // We can remove the static swipe icon now, as the actual gesture works!
              // trailing: const Icon(Icons.swipe_left, color: Colors.grey, size: 16),
            ),
          );
        },
      ),
      // USER STORY #1: ACCEPTANCE CRITERIA 1 - Triggering the modal
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
