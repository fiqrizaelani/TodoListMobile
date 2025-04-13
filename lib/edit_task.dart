import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DatabaseHelper.dart';
import 'task_models.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  String _priority = "Low";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _startDateController = TextEditingController(text: widget.task.startDate);
    _endDateController = TextEditingController(text: widget.task.endDate);
    _priority = widget.task.priority;
  }

  int colorToHex(String color) {
    switch (color.toLowerCase()) {
      case 'low':
        return 0xFF66BB6A;
      case 'medium':
        return 0xFFFFA726;
      case 'high':
        return 0xFFFF5252;
      default:
        return 0xFF000000;
    }
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        String formattedDate =
            DateFormat('dd MMM, HH:mm').format(fullDateTime);
        setState(() {
          controller.text = formattedDate;
        });
      }
    }
  }

  Future<void> _updateTask() async {
    int colorHex = colorToHex(_priority);
    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      priority: _priority,
      completed: widget.task.completed,
      color: colorHex.toRadixString(16).padLeft(8, '0'),
    );

    await DatabaseHelper().updateTask(updatedTask);
    Navigator.pop(context, updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade700,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
        title: const Text("Edit Task", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Task Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _startDateController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Start Date"),
              readOnly: true,
              onTap: () => _selectDateTime(_startDateController),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _endDateController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("End Date"),
              readOnly: true,
              onTap: () => _selectDateTime(_endDateController),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _priority,
              items: ["Low", "Medium", "High"].map((priority) {
                Color bgColor;
                Color textColor = Colors.black;

                switch (priority) {
                  case "Low":
                    bgColor = const Color(0xFF66BB6A);
                    break;
                  case "Medium":
                    bgColor = const Color(0xFFFFA726);
                    break;
                  case "High":
                    bgColor = const Color(0xFFFF5252);
                    textColor = Colors.white;
                    break;
                  default:
                    bgColor = Colors.grey;
                }

                return DropdownMenuItem<String>(
                  value: priority,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _priority = newValue!;
                });
              },
              dropdownColor: Colors.white,
              decoration: _inputDecoration("Priority"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _updateTask,
                child: const Text(
                  "Save Task",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.white24,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
