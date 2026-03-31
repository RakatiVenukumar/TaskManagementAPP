import 'package:flutter/material.dart';
import 'package:task_manager_app/database/database_helper.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/screens/task_form_screen.dart';
import 'package:task_manager_app/utils/task_status.dart';
import 'package:task_manager_app/widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
	const TaskListScreen({super.key});

	@override
	State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
	final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
	List<Task> _tasks = [];
	String _searchQuery = '';
	TaskStatus? _selectedStatusFilter;

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
		final visibleTasks = _tasks.where((task) {
			final query = _searchQuery.trim().toLowerCase();
			final matchesSearch = query.isEmpty ||
				task.title.toLowerCase().contains(query);
			final matchesStatus = _selectedStatusFilter == null ||
				task.status == _selectedStatusFilter;

			return matchesSearch && matchesStatus;
		}).toList();

		final taskById = {
			for (final item in _tasks)
				if (item.id != null) item.id!: item,
		};

		return Scaffold(
			appBar: AppBar(
				title: const Text('Task Manager'),
			),
			body: Column(
				children: [
					Padding(
						padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
						child: Row(
							children: [
								Expanded(
									flex: 3,
									child: TextField(
										onChanged: (value) {
											setState(() {
												_searchQuery = value;
											});
										},
										decoration: const InputDecoration(
											hintText: 'Search by title',
											prefixIcon: Icon(Icons.search),
											border: OutlineInputBorder(),
										),
									),
								),
								const SizedBox(width: 10),
								Expanded(
									flex: 2,
									child: DropdownButtonFormField<TaskStatus?>(
										initialValue: _selectedStatusFilter,
										decoration: const InputDecoration(
											labelText: 'Status',
											border: OutlineInputBorder(),
										),
										items: [
											const DropdownMenuItem<TaskStatus?>(
												value: null,
												child: Text('All'),
											),
											...TaskStatus.values.map((status) {
												return DropdownMenuItem<TaskStatus?>(
													value: status,
													child: Text(status.toDisplayLabel()),
												);
											}),
										],
										onChanged: (value) {
											setState(() {
												_selectedStatusFilter = value;
											});
										},
									),
								),
							],
						),
					),
					Expanded(
						child: visibleTasks.isEmpty
							? Center(
								child: Text(
									_tasks.isEmpty ? 'No tasks yet' : 'No tasks found',
								),
							)
							: ListView.builder(
								padding: const EdgeInsets.all(16),
								itemCount: visibleTasks.length,
								itemBuilder: (context, index) {
									final task = visibleTasks[index];
									final blockedByTask = task.blockedBy == null
										? null
										: taskById[task.blockedBy];
									final isBlocked = blockedByTask != null &&
										blockedByTask.status != TaskStatus.done;

									return TaskCard(
										task: task,
										isBlocked: isBlocked,
										onTap: isBlocked
											? null
											: () async {
											final updated = await Navigator.push<bool>(
												context,
												MaterialPageRoute(
													builder: (_) => TaskFormScreen(
														existingTask: task,
														availableTasks: _tasks,
													),
												),
											);

											if (updated == true) {
												await _loadTasks();
											}
											},
										onDelete: isBlocked ? null : () => _confirmAndDeleteTask(task),
									);
								},
							),
					),
				],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () async {
					final created = await Navigator.push<bool>(
						context,
						MaterialPageRoute(
							builder: (_) => TaskFormScreen(availableTasks: _tasks),
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
