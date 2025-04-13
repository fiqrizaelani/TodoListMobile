import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/task_models.dart';
import 'DatabaseHelper.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>(); // Key untuk Form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String _priority = "Low";

  @override
  void dispose() {
    _titleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
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

        String formattedDate = DateFormat('dd MMM, HH:mm').format(fullDateTime);
        setState(() {
          controller.text = formattedDate;
        });
      }
    }
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

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      int colorHex = colorToHex(_priority);
      Task newTask = Task(
        title: _titleController.text,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        priority: _priority,
        completed: 0,
        color: colorHex.toRadixString(16).padLeft(8, '0'),
      );

      await DatabaseHelper().insertTask(newTask);
      Navigator.pop(context, newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade700,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        elevation: 0,
        title: const Text("Add Task", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Task Title"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Task Title is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startDateController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Start Date"),
                readOnly: true,
                onTap: () => _selectDateTime(_startDateController),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Start Date must be filled in";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _endDateController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("End Date"),
                readOnly: true,
                onTap: () => _selectDateTime(_endDateController),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "End Date must be filled in";
                  }
                  return null;
                },
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
                  onPressed: _addTask,
                  child: const Text(
                    "Add Task",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
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
