import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

// State Notifier untuk Task
class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    loadTasks();
  }

  static const String _storageKey = 'tasks';

  // Load tasks dari storage
  Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_storageKey);
      
      if (tasksJson != null) {
        final List<dynamic> tasksList = json.decode(tasksJson);
        state = tasksList.map((json) => Task.fromJson(json)).toList();
      }
    } catch (e) {
      state = [];
    }
  }

  // Save tasks ke storage
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tasksJson = json.encode(
        state.map((task) => task.toJson()).toList(),
      );
      await prefs.setString(_storageKey, tasksJson);
    } catch (e) {
      // Handle error
    }
  }

  // Tambah task baru
  Future<void> addTask(Task task) async {
    state = [...state, task];
    await _saveTasks();
  }

  // Update task
  Future<void> updateTask(Task updatedTask) async {
    state = [
      for (final task in state)
        if (task.id == updatedTask.id) updatedTask else task,
    ];
    await _saveTasks();
  }

  // Toggle complete status
  Future<void> toggleTaskComplete(String taskId) async {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
    await _saveTasks();
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    state = state.where((task) => task.id != taskId).toList();
    await _saveTasks();
  }

  // Clear completed tasks
  Future<void> clearCompletedTasks() async {
    state = state.where((task) => !task.isCompleted).toList();
    await _saveTasks();
  }
}

// Provider untuk TaskNotifier
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

// Provider untuk filter tasks
enum TaskFilter { all, active, completed }

final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter.all;
});

// Provider untuk filtered tasks
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final filter = ref.watch(taskFilterProvider);

  switch (filter) {
    case TaskFilter.active:
      return tasks.where((task) => !task.isCompleted).toList();
    case TaskFilter.completed:
      return tasks.where((task) => task.isCompleted).toList();
    case TaskFilter.all:
      return tasks;
  }
});

// Provider untuk task statistics
final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(taskProvider);
  
  return {
    'total': tasks.length,
    'active': tasks.where((task) => !task.isCompleted).length,
    'completed': tasks.where((task) => task.isCompleted).length,
  };
});