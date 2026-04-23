import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_training_full/app_drawer.dart';
import 'package:flutter_training_full/app_theme.dart';
import 'package:flutter_training_full/todo_api.dart';
import 'package:flutter_training_full/utils/shared_preferences_utils.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late TodoApi api;

  List<Map<String, dynamic>> _tasks = [];
  bool _loading = false;

  Timer? _logoutTimer;

  bool _isDone(dynamic value) {
    return value == true || value == 1 || value == '1';
  }

  DateTime? _selectedDate;
  List<Map<String, dynamic>> get _displayTasks {
    if (_selectedDate == null) return _tasks;

    return _tasks.where((task) {
      final taskDate = DateTime.parse(task['created_at']);
      return taskDate.year == _selectedDate!.year &&
          taskDate.month == _selectedDate!.month &&
          taskDate.day == _selectedDate!.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _checkTokenExpiration();
    final token = SharedPreferencesUtils().getStorageToken;
    _selectedDate = DateTime.now();

    api = TodoApi(baseUrl: 'http://10.0.2.2:8000/api', token: token);

    _loadTasks();
    _startLogoutTimer();
  }

  @override
  void dispose() {
    _logoutTimer?.cancel();
    super.dispose();
  }

  void _startLogoutTimer() {
    _logoutTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTokenExpiration();
    });
  }

  void _checkTokenExpiration() {
    final expiresAtStr = SharedPreferencesUtils().getExpiresAt;
    if (expiresAtStr.isEmpty) return;
    try {
      DateTime expiresAt;
      if (int.tryParse(expiresAtStr) != null) {
        // Assume it's Unix timestamp in seconds
        expiresAt = DateTime.fromMillisecondsSinceEpoch(
          int.parse(expiresAtStr) * 1000,
        );
      } else {
        // Assume it's ISO string
        expiresAt = DateTime.parse(expiresAtStr);
      }
      if (DateTime.now().toUtc().isAfter(expiresAt)) {
        _logout();
      }
    } catch (e) {
      // Invalid date format, ignore or logout
    }
  }

  void _logout() async {
    _logoutTimer?.cancel();
    await SharedPreferencesUtils().clearSharedPreferences();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Session expired. Please login again.',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _setSelectedDate(picked);
    }
  }

  void _setSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);

    try {
      final data = await api.fetchTasks();

      final tasks = List<Map<String, dynamic>>.from(data).map((task) {
        return {...task, 'isDone': task['isDone'] ?? 0};
      }).toList();

      // 👇 SORT BY created_at (newest first)
      tasks.sort((a, b) {
        final aDate = DateTime.parse(a['created_at']);
        final bDate = DateTime.parse(b['created_at']);
        return bDate.compareTo(aDate); // DESC order
      });

      setState(() {
        _tasks = tasks;
      });
      if (_selectedDate != null) {
        _setSelectedDate(_selectedDate!);
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }

    setState(() => _loading = false);
  }

  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty) return;

    try {
      final response = await api.createTask({
        'title': title,
        'content': desc,
        'isDone': 0,
      });

      final newTask = Map<String, dynamic>.from(response['data']);

      final safeTask = {...newTask, 'isDone': newTask['isDone'] ?? 0};

      setState(() {
        _tasks.insert(0, safeTask);
      });

      if (_selectedDate != null) {
        _setSelectedDate(_selectedDate!);
      }

      _titleController.clear();
      _descController.clear();

      if (!mounted) return;

      // ✅ SUCCESS SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Task created',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ❌ ERROR SNACKBAR
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleTask(int index) async {
    final oldTask = _tasks[index];

    final current = _isDone(oldTask['isDone']);
    final newValue = !current;

    setState(() {
      _tasks[index] = {...oldTask, 'isDone': newValue};
    });

    try {
      await api.updateTask(oldTask['id'].toString(), {
        ...oldTask,
        'isDone': newValue,
      });
    } catch (e) {
      debugPrint('Update failed: $e');

      // ❌ rollback if API fails
      setState(() {
        _tasks[index] = oldTask;
      });
    }
  }

  Future<void> _deleteTask(int index) async {
    final messenger = ScaffoldMessenger.of(context);

    final task = _tasks[index];
    final removed = _tasks.removeAt(index);

    setState(() {});

    try {
      final response = await api.deleteTask(task['id'].toString());

      if (!mounted) return;

      // ✅ SUCCESS SNACKBAR
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Task deleted',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // ❌ rollback UI
      setState(() {
        _tasks.insert(index, removed);
      });

      // ❌ ERROR SNACKBAR
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editTask(int index) {
    final task = _tasks[index];

    final editTitle = TextEditingController(text: task['title']);
    final editDesc = TextEditingController(text: task['content']);

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
                        onPressed: () async {
                          final updated = {
                            ...task,
                            'title': editTitle.text.trim(),
                            'content': editDesc.text.trim(),
                          };

                          try {
                            final response = await api.updateTask(
                              task['id'],
                              updated,
                            );

                            if (!mounted) return; // 👈 IMPORTANT

                            final updatedTask = Map<String, dynamic>.from(
                              response['data'],
                            );

                            setState(() {
                              _tasks[index] = {
                                ...updatedTask,
                                'isDone': updatedTask['isDone'] ?? 0,
                              };
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  response['message'] ?? 'Task updated',
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return; // 👈 ALSO HERE

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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

  void _confirmDelete(int index) {
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
                  "Delete Task",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 10),

                /// DESCRIPTION
                const Text(
                  "Are you sure you want to delete this task? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
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

                    /// DELETE
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // close sheet
                          _deleteTask(index); // proceed delete
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Yes, Delete"),
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
              onTap: () => _confirmDelete(index),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do')),

      drawer: AppDrawer(currentRoute: '/todos'),

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
                "Completed: ${_displayTasks.where((task) => _isDone(task['isDone'])).length} / ${_displayTasks.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (_selectedDate != null)
                Text(
                  "Tasks on: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  style: const TextStyle(color: Colors.white),
                ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Select Date"),
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
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _tasks.isEmpty
                        ? const Center(
                            child: Text(
                              'No tasks yet ✨',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _selectedDate == null
                                ? _tasks.length
                                : _displayTasks.length,
                            itemBuilder: (context, index) {
                              final task = _selectedDate == null
                                  ? _tasks[index]
                                  : _displayTasks[index];
                              final isDone = _isDone(task['isDone']);

                              return Container(
                                key: ValueKey(task['id']),
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
                                      value: isDone,
                                      onChanged: (_) => _toggleTask(index),
                                    ),

                                    title: Text(
                                      task['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),

                                    subtitle:
                                        task['content'] != null &&
                                            task['content']
                                                .toString()
                                                .isNotEmpty
                                        ? Text(task['content'])
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
