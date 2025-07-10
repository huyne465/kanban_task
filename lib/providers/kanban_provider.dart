import 'package:flutter/material.dart';
import '../models/task.dart';

class KanbanProvider extends ChangeNotifier {
  final List<Task> _tasks = [
    //data
    Task(
      id: '1',
      title: 'Task 1',
      description: 'Description for task 1',
      status: 'requested',
    ),
    Task(
      id: '2',
      title: 'Task 2',
      description: 'Description for task 2',
      status: 'requested',
    ),
    Task(
      id: '3',
      title: 'Task 3',
      description: 'Description for task 3',
      status: 'inprogress',
    ),
    Task(
      id: '4',
      title: 'Task 4',
      description: 'Description for task 4',
      status: 'done',
    ),
  ];

  List<Task> get tasks => _tasks;

  List<Task> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  Color getHeaderColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.blue[900]!;
      case 'inprogress':
        return Colors.orange[800]!;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void updateTaskStatus(String taskId, String newStatus) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void removeTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }
}
