enum TaskStatus { todo, inProgress, done }

extension TaskStatusX on TaskStatus {
  String toStorageValue() {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }

  String toDisplayLabel() {
    switch (this) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }
}

TaskStatus taskStatusFromStorage(String value) {
  switch (value) {
    case 'todo':
      return TaskStatus.todo;
    case 'in_progress':
      return TaskStatus.inProgress;
    case 'done':
      return TaskStatus.done;
    default:
      return TaskStatus.todo;
  }
}
