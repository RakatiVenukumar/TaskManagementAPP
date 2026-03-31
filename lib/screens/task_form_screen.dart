import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/utils/task_status.dart';

class TaskFormScreen extends StatefulWidget {
	const TaskFormScreen({super.key});

	@override
	State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	final TextEditingController _titleController = TextEditingController();
	final TextEditingController _descriptionController = TextEditingController();
	DateTime? _selectedDueDate;
	TaskStatus _selectedStatus = TaskStatus.todo;
	String? _dueDateError;

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

	void _onSave() {
		final isFormValid = _formKey.currentState?.validate() ?? false;
		setState(() {
			_dueDateError = _selectedDueDate == null ? 'Due date is required' : null;
		});

		if (!isFormValid || _selectedDueDate == null) {
			return;
		}

		// Save logic will be added in later steps.
	}

	@override
	void dispose() {
		_titleController.dispose();
		_descriptionController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final dueDateText = _selectedDueDate == null
			? 'Select due date'
			: DateFormat('dd MMM yyyy').format(_selectedDueDate!);

		return Scaffold(
			appBar: AppBar(
				title: const Text('Create Task'),
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
							onTap: _pickDueDate,
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
								if (value != null) {
									setState(() {
										_selectedStatus = value;
									});
								}
							},
						),
						const SizedBox(height: 20),
						SizedBox(
							height: 48,
							child: ElevatedButton(
								onPressed: _onSave,
								child: const Text('Save'),
							),
						),
					],
				),
			),
		);
	}
}
