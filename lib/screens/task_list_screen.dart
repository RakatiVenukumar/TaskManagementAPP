import 'dart:async';

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
	final TextEditingController _searchController = TextEditingController();
	List<Task> _tasks = [];
	bool _isLoading = true;
	String _searchQuery = '';
	String _debouncedSearchQuery = '';
	Timer? _searchDebounce;
	TaskStatus? _selectedStatusFilter;

	@override
	void initState() {
		super.initState();
		_loadTasks();
	}

	void _showMessage(String message, {bool isError = false}) {
		if (!mounted) {
			return;
		}

		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: isError ? Colors.red.shade700 : null,
			),
		);
	}

	Future<void> _loadTasks() async {
		try {
			final tasks = await _databaseHelper.getTasks();
			if (!mounted) {
				return;
			}

			setState(() {
				_tasks = tasks;
				_isLoading = false;
			});
		} catch (_) {
			if (!mounted) {
				return;
			}

			setState(() {
				_isLoading = false;
			});
			_showMessage('Failed to load tasks. Please try again.', isError: true);
		}
	}

	void _onSearchChanged(String value) {
		setState(() {
			_searchQuery = value;
		});

		_searchDebounce?.cancel();
		_searchDebounce = Timer(const Duration(milliseconds: 300), () {
			if (!mounted) {
				return;
			}

			setState(() {
				_debouncedSearchQuery = _searchQuery;
			});
		});
	}

	@override
	void dispose() {
		_searchDebounce?.cancel();
		_searchController.dispose();
		super.dispose();
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

		try {
			await _databaseHelper.deleteTask(task.id!);
			await _loadTasks();
			_showMessage('Task deleted');
		} catch (_) {
			_showMessage('Could not delete task.', isError: true);
		}
	}

	Widget _buildEmptyState({required bool hasFilters}) {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(24),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(
							hasFilters ? Icons.filter_alt_off_outlined : Icons.task_alt,
							size: 56,
							color: Colors.grey.shade500,
						),
						const SizedBox(height: 12),
						Text(
							hasFilters ? 'No tasks found' : 'No tasks yet',
							style: Theme.of(context).textTheme.titleMedium,
						),
						const SizedBox(height: 6),
						Text(
							hasFilters
								? 'Try a different search text or status filter.'
								: 'Tap the + button to create your first task.',
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodyMedium,
						),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final visibleTasks = _tasks.where((task) {
			final query = _debouncedSearchQuery.trim().toLowerCase();
			final matchesSearch = query.isEmpty ||
				task.title.toLowerCase().contains(query);
			final matchesStatus = _selectedStatusFilter == null ||
				task.status == _selectedStatusFilter;

			return matchesSearch && matchesStatus;
		}).toList();
		final hasFilters = _tasks.isNotEmpty && visibleTasks.isEmpty;

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
						padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
						child: Container(
							padding: const EdgeInsets.all(12),
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(14),
								boxShadow: const [
									BoxShadow(
										color: Color(0x14000000),
										blurRadius: 12,
										offset: Offset(0, 4),
									),
								],
							),
							child: Row(
								children: [
									Expanded(
										flex: 3,
										child: TextField(
											controller: _searchController,
											onChanged: _onSearchChanged,
											decoration: const InputDecoration(
												hintText: 'Search by title',
												prefixIcon: Icon(Icons.search),
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
					),
					Expanded(
						child: AnimatedSwitcher(
							duration: const Duration(milliseconds: 240),
							child: _isLoading
								? const Center(
										key: ValueKey('loading'),
										child: CircularProgressIndicator(),
								)
								: visibleTasks.isEmpty
								? _buildEmptyState(hasFilters: hasFilters)
								: ListView.builder(
										key: const ValueKey('task-list'),
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
										searchQuery: _debouncedSearchQuery,
										isBlocked: isBlocked,
										animationDelay: Duration(milliseconds: 28 * index),
										onTap: () async {
											final result = await Navigator.push<String>(
												context,
												MaterialPageRoute(
													builder: (_) => TaskFormScreen(
														existingTask: task,
														availableTasks: _tasks,
													),
												),
											);

											if (result != null) {
												await _loadTasks();
												_showMessage('Task updated');
											}
											},
										onDelete: () => _confirmAndDeleteTask(task),
									);
								},
							),
						),
					),
				],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () async {
				final result = await Navigator.push<String>(
						context,
						MaterialPageRoute(
							builder: (_) => TaskFormScreen(availableTasks: _tasks),
						),
					);

				if (result != null) {
						await _loadTasks();
					_showMessage('Task created');
					}
				},
				child: const Icon(Icons.add),
			),
		);
	}
}
