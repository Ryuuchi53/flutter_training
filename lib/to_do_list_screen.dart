import 'package:flutter/material.dart';
import 'package:flutter_training_full/app_drawer.dart';
import 'package:flutter_training_full/app_theme.dart';

class ToDoListScreen extends StatefulWidget {
  final String email;
  final String name;

  const ToDoListScreen({super.key, required this.email, required this.name});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _tasks.add({'title': text, 'isDone': false});
    });

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do'),
      ),

      drawer: AppDrawer(currentRoute: '/todos', prefilledEmail: widget.email, prefilledName: widget.name),

      /// BACKGROUND
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF8E2DE2), Color(0xFFDA22FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              /// INPUT FIELD CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 6,
                  shadowColor: AppColors.darkPurple.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Add a new task...',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        IconButton(
                          onPressed: _addTask,
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: AppColors.deepPurple,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// TASK LIST
              Expanded(
                child: _tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks yet ✨',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 5,
                              shadowColor: AppColors.darkPurple.withValues(
                                alpha: 0.25,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task['isDone'],
                                  onChanged: (_) => _toggleTask(index),
                                ),
                                title: Text(
                                  task['title'],
                                  style: TextStyle(
                                    decoration: task['isDone']
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: task['isDone']
                                        ? Colors.grey
                                        : AppColors.darkPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _deleteTask(index),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
