import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Root App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App Pemula',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

// Model class untuk Task
class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  void toggle() {
    isCompleted = !isCompleted;
  }

  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}

// StatefulWidget agar bisa menyimpan list task
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> tasks = [];
  final TextEditingController taskController = TextEditingController();

  // Tambah task baru dengan validasi
  void addTask() {
    String newTaskTitle = taskController.text.trim();

    // Validasi 1: kosong
    if (newTaskTitle.isEmpty) {
      _showSnackBar(Icons.warning, 'Task tidak boleh kosong!', Colors.orange);
      return;
    }

    // Validasi 2: duplikat
    bool isDuplicate = tasks.any(
        (task) => task.title.toLowerCase() == newTaskTitle.toLowerCase());
    if (isDuplicate) {
      _showSnackBar(Icons.info, 'Task "$newTaskTitle" sudah ada!', Colors.blue);
      return;
    }

    // Validasi 3: panjang karakter
    if (newTaskTitle.length > 100) {
      _showSnackBar(Icons.error,
          'Task terlalu panjang! Maksimal 100 karakter.', Colors.red);
      return;
    }

    // Jika lolos semua validasi
    setState(() {
      tasks.add(Task(title: newTaskTitle));
    });
    taskController.clear();
    _showSnackBar(Icons.check_circle,
        'Task "$newTaskTitle" berhasil ditambahkan!', Colors.green);
  }

  // Toggle status selesai
  void toggleTask(int index) {
    setState(() {
      tasks[index].toggle();
    });

    Task task = tasks[index];
    String message = task.isCompleted
        ? 'Selamat! Task "${task.title}" selesai 🎉'
        : 'Task "${task.title}" ditandai belum selesai';

    _showSnackBar(
        task.isCompleted ? Icons.celebration : Icons.undo,
        message,
        task.isCompleted ? Colors.green : Colors.blue);
  }

  // Hapus task dengan konfirmasi
  Future<void> removeTask(int index) async {
    Task taskToDelete = tasks[index];

    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Text('Apakah kamu yakin ingin menghapus "${taskToDelete.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        tasks.removeAt(index);
      });
      _showSnackBar(
          Icons.delete, 'Task "${taskToDelete.title}" dihapus', Colors.red);
    }
  }

  // Helper function SnackBar
  void _showSnackBar(IconData icon, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Widget statistik progress
  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', tasks.length, Icons.list, Colors.blue),
          _buildStatItem('Selesai',
              tasks.where((t) => t.isCompleted).length, Icons.check, Colors.green),
          _buildStatItem('Belum',
              tasks.where((t) => !t.isCompleted).length, Icons.pending, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My To-Do List")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field
            TextField(
              controller: taskController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Ketik task baru di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.edit),
                counterText: '',
                helperText: 'Maksimal 100 karakter',
              ),
              onSubmitted: (value) => addTask(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: addTask,
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
            ),
            const SizedBox(height: 20),

            if (tasks.isNotEmpty) _buildStatsCard(),

            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("Belum ada task"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        Task task = tasks[index];
                        return ListTile(
                          leading: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: task.isCompleted
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(task.isCompleted
                              ? 'Selesai ✅'
                              : 'Belum selesai'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeTask(index),
                          ),
                          onTap: () => toggleTask(index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
