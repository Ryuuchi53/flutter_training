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
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  final List<Map<String, dynamic>> _tasks = [];

  void _addTask() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) return;

    setState(() {
      _tasks.add({'title': title, 'description': desc, 'isDone': false});
    });

    _titleController.clear();
    _descController.clear();
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

  void _editTask(int index) {
    final task = _tasks[index];

    final editTitle = TextEditingController(text: task['title']);
    final editDesc = TextEditingController(text: task['description']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HANDLE BAR
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                /// TITLE
                const Text(
                  "Edit Task",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 16),

                /// TITLE FIELD
                TextField(
                  controller: editTitle,
                  decoration: InputDecoration(
                    labelText: "Title",
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: "Enter task title",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// DESCRIPTION FIELD
                TextField(
                  controller: editDesc,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    hintText: "Enter task description",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ACTIONS
                Row(
                  children: [
                    /// CANCEL
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// SAVE
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _tasks[index]['title'] = editTitle.text.trim();
                            _tasks[index]['description'] = editDesc.text.trim();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A11CB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Save"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskActions(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator_rounded,
              color: Colors.grey.shade600,
              size: 22,
            ),
          ),

          const SizedBox(width: 6),

          Material(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _editTask(index),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.edit_rounded, size: 20, color: Colors.blue),
              ),
            ),
          ),

          const SizedBox(width: 6),

          Material(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _deleteTask(index),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get _completedCount =>
      _tasks.where((task) => task['isDone'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do')),

      drawer: AppDrawer(
        currentRoute: '/todos',
        prefilledEmail: widget.email,
        prefilledName: widget.name,
      ),

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
              const SizedBox(height: 12),

              /// ✅ COUNTER
              Text(
                "Completed: $_completedCount / ${_tasks.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// INPUT CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Task title...',
                            border: InputBorder.none,
                          ),
                        ),
                        TextField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            hintText: 'Task description...',
                            border: InputBorder.none,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: _addTask,
                            icon: const Icon(
                              Icons.add_circle_rounded,
                              color: AppColors.deepPurple,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// LIST
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _tasks.isEmpty
                        ? const Center(
                            child: Text(
                              'No tasks yet ✨',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: Colors.transparent,
                                child: child,
                              );
                            },
                            itemCount: _tasks.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;

                                final item = _tasks.removeAt(oldIndex);
                                _tasks.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final task = _tasks[index];

                              return Container(
                                key: ValueKey(index),
                                margin: const EdgeInsets.only(bottom: 12),
                                width: double.infinity,

                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),

                                  child: ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),

                                    leading: Checkbox(
                                      value: task['isDone'],
                                      onChanged: (_) => _toggleTask(index),
                                    ),

                                    title: Text(
                                      task['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: task['isDone']
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),

                                    subtitle:
                                        task['description'] != null &&
                                            task['description']
                                                .toString()
                                                .isNotEmpty
                                        ? Text(task['description'])
                                        : null,

                                    trailing: _buildTaskActions(index),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
