import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusflow/models/task_model.dart';

class TaskService extends ChangeNotifier {
  static const String _keyTasks = 'tasks';
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_keyTasks);
      
      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        final allTasks = decoded.map((e) => TaskModel.fromJson(e)).toList();
        _tasks = allTasks.where((t) => t.userId == userId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _tasks = _createSampleTasks(userId);
        await _saveTasks();
      }
    } catch (e) {
      debugPrint('Failed to load tasks: $e');
      _tasks = _createSampleTasks(userId);
      await _saveTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TaskModel> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _tasks.where((task) {
      if (task.dueDate == null) return true;
      final dueDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDay.isAtSameMomentAs(today) || dueDay.isBefore(today);
    }).toList();
  }

  List<TaskModel> getTasksByDate(DateTime date) {
    final targetDay = DateTime(date.year, date.month, date.day);
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDay = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDay.isAtSameMomentAs(targetDay);
    }).toList();
  }

  TaskModel? getTaskById(String id) => _tasks.firstWhere((t) => t.id == id);

  Future<void> createTask(TaskModel task) async {
    try {
      _tasks.insert(0, task);
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to create task: $e');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(updatedAt: DateTime.now());
        await _saveTasks();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to update task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    try {
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: !_tasks[index].isCompleted,
          updatedAt: DateTime.now(),
        );
        await _saveTasks();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to toggle task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      _tasks.removeWhere((t) => t.id == id);
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete task: $e');
    }
  }

  double getCompletionPercentage() {
    if (_tasks.isEmpty) return 0.0;
    final completed = _tasks.where((t) => t.isCompleted).length;
    return (completed / _tasks.length * 100).clamp(0.0, 100.0);
  }

  double getTodayCompletionPercentage() {
    final todayTasks = getTodayTasks();
    if (todayTasks.isEmpty) return 0.0;
    final completed = todayTasks.where((t) => t.isCompleted).length;
    return (completed / todayTasks.length * 100).clamp(0.0, 100.0);
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_keyTasks, encoded);
    } catch (e) {
      debugPrint('Failed to save tasks: $e');
    }
  }

  List<TaskModel> _createSampleTasks(String userId) {
    final now = DateTime.now();
    return [
      TaskModel(
        id: '1',
        userId: userId,
        title: 'Complete project proposal',
        description: 'Finish the Q1 project proposal document and send it to the team',
        priority: TaskPriority.high,
        dueDate: now,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      TaskModel(
        id: '2',
        userId: userId,
        title: 'Team meeting preparation',
        description: 'Prepare slides for tomorrow\'s team sync',
        priority: TaskPriority.medium,
        dueDate: now,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '3',
        userId: userId,
        title: 'Review code changes',
        description: 'Review pull requests from the development team',
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: '4',
        userId: userId,
        title: 'Update documentation',
        description: 'Update API documentation with new endpoints',
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now,
        updatedAt: now,
      ),
      TaskModel(
        id: '5',
        userId: userId,
        title: 'Client call',
        description: 'Weekly check-in with client about project progress',
        priority: TaskPriority.high,
        dueDate: now,
        isCompleted: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
