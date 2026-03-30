import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
}
