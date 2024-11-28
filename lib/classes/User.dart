import 'package:flutter/material.dart';
import 'DBHandler.dart';

enum TaskState { Like, Dislike, Undecided }

class User {
  final int _userId; // Unique ID for the user
  String _name;
  Color _flowerColor;
  Map<int, TaskState> _taskStates;

  // Getters
  int get userId => _userId;
  String get name => _name;
  Color get flowerColor => _flowerColor;
  Map<int, TaskState> get taskStates => _taskStates;

  set name(String value) {
    _name = value;
    DBHandler().saveUser(this);
  }

  set flowerColor(Color value) {
    _flowerColor = value;
    DBHandler().saveUser(this);
  }

  set taskStates(Map<int, TaskState> value) {
    _taskStates = value;
    DBHandler().saveUser(this);
  }

  updateTaskState(int taskId, TaskState? newState) async {
    if (newState == null) {
      _taskStates.remove(taskId);
    } else {
      _taskStates[taskId] = newState;
    }

    await DBHandler().saveUser(this);
  }

  // Private Constructor
  User._({
    required int userId,
    required String name,
    required Color flowerColor,
    Map<int, TaskState>? taskStates,
  })  : _userId = userId,
        _name = name,
        _flowerColor = flowerColor,
        _taskStates = taskStates ?? {};

  // Factory Constructor to Create New User
  static Future<User> create({
    required String name,
    required Color flowerColor,
  }) async {
    final id = await DBHandler().getNextUserId(); // Fetch auto-incremented ID
    User user = User._(userId: id, name: name, flowerColor: flowerColor);
    await DBHandler().saveUser(user); // Save user to DB
    return user;
  }

  // Convert User to JSON for Database Storage
  Map<String, dynamic> toJson() => {
        'userId': _userId,
        'name': _name,
        'flowerColor': _flowerColor.value,
        'taskStates': _taskStates.map((key, value) => MapEntry(key.toString(), value.name)),
      };

  // Parse JSON Data to Create User
  User.fromJson(Map<String, dynamic> json)
      : _userId = json['userId'],
        _name = json['name'],
        _flowerColor = Color(json['flowerColor']),
        _taskStates = (json['taskStates'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                int.parse(key),
                TaskState.values.byName(value),
              ),
            ) ??
            {}; // Default to empty map if taskStates is null

  // Save Changes to DB (Optional)
  Future<void> save() async {
    await DBHandler().saveUser(this);
  }

  @override
  String toString() {
    return 'User: {\n'
        '  userId: $_userId,\n'
        '  name: $_name,\n'
        '  flowerColor: #${_flowerColor.value.toRadixString(16).padLeft(8, '0')},\n'
        '  taskStates: $_taskStates\n'
        '}';
  }
}
