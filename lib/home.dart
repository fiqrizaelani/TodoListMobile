import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'DatabaseHelper.dart';
import 'edit_task.dart';
import 'add_task.dart';
import 'task_models.dart'; 
import 'delete_task.dart';

Color getColorFromPriority(String priority) {
  switch (priority) {
    case 'High':
      return const Color(0xFFFF5252); // merah
    case 'Medium':
      return const Color(0xFFFFA726); // oranye
    case 'Low':
    default:
      return const Color(0xFF66BB6A); // hijau
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final fetchedTasks = await DatabaseHelper().getTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  double _calculateProgress() {
    if (tasks.isEmpty) return 0.0;
    int completedTasks = tasks.where((task) => task.completed == 1).length;
    return completedTasks / tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade700,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
        title: const Text(
          "Todo List",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress Indicator Bulat
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 10.0,
                animation: true,
                percent: _calculateProgress(),
                center: Text(
                  "${(_calculateProgress() * 100).toInt()}%",
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.white,
                backgroundColor: Colors.white24,
              ),
            ),

            // Daftar Tugas
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    color: Color(int.tryParse(task.color, radix: 16) ?? 0xFF000000),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Checkbox(
                        value: task.completed == 1,
                        onChanged: (bool? value) async {
                          task.completed = value == true ? 1 : 0;
                          await DatabaseHelper().updateTask(task);
                          _loadTasks();
                        },
                      ),
                      title: Text(
                        task.title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Start: ${task.startDate}", style: const TextStyle(color: Colors.white70)),
                          Text("End: ${task.endDate}", style: const TextStyle(color: Colors.white70)),
                          Text(
                            "Priority: ${task.priority}",
                            style: TextStyle(color: getColorFromPriority(task.priority), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () async {
                              final updatedTask = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskPage(task: task),
                                ),
                              );
                              if (updatedTask != null) {
                                await DatabaseHelper().updateTask(updatedTask);
                                _loadTasks();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () async {
                              final shouldDelete = await showDeleteConfirmationDialog(context);
                              if (shouldDelete == true && task.id != null) {
                                await DatabaseHelper().deleteTask(task.id!);
                                _loadTasks();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskPage(),
            ),
          );
          if (newTask != null) {
            _loadTasks();
          }
        },
        child: const Icon(Icons.add, color: Colors.purple),
      ),
    );
  }
}
