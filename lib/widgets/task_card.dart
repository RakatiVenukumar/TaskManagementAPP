import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_app/models/task.dart';
import 'package:task_manager_app/utils/task_status.dart';

class TaskCard extends StatelessWidget {
	const TaskCard({
		super.key,
		required this.task,
		required this.searchQuery,
		required this.animationDelay,
		this.onTap,
		this.onDelete,
		this.isBlocked = false,
	});

	final Task task;
	final String searchQuery;
	final Duration animationDelay;
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
		final statusColor = switch (task.status) {
			TaskStatus.todo => Colors.blue.shade700,
			TaskStatus.inProgress => Colors.orange.shade700,
			TaskStatus.done => Colors.green.shade700,
		};

		return TweenAnimationBuilder<double>(
			tween: Tween<double>(begin: 0.0, end: 1.0),
			duration: const Duration(milliseconds: 220),
			curve: Curves.easeOut,
			builder: (context, value, child) {
				return Opacity(
					opacity: value * (isBlocked ? 0.6 : 1.0),
					child: Transform.translate(
						offset: Offset(0, 12 * (1 - value)),
						child: child,
					),
				);
			},
			child: Card(
				margin: const EdgeInsets.only(bottom: 14),
				color: isBlocked ? const Color(0xFFF1F3F2) : Colors.white,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
				child: InkWell(
					onTap: onTap,
					borderRadius: BorderRadius.circular(14),
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Expanded(
											child: RichText(text: _buildHighlightedTitle(context)),
										),
										IconButton(
											onPressed: onDelete,
											icon: const Icon(Icons.delete_outline),
											tooltip: 'Delete task',
										),
									],
								),
								if (task.description.trim().isNotEmpty) ...[
									const SizedBox(height: 6),
									Text(
										task.description.trim(),
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
									),
								],
								const SizedBox(height: 8),
								Wrap(
									spacing: 8,
									runSpacing: 8,
									children: [
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
											decoration: BoxDecoration(
												color: statusColor.withValues(alpha: 0.12),
												borderRadius: BorderRadius.circular(999),
											),
											child: Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Icon(Icons.flag_outlined, size: 14, color: statusColor),
													const SizedBox(width: 6),
													Text(
														task.status.toDisplayLabel(),
														style: TextStyle(color: statusColor),
													),
												],
											),
										),
										if (isBlocked)
											Container(
												padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
												decoration: BoxDecoration(
													color: const Color(0xFFDADFDB),
													borderRadius: BorderRadius.circular(999),
												),
												child: const Row(
													mainAxisSize: MainAxisSize.min,
													children: [
														Icon(Icons.lock_outline, size: 14, color: Color(0xFF46504A)),
														SizedBox(width: 6),
														Text('Blocked', style: TextStyle(color: Color(0xFF46504A))),
													],
												),
											),
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
