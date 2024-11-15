import 'package:localstorage/localstorage.dart';
import 'Task.dart';
import 'Subtask.dart';
import 'User.dart';
import 'AssignedTask.dart';

class DBHandler {
  // Singleton instance
  static final DBHandler _instance = DBHandler._internal();

  factory DBHandler() {
    return _instance;
  }

  DBHandler._internal();

  final LocalStorage _storage = LocalStorage('db_handler');

  // Storage keys
  static const String userKey = 'last_user_id';
  static const String taskKey = 'last_task_id';
  static const String subtaskKey = 'last_subtask_id';
  static const String assignedTaskKey = 'last_assigned_task_id';

  final LocalStorage _taskStorage = LocalStorage('tasks');
  final LocalStorage _subtaskStorage = LocalStorage('subtasks');
  final LocalStorage _userStorage = LocalStorage('users');
  final LocalStorage _assignedTaskStorage = LocalStorage('assigned_tasks');

  Future<void> initDb() async {
    await Future.wait([
      _storage.ready,
      _taskStorage.ready,
      _subtaskStorage.ready,
      _userStorage.ready,
      _assignedTaskStorage.ready,
    ]);
  }

  Future<int> _getLastId(String key) async {
    return _storage.getItem(key) ?? 0;
  }

  Future<void> _setLastId(String key, int id) async {
    await _storage.setItem(key, id);
  }

  Future<int> getNextUserId() async {
    final id = await _getLastId(userKey) + 1;
    await _setLastId(userKey, id);
    return id;
  }

  Future<int> getNextTaskId() async {
    final id = await _getLastId(taskKey) + 1;
    await _setLastId(taskKey, id);
    return id;
  }

  Future<int> getNextSubtaskId() async {
    final id = await _getLastId(subtaskKey) + 1;
    await _setLastId(subtaskKey, id);
    return id;
  }

  Future<int> getNextAssignedTaskId() async {
    final id = await _getLastId(assignedTaskKey) + 1;
    await _setLastId(assignedTaskKey, id);
    return id;
  }

  Future<List<Task>> getTasks() async {
    final tasksJson = _taskStorage.getItem('tasks') ?? [];
    return List<Map<String, dynamic>>.from(tasksJson)
        .map<Task>((json) => Task.fromJson(json))
        .toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await _taskStorage.setItem('tasks', tasks.map((task) => task.toJson()).toList());
  }

  Future<List<Subtask>> getSubtasks() async {
    final subtasksJson = _subtaskStorage.getItem('subtasks') ?? [];
    return List<Map<String, dynamic>>.from(subtasksJson)
        .map<Subtask>((json) => Subtask.fromJson(json))
        .toList();
  }

  Future<void> saveSubtask(Subtask subtask) async {
    final subtasks = await getSubtasks();
    subtasks.add(subtask);
    await _subtaskStorage.setItem('subtasks', subtasks.map((subtask) => subtask.toJson()).toList());
  }

  Future<List<User>> getUsers() async {
    final usersJson = _userStorage.getItem('users') ?? [];
    return List<Map<String, dynamic>>.from(usersJson)
        .map<User>((json) => User.fromJson(json))
        .toList();
  }

  Future<void> saveUser(User user) async {
    final users = await getUsers();
    users.add(user);
    await _userStorage.setItem('users', users.map((user) => user.toJson()).toList());
  }

  Future<List<AssignedTask>> getAssignedTasks() async {
    final assignedTasksJson = _assignedTaskStorage.getItem('assigned_tasks') ?? [];
    return List<Map<String, dynamic>>.from(assignedTasksJson)
        .map<AssignedTask>((json) => AssignedTask.fromJson(json))
        .toList();
  }

  Future<void> saveAssignedTask(AssignedTask assignedTask) async {
    final assignedTasks = await getAssignedTasks();
    assignedTasks.add(assignedTask);
    await _assignedTaskStorage.setItem(
        'assigned_tasks', assignedTasks.map((task) => task.toJson()).toList());
  }
}
