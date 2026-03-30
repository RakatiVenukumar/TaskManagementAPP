class Task {
	final int? id;
	final String title;
	final String description;
	final DateTime dueDate;
	final String status;
	final int? blockedBy;

	const Task({
		this.id,
		required this.title,
		required this.description,
		required this.dueDate,
		required this.status,
		this.blockedBy,
	});

	Task copyWith({
		int? id,
		String? title,
		String? description,
		DateTime? dueDate,
		String? status,
		int? blockedBy,
	}) {
		return Task(
			id: id ?? this.id,
			title: title ?? this.title,
			description: description ?? this.description,
			dueDate: dueDate ?? this.dueDate,
			status: status ?? this.status,
			blockedBy: blockedBy ?? this.blockedBy,
		);
	}

	// Converts Task object into a DB-friendly map.
	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'title': title,
			'description': description,
			'dueDate': dueDate.toIso8601String(),
			'status': status,
			'blockedBy': blockedBy,
		};
	}

	// Builds a Task object from a DB row map.
	factory Task.fromMap(Map<String, dynamic> map) {
		return Task(
			id: map['id'] as int?,
			title: map['title'] as String,
			description: map['description'] as String,
			dueDate: DateTime.parse(map['dueDate'] as String),
			status: map['status'] as String,
			blockedBy: map['blockedBy'] as int?,
		);
	}
}
