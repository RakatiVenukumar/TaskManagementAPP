import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager_app/main.dart';

void main() {
  testWidgets('Task Manager basic screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
