import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// ignore: unused_import
import 'task_models.dart'; // Import your task model if needed

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();

  static Database? _db; // Ganti jadi nullable

  Future<Database> get database async {
    if (_db != null) return _db!; // jika sudah ada, langsung kembalikan
    _db = await _initDB(); // kalau belum, inisialisasi dulu
    return _db!;
  }

  // Inisialisasi database
  Future<Database> _initDB() async {
  var path = await getDatabasesPath();
  return await openDatabase(
    join(path, 'task_database.db'),
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, startDate TEXT, endDate TEXT, priority TEXT, completed INTEGER, color TEXT)',  // Menambahkan kolom color
      );
    },
    version: 1,
  );
}


  Future<List<Task>> getTasks() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('tasks');

  return List.generate(maps.length, (i) {
    return Task.fromMap(maps[i]); // ✅ Konversi manual
  });
}


  // Menambahkan tugas ke dalam database
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Memperbarui tugas dalam database
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Menghapus tugas dari database
  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
