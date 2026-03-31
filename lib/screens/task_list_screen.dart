import 'package:flutter/material.dart';
import 'package:task_manager_app/database/database_helper.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/screens/task_form_screen.dart';
import 'package:task_manager_app/widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
	const TaskListScreen({super.key});

	@override
	State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
	final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
	List<Task> _tasks = [];

	@override
	void initState() {
		super.initState();
		_loadTasks();
	}

	Future<void> _loadTasks() async {
		final tasks = await _databaseHelper.getTasks();
		setState(() {
			_tasks = tasks;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Task Manager'),
			),
			body: _tasks.isEmpty
				? const Center(child: Text('No tasks yet'))
				: ListView.builder(
					padding: const EdgeInsets.all(16),
					itemCount: _tasks.length,
					itemBuilder: (context, index) {
						return TaskCard(task: _tasks[index]);
					},
				),
			floatingActionButton: FloatingActionButton(
				onPressed: () async {
					final created = await Navigator.push<bool>(
						context,
						MaterialPageRoute(
							builder: (_) => const TaskFormScreen(),
						),
					);

					if (created == true) {
						await _loadTasks();
					}
				},
				child: const Icon(Icons.add),
			),
		);
	}
}
