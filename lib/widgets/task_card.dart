import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/utils/task_status.dart';

class TaskCard extends StatelessWidget {
	const TaskCard({super.key, required this.task, this.onTap});

	final Task task;
	final VoidCallback? onTap;

	@override
	Widget build(BuildContext context) {
		final dueDateText = DateFormat('dd MMM yyyy').format(task.dueDate);

		return Card(
			margin: const EdgeInsets.only(bottom: 12),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(12),
				child: Padding(
					padding: const EdgeInsets.all(14),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								task.title,
								style: Theme.of(context).textTheme.titleMedium,
							),
							const SizedBox(height: 8),
							Row(
								children: [
									const Icon(Icons.flag_outlined, size: 18),
									const SizedBox(width: 6),
									Text(task.status.toDisplayLabel()),
								],
							),
							const SizedBox(height: 6),
							Row(
								children: [
									const Icon(Icons.calendar_today_outlined, size: 18),
									const SizedBox(width: 6),
									Text(dueDateText),
								],
							),
						],
					),
				),
			),
		);
	}
}
