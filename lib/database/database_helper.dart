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
		// Table creation will be added in Step 8.
	}
}
