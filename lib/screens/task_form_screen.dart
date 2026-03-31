import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/database/database_helper.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/utils/task_status.dart';

class TaskFormScreen extends StatefulWidget {
	const TaskFormScreen({
		super.key,
		this.existingTask,
		required this.availableTasks,
	});

	final Task? existingTask;
	final List<Task> availableTasks;

	@override
	State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
	static const String _draftTitleKey = 'task_form_draft_title';
	static const String _draftDescriptionKey = 'task_form_draft_description';

	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	final TextEditingController _titleController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	DateTime? _selectedDueDate;
	TaskStatus _selectedStatus = TaskStatus.todo;
	int? _selectedBlockedById;
	String? _dueDateError;
	bool _isSaving = false;

	bool get _isEditMode => widget.existingTask != null;

	@override
	void initState() {
		super.initState();
		_titleController.addListener(_saveDraft);
		_descriptionController.addListener(_saveDraft);

		if (widget.existingTask != null) {
			_titleController.text = widget.existingTask!.title;
			_descriptionController.text = widget.existingTask!.description;
			_selectedDueDate = widget.existingTask!.dueDate;
			_selectedStatus = widget.existingTask!.status;
			_selectedBlockedById = widget.existingTask!.blockedBy;
		} else {
			_loadDraft();
		}
	}

	Future<void> _loadDraft() async {
		final prefs = await SharedPreferences.getInstance();
		final draftTitle = prefs.getString(_draftTitleKey) ?? '';
		final draftDescription = prefs.getString(_draftDescriptionKey) ?? '';

		if (!mounted) {
			return;
		}

		setState(() {
			_titleController.text = draftTitle;
			_descriptionController.text = draftDescription;
		});
	}

	Future<void> _saveDraft() async {
		if (_isEditMode) {
			return;
		}

		final prefs = await SharedPreferences.getInstance();
		await prefs.setString(_draftTitleKey, _titleController.text);
		await prefs.setString(_draftDescriptionKey, _descriptionController.text);
	}

	Future<void> _clearDraft() async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.remove(_draftTitleKey);
		await prefs.remove(_draftDescriptionKey);
	}

	Future<void> _pickDueDate() async {
		final now = DateTime.now();
		final pickedDate = await showDatePicker(
			context: context,
			initialDate: _selectedDueDate ?? now,
			firstDate: now.subtract(const Duration(days: 365)),
			lastDate: now.add(const Duration(days: 3650)),
		);

		if (pickedDate != null) {
			setState(() {
				_selectedDueDate = pickedDate;
				_dueDateError = null;
			});
		}
	}

	Future<void> _onSave() async {
		if (_isSaving) {
			return;
		}

		final isFormValid = _formKey.currentState?.validate() ?? false;
		setState(() {
			_dueDateError = _selectedDueDate == null ? 'Due date is required' : null;
		});

		if (!isFormValid || _selectedDueDate == null) {
			return;
		}

		setState(() {
			_isSaving = true;
		});

		try {
			Future<void> saveOperation() async {
				if (_isEditMode) {
					await Future<void>.delayed(const Duration(seconds: 2));

					final updatedTask = widget.existingTask!.copyWith(
						title: _titleController.text.trim(),
						description: _descriptionController.text.trim(),
						dueDate: _selectedDueDate!,
						status: _selectedStatus,
						blockedBy: _selectedBlockedById,
					);
					await DatabaseHelper.instance.updateTask(updatedTask);
					return;
				}

				await Future<void>.delayed(const Duration(seconds: 2));

				final task = Task(
					title: _titleController.text.trim(),
					description: _descriptionController.text.trim(),
					dueDate: _selectedDueDate!,
					status: _selectedStatus,
					blockedBy: _selectedBlockedById,
				);
				await DatabaseHelper.instance.insertTask(task);
				await _clearDraft();
			}

			await saveOperation().timeout(const Duration(seconds: 15));

			if (!mounted) {
				return;
			}

			Navigator.pop(context, _isEditMode ? 'updated' : 'created');
		} on TimeoutException catch (error, stackTrace) {
			debugPrint('Task save timed out: $error');
			debugPrintStack(stackTrace: stackTrace);

			if (!mounted) {
				return;
			}

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: const Text(
						'Saving task is taking too long. Please try again.',
					),
					backgroundColor: Colors.red.shade700,
				),
			);
		} catch (error, stackTrace) {
			debugPrint('Task save failed: $error');
			debugPrintStack(stackTrace: stackTrace);

			if (!mounted) {
				return;
			}

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text(
						_isEditMode
							? 'Could not update task. Please try again.'
							: 'Could not create task. Please try again.',
					),
					backgroundColor: Colors.red.shade700,
				),
			);
		} finally {
			if (mounted) {
				setState(() {
					_isSaving = false;
				});
			}
		}
	}

	@override
	void dispose() {
		_titleController.removeListener(_saveDraft);
		_descriptionController.removeListener(_saveDraft);
		_titleController.dispose();
		_descriptionController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final blockedByOptions = widget.availableTasks.where((task) {
			if (!_isEditMode) {
				return true;
			}

			return task.id != widget.existingTask!.id;
		}).toList();

		final dueDateText = _selectedDueDate == null
			? 'Select due date'
			: DateFormat('dd MMM yyyy').format(_selectedDueDate!);

		return Scaffold(
			appBar: AppBar(
				title: Text(_isEditMode ? 'Edit Task' : 'Create Task'),
			),
			body: Form(
				key: _formKey,
				child: ListView(
					padding: const EdgeInsets.all(16),
					children: [
						TextFormField(
							controller: _titleController,
							decoration: const InputDecoration(
								labelText: 'Title',
								border: OutlineInputBorder(),
							),
							validator: (value) {
								if (value == null || value.trim().isEmpty) {
									return 'Title is required';
								}
								return null;
							},
						),
						const SizedBox(height: 12),
						TextField(
							controller: _descriptionController,
							maxLines: 4,
							decoration: const InputDecoration(
								labelText: 'Description',
								border: OutlineInputBorder(),
							),
						),
						const SizedBox(height: 12),
						ListTile(
							contentPadding: const EdgeInsets.symmetric(horizontal: 12),
							title: const Text('Due Date'),
							subtitle: Text(dueDateText),
							trailing: const Icon(Icons.calendar_today_outlined),
							onTap: _isSaving ? null : _pickDueDate,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(6),
								side: BorderSide(
										color: _dueDateError == null ? Colors.grey : Colors.red,
								),
							),
						),
						if (_dueDateError != null) ...[
							const SizedBox(height: 6),
							Text(
								_dueDateError!,
								style: TextStyle(
									color: Theme.of(context).colorScheme.error,
									fontSize: 12,
								),
							),
						],
						const SizedBox(height: 12),
						DropdownButtonFormField<TaskStatus>(
							initialValue: _selectedStatus,
							decoration: const InputDecoration(
								labelText: 'Status',
								border: OutlineInputBorder(),
							),
							items: TaskStatus.values.map((status) {
								return DropdownMenuItem<TaskStatus>(
									value: status,
									child: Text(status.toDisplayLabel()),
								);
							}).toList(),
							onChanged: (value) {
								if (_isSaving) {
									return;
								}

								if (value != null) {
									setState(() {
										_selectedStatus = value;
									});
								}
							},
						),
						const SizedBox(height: 12),
						DropdownButtonFormField<int?>(
							initialValue: _selectedBlockedById,
							decoration: const InputDecoration(
								labelText: 'Blocked By (Optional)',
								border: OutlineInputBorder(),
								isDense: true,
							),
							items: [
								const DropdownMenuItem<int?>(
									value: null,
									child: Text('None'),
								),
								...blockedByOptions.map((task) {
									return DropdownMenuItem<int?>(
										value: task.id,
										child: Text(task.title),
									);
								}),
							],
							onChanged: (value) {
								if (_isSaving) {
									return;
								}

								setState(() {
									_selectedBlockedById = value;
								});
							},
						),
						const SizedBox(height: 20),
						SizedBox(
							height: 48,
							child: ElevatedButton(
								onPressed: _isSaving ? null : _onSave,
								child: _isSaving
									? const SizedBox(
										height: 20,
										width: 20,
										child: CircularProgressIndicator(strokeWidth: 2.2),
									)
									: Text(_isEditMode ? 'Update' : 'Save'),
							),
						),
					],
				),
			),
		);
	}
}
