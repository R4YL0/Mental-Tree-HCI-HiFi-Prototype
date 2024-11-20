import 'Subtask.dart';
import 'DBHandler.dart';

class Task {
  int _taskId;
  String _name;
  Frequency _frequency;
  String _notes;
  bool _isPrivate;
  int _difficulty;
  int _priority;
  List<Subtask> _subtasks;

  // Private Constructor
  Task._({
    required int taskId,
    required String name,
    required Frequency frequency,
    required String notes,
    required bool isPrivate,
    required int difficulty,
    required int priority,
    List<Subtask> subtasks = const [],
  })  : _taskId = taskId,
        _name = name,
        _frequency = frequency,
        _notes = notes,
        _isPrivate = isPrivate,
        _difficulty = difficulty,
        _priority = priority,
        _subtasks = List.from(subtasks);

  // Factory Constructor with Auto ID
  static Future<Task> create({
    required String name,
    required Frequency frequency,
    required String notes,
    required bool isPrivate,
    required int difficulty,
    required int priority,
    List<Subtask> subtasks = const [],
  }) async {
    final id = await DBHandler().getNextTaskId();
    return Task._(
      taskId: id,
      name: name,
      frequency: frequency,
      notes: notes,
      isPrivate: isPrivate,
      difficulty: difficulty,
      priority: priority,
      subtasks: subtasks,
    );
  }

  // Find a Task by ID
  static Future<Task?> findById(int taskId) async {
    final tasks = await DBHandler().getTasks();
    return tasks.cast<Task?>().firstWhere(
      (task) => task?._taskId == taskId,
      orElse: () => null,
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': _taskId,
        'name': _name,
        'frequency': _frequency.toString(),
        'notes': _notes,
        'isPrivate': _isPrivate,
        'difficulty': _difficulty,
        'priority': _priority,
        'subtasks': _subtasks.map((subtask) => subtask.toJson()).toList(),
      };

  Task.fromJson(Map<String, dynamic> json)
      : _taskId = json['taskId'],
        _name = json['name'],
        _frequency = Frequency.values.firstWhere((e) => e.toString() == json['frequency']),
        _notes = json['notes'],
        _isPrivate = json['isPrivate'],
        _difficulty = json['difficulty'],
        _priority = json['priority'],
        _subtasks = (json['subtasks'] as List).map((item) => Subtask.fromJson(item)).toList();

  String get name => _name;
  int get taskid => _taskId;

}

enum Frequency { daily, weekly, monthly, yearly }
