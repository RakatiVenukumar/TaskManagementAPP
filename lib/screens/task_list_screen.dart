import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
	const TaskListScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Task Manager'),
			),
			body: ListView(
				padding: const EdgeInsets.all(16),
				children: const [],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					// Navigation to task form will be added in Step 16.
				},
				child: const Icon(Icons.add),
			),
		);
	}
}
