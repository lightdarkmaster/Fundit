import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:fundit/models/goal_model.dart';
// import 'package:fundit/models/history_entry_model.dart'; // Keep this if you use it later

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = p.join(await getDatabasesPath(), 'goals.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            saved REAL NOT NULL,
            imagePath TEXT,
            createdAt TEXT,
            description TEXT,
            priority TEXT,
            estimatedDate TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Goal>> fetchGoals() async {
    final db = await database;
    final result = await db.query('goals', orderBy: 'id DESC');
    return result.map((e) => Goal.fromMap(e)).toList();
  }
}
