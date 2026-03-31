import 'dart:convert';

import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager_app/models/task.dart';

class DatabaseHelper {
	DatabaseHelper._internal();

	static const String _webTasksStorageKey = 'tasks_web_storage_v1';

	static final DatabaseHelper instance = DatabaseHelper._internal();

	static Database? _database;

	Future<Database> get database async {
		if (kIsWeb) {
			throw UnsupportedError('SQLite is not used on web for this app');
		}

		if (_database != null) {
			return _database!;
		}

		_database = await _initDatabase();
		return _database!;
	}

	Future<Database> _initDatabase() async {
		final path = join(await getDatabasesPath(), 'task_manager.db');

		return openDatabase(
			path,
			version: 2,
			onCreate: _onCreate,
			onUpgrade: _onUpgrade,
			onOpen: (db) async {
				await _ensureTasksTableSchema(db);
			},
		);
	}

	Future<void> _onCreate(Database db, int version) async {
		await db.execute('''
			CREATE TABLE tasks (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				title TEXT NOT NULL,
				description TEXT NOT NULL,
				dueDate TEXT NOT NULL,
				status TEXT NOT NULL,
				blockedBy INTEGER,
				FOREIGN KEY (blockedBy) REFERENCES tasks (id) ON DELETE SET NULL
			)
		''');
	}

	Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
		await _ensureTasksTableSchema(db);
	}

	Future<void> _ensureTasksTableSchema(Database db) async {
		final taskTableCheck = await db.rawQuery(
			"SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'tasks'",
		);

		if (taskTableCheck.isEmpty) {
			await _onCreate(db, 2);
			return;
		}

		final existingColumns = await _getExistingColumns(db, 'tasks');

		if (!existingColumns.contains('title')) {
			await db.execute("ALTER TABLE tasks ADD COLUMN title TEXT NOT NULL DEFAULT ''");
		}

		if (!existingColumns.contains('description')) {
			await db.execute(
				"ALTER TABLE tasks ADD COLUMN description TEXT NOT NULL DEFAULT ''",
			);
		}

		if (!existingColumns.contains('dueDate')) {
			await db.execute(
				"ALTER TABLE tasks ADD COLUMN dueDate TEXT NOT NULL DEFAULT '1970-01-01T00:00:00.000'",
			);
		}

		if (!existingColumns.contains('status')) {
			await db.execute(
				"ALTER TABLE tasks ADD COLUMN status TEXT NOT NULL DEFAULT 'todo'",
			);
		}

		if (!existingColumns.contains('blockedBy')) {
			await db.execute('ALTER TABLE tasks ADD COLUMN blockedBy INTEGER');
		}
	}

	Future<Set<String>> _getExistingColumns(Database db, String tableName) async {
		final columns = await db.rawQuery('PRAGMA table_info($tableName)');
		return columns.map((column) => column['name'] as String).toSet();
	}

	Future<int> insertTask(Task task) async {
		if (kIsWeb) {
			return _insertTaskWeb(task);
		}

		final db = await database;
		return db.insert('tasks', task.toMap());
	}

	Future<List<Task>> getTasks() async {
		if (kIsWeb) {
			return _getTasksWeb();
		}

		final db = await database;
		final List<Map<String, dynamic>> maps = await db.query('tasks');

		return maps.map((map) => Task.fromMap(map)).toList();
	}

	Future<int> updateTask(Task task) async {
		if (kIsWeb) {
			return _updateTaskWeb(task);
		}

		final db = await database;

		return db.update(
			'tasks',
			task.toMap(),
			where: 'id = ?',
			whereArgs: [task.id],
		);
	}

	Future<int> deleteTask(int id) async {
		if (kIsWeb) {
			return _deleteTaskWeb(id);
		}

		final db = await database;

		return db.delete(
			'tasks',
			where: 'id = ?',
			whereArgs: [id],
		);
	}

	Future<List<Map<String, dynamic>>> _readWebTaskMaps() async {
		final prefs = await SharedPreferences.getInstance();
		final raw = prefs.getString(_webTasksStorageKey);

		if (raw == null || raw.isEmpty) {
			return <Map<String, dynamic>>[];
		}

		final decoded = jsonDecode(raw);
		if (decoded is! List) {
			return <Map<String, dynamic>>[];
		}

		return decoded
				.cast<Map<dynamic, dynamic>>()
				.map(
					(item) => item.map(
						(key, value) => MapEntry(key.toString(), value),
					),
				)
				.toList();
	}

	Future<void> _writeWebTaskMaps(List<Map<String, dynamic>> maps) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString(_webTasksStorageKey, jsonEncode(maps));
	}

	Future<int> _insertTaskWeb(Task task) async {
		final maps = await _readWebTaskMaps();
		final nextId = maps.isEmpty
				? 1
				: maps
						.map((item) => (item['id'] as int?) ?? 0)
						.reduce((a, b) => a > b ? a : b) +
					1;

		maps.add(
			task.copyWith(id: nextId).toMap(),
		);
		await _writeWebTaskMaps(maps);
		return nextId;
	}

	Future<List<Task>> _getTasksWeb() async {
		final maps = await _readWebTaskMaps();
		return maps.map(Task.fromMap).toList();
	}

	Future<int> _updateTaskWeb(Task task) async {
		if (task.id == null) {
			return 0;
		}

		final maps = await _readWebTaskMaps();
		final index = maps.indexWhere((item) => item['id'] == task.id);
		if (index == -1) {
			return 0;
		}

		maps[index] = task.toMap();
		await _writeWebTaskMaps(maps);
		return 1;
	}

	Future<int> _deleteTaskWeb(int id) async {
		final maps = await _readWebTaskMaps();
		final beforeCount = maps.length;
		maps.removeWhere((item) => item['id'] == id);

		if (maps.length == beforeCount) {
			return 0;
		}

		for (final taskMap in maps) {
			if (taskMap['blockedBy'] == id) {
				taskMap['blockedBy'] = null;
			}
		}

		await _writeWebTaskMaps(maps);
		return 1;
	}
}
