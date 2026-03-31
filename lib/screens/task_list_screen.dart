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

	Future<void> _confirmAndDeleteTask(Task task) async {
		final shouldDelete = await showDialog<bool>(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: const Text('Delete Task'),
					content: Text('Are you sure you want to delete "${task.title}"?'),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context, false),
							child: const Text('Cancel'),
						),
						TextButton(
							onPressed: () => Navigator.pop(context, true),
							child: const Text('Delete'),
						),
					],
				);
			},
		);

		if (shouldDelete != true) {
			return;
		}

		await _databaseHelper.deleteTask(task.id!);
		await _loadTasks();
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
						final task = _tasks[index];
						return TaskCard(
							task: task,
							onTap: () async {
								final updated = await Navigator.push<bool>(
									context,
									MaterialPageRoute(
										builder: (_) => TaskFormScreen(existingTask: task),
									),
								);

								if (updated == true) {
									await _loadTasks();
								}
							},
							onDelete: () => _confirmAndDeleteTask(task),
						);
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
