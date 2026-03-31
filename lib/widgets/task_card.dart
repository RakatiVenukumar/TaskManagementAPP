import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/utils/task_status.dart';

class TaskCard extends StatelessWidget {
	const TaskCard({
		super.key,
		required this.task,
		required this.searchQuery,
		this.onTap,
		this.onDelete,
		this.isBlocked = false,
	});

	final Task task;
	final String searchQuery;
	final VoidCallback? onTap;
	final VoidCallback? onDelete;
	final bool isBlocked;

	InlineSpan _buildHighlightedTitle(BuildContext context) {
		final title = task.title;
		final query = searchQuery.trim();

		if (query.isEmpty) {
			return TextSpan(
				text: title,
				style: Theme.of(context).textTheme.titleMedium,
			);
		}

		final lowerTitle = title.toLowerCase();
		final lowerQuery = query.toLowerCase();
		final matchStart = lowerTitle.indexOf(lowerQuery);

		if (matchStart == -1) {
			return TextSpan(
				text: title,
				style: Theme.of(context).textTheme.titleMedium,
			);
		}

		final matchEnd = matchStart + query.length;
		final normalStyle = Theme.of(context).textTheme.titleMedium;
		final highlightStyle = normalStyle?.copyWith(fontWeight: FontWeight.bold);

		return TextSpan(
			style: normalStyle,
			children: [
				TextSpan(text: title.substring(0, matchStart)),
				TextSpan(
					text: title.substring(matchStart, matchEnd),
					style: highlightStyle,
				),
				TextSpan(text: title.substring(matchEnd)),
			],
		);
	}

	@override
	Widget build(BuildContext context) {
		final dueDateText = DateFormat('dd MMM yyyy').format(task.dueDate);

		return Opacity(
			opacity: isBlocked ? 0.5 : 1,
			child: Card(
				margin: const EdgeInsets.only(bottom: 12),
				color: isBlocked ? Colors.grey.shade200 : null,
				child: InkWell(
					onTap: onTap,
					borderRadius: BorderRadius.circular(12),
					child: Padding(
						padding: const EdgeInsets.all(14),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Expanded(
											child: RichText(
												text: _buildHighlightedTitle(context),
											),
										),
										IconButton(
											onPressed: onDelete,
											icon: const Icon(Icons.delete_outline),
											tooltip: 'Delete task',
										),
									],
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
			),
		);
	}
}
