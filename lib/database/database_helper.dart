import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager_app/models/task.dart';

class DatabaseHelper {
	DatabaseHelper._internal();

	static final DatabaseHelper instance = DatabaseHelper._internal();

	static Database? _database;

	Future<Database> get database async {
		if (_database != null) {
			return _database!;
		}

		_database = await _initDatabase();
		return _database!;
	}

	Future<Database> _initDatabase() async {
		final dbPath = await getDatabasesPath();
		final path = join(dbPath, 'task_manager.db');

		return openDatabase(
			path,
			version: 1,
			onCreate: _onCreate,
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
				FOREIGN KEY (blockedBy) REFERENCES tasks (id)
			)
		''');
	}

	Future<int> insertTask(Task task) async {
		final db = await database;
		return db.insert('tasks', task.toMap());
	}

	Future<List<Task>> getTasks() async {
		final db = await database;
		final List<Map<String, dynamic>> maps = await db.query('tasks');

		return maps.map((map) => Task.fromMap(map)).toList();
	}

	Future<int> updateTask(Task task) async {
		final db = await database;

		return db.update(
			'tasks',
			task.toMap(),
			where: 'id = ?',
			whereArgs: [task.id],
		);
	}

	Future<int> deleteTask(int id) async {
		final db = await database;

		return db.delete(
			'tasks',
			where: 'id = ?',
			whereArgs: [id],
		);
	}
}
