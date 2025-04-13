class Task {
  int? id;
  String title;
  String startDate;
  String endDate;
  String priority;
  int completed;
  String color;  // Menambahkan properti color

  Task({
    this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.completed,
    required this.color,  // Menambahkan parameter untuk color
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'priority': priority,
      'completed': completed,
      'color': color,  // Menambahkan color ke dalam Map
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      priority: map['priority'],
      completed: map['completed'],
      color: map['color'],  // Menambahkan color dari Map
    );
  }
}
