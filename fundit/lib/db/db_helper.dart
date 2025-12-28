import 'package:sqflite/sqflite.dart';
import '../models/goal_model.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as p;

import 'package:fundit/models/goal_model.dart';
import 'package:fundit/models/history_entry_model.dart';

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
            createdAt TEXT
          )
        ''');
      },
    );
  }

  // Insert new goal
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update existing goal
  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  // Delete a goal
  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // Fetch all goals
  Future<List<Goal>> fetchGoals() async {
    final db = await database;
    final result = await db.query('goals', orderBy: 'id DESC');
    return result.map((e) => Goal.fromMap(e)).toList();
  }
}
