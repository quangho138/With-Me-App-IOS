import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // --- ValueNotifier to notify username changes ---
  final ValueNotifier<String?> userNameNotifier = ValueNotifier(null);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    await _loadUserNameNotifier(); // initialize the notifier
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      // On web there is no file system. The web database factory stores the
      // database inside the browser using just this name.
      path = 'reflections.db';
    } else {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'reflections.db');
    }

    return await openDatabase(
      path,
      version: 3, // incremented version to ensure users table exists
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reflections(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        who TEXT NOT NULL,
        what TEXT NOT NULL,
        when_question TEXT NOT NULL,
        where_question TEXT NOT NULL,
        why_question TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    // Database and table created successfully

    await db.execute('''
    CREATE TABLE moods(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL UNIQUE,
      mood TEXT NOT NULL,
      createdAt TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE control_gauge(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL UNIQUE,
      level INTEGER NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS stressors(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      category TEXT NOT NULL,
      detail TEXT
    )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    print('Database and tables created!');
    await db.execute('''CREATE TABLE user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
        ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE reflections ADD COLUMN date TEXT');
      // Database upgraded: Added "date" column
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
      print('Database upgraded: Added users table.');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE user(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');
    }
  }

  // --- User methods ---
  Future<int> saveUserName(String name) async {
    final db = await database;
    await db.delete('user'); // keep only one user
    final id = await db.insert('user', {'name': name});
    userNameNotifier.value = name; // notify listeners immediately
    return id;
  }

  Future<String?> getUserName() async {
    final db = await database;
    final result = await db.query('user', limit: 1);
    if (result.isNotEmpty) return result.first['name'] as String?;
    return null;
  }

  Future<void> deleteUserName() async {
    final db = await database;
    await db.delete('user');
    userNameNotifier.value = null; // notify listeners immediately
  }

  Future<void> _loadUserNameNotifier() async {
    userNameNotifier.value = await getUserName();
  }

  // Reflection methods remain unchanged
  // --- Keep your existing reflection methods as-is ---
  Future<int> insertReflection({
    required String who,
    required String what,
    required String when,
    required String where,
    required String why,
    required DateTime date,
  }) async {
    final db = await database;
    return await db.insert(
      'reflections',
      {
        'who': who,
        'what': what,
        'when_question': when,
        'where_question': where,
        'why_question': why,
        'date': date.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> clearReflections() async {
    final db = await database;
    return await db.delete('reflections');
  }

  Future<void> deleteAllData() async {
    await clearReflections();
    await deleteUserName();
  }

  Future<List<Map<String, dynamic>>> getReflections() async {
    final db = await database;
    return await db.query('reflections', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getReflectionsByDate(DateTime date) async {
    final db = await database;
    String isoDate = date.toIso8601String().substring(0, 10);
    return await db.query(
      'reflections',
      where: 'date LIKE ?',
      whereArgs: ['$isoDate%'],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> deleteReflectionsByDate(DateTime date) async {
    final db = await database;
    String isoDate = date.toIso8601String().substring(0, 10);
    return await db.delete(
      'reflections',
      where: 'date LIKE ?',
      whereArgs: ['$isoDate%'],
    );
  }

  // USER AUTH
  Future<int> insertUser(String email, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Mood Selection
  Future<int> insertMood(DateTime date, String mood) async {
    final db = await database;
    return await db.insert(
      'moods',
      {
        'date': date.toIso8601String().substring(0, 10),
        'mood': mood,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get mood for a specific date
  Future<String?> getMood(DateTime date) async {
    final db = await database;
    String isoDate = date.toIso8601String().substring(0, 10);
    final result = await db.query(
      'moods',
      where: 'date = ?',
      whereArgs: [isoDate],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['mood'] as String : null;
  }

  // Delete mood for a date
  Future<void> deleteMood(DateTime date) async {
    final db = await database;
    await db.delete(
      'moods',
      where: 'date LIKE ?',
      whereArgs: [date.toIso8601String().substring(0, 10) + '%'],
    );
  }

  // Control Gauge
  Future<int> insertControlGauge(DateTime date, int level) async {
    final db = await database;
    String isoDate = date.toIso8601String().substring(0, 10);
    return await db.insert(
      'control_gauge',
      {'date': isoDate, 'level': level},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getControlGauge(DateTime date) async {
    final db = await database;
    String isoDate = date.toIso8601String().substring(0, 10);
    final result = await db.query(
      'control_gauge',
      where: 'date = ?',
      whereArgs: [isoDate],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['level'] as int;
    }
    return null;
  }

  // Delete control gauge value for a date
  Future<int> deleteControlGauge(DateTime date) async {
    final db = await database;
    String isoDate = date.toIso8601String().substring(0, 10);
    return await db.delete(
      'control_gauge',
      where: 'date LIKE ?',
      whereArgs: ['$isoDate%'],
    );
  }

  // Stressor activity

  // Insert or update stressor
  Future<void> insertStressor(DateTime date, String category, {String? detail}) async {
    final db = await database;
    await db.insert(
      'stressors',
      {
        'date': date.toIso8601String().substring(0,10),
        'category': category,
        'detail': detail,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get stressor by date
    Future<Map<String, dynamic>?> getStressor(DateTime date) async {
      final db = await database;
      final result = await db.query(
        'stressors',
        where: 'date LIKE ?',
        whereArgs: ['${date.toIso8601String().substring(0,10)}%'],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    }

  // Update detail for stressor
    Future<void> updateStressorDetail(DateTime date, String detail) async {
      final db = await database;
      await db.update(
        'stressors',
        {'detail': detail},
        where: 'date LIKE ?',
        whereArgs: ['${date.toIso8601String().substring(0,10)}%'],
      );
    }

  // Delete stressor entry
    Future<int> deleteStressor(DateTime date) async {
      final db = await database;
      return await db.delete(
        'stressors',
        where: 'date LIKE ?',
        whereArgs: ['${date.toIso8601String().substring(0,10)}%'],
      );
    }

}
