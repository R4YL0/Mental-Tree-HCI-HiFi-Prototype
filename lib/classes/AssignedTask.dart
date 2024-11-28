import 'User.dart';
import 'Task.dart';
import 'DBHandler.dart';

class AssignedTask {
  int _assignedTaskId;
  User _user;
  Task _task;
  DateTime _dueDate;
  DateTime? _finishDate;

  // Getters & Setters
  int get assignedTaskId => _assignedTaskId;
  User get user => _user;
  Task get task => _task;
  DateTime get dueDate => _dueDate;
  DateTime? get finishDate => _finishDate;

  set assignedTaskId(int value) => {_assignedTaskId = value, DBHandler().saveAssignedTask(this)};
  set task(Task value) => {_task = value, DBHandler().saveAssignedTask(this)};
  set dueDate(DateTime value) => {_dueDate = value, DBHandler().saveAssignedTask(this)};
  set finishDate(DateTime? value) => {_finishDate = value, DBHandler().saveAssignedTask(this)};

  setUser(User value) async {
    _user = value;
    await DBHandler().saveAssignedTask(this);
  }

  // Private Constructor
  AssignedTask._({
    required int assignedTaskId,
    required User user,
    required Task task,
    required DateTime dueDate,
    DateTime? finishDate,
  })  : _assignedTaskId = assignedTaskId,
        _user = user,
        _task = task,
        _dueDate = dueDate,
        _finishDate = finishDate;

  // Factory Constructor with Auto ID
  static Future<AssignedTask> create({
    required User user,
    required Task task,
    required DateTime dueDate,
    DateTime? finishDate,
  }) async {
    final assignedTaskId = await DBHandler().getNextAssignedTaskId();
    AssignedTask assignedTask = AssignedTask._(
      assignedTaskId: assignedTaskId,
      user: user,
      task: task,
      dueDate: dueDate,
      finishDate: finishDate,
    );
    await DBHandler().saveAssignedTask(assignedTask);
    return assignedTask;
  }

  // Find all tasks assigned to a specific user
  static Future<List<AssignedTask>> getTasksForUser(int userId) async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks.where((task) => task._user.userId == userId).toList();
  }

  // Find all completed tasks for a specific user
  static Future<List<AssignedTask>> getCompletedTasksForUser(int userId) async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks.where((task) => task._user.userId == userId && task._finishDate != null).toList();
  }

  // Find all completed tasks ordered by the finish date
  static Future<List<AssignedTask>> getCompletedTasks() async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks.where((task) => task._finishDate != null).toList()..sort((a, b) => a._finishDate!.compareTo(b._finishDate!));
  }

  // Get all tasks not completed for a specific user
  static Future<List<AssignedTask>> getIncompleteTasksForUser(int userId) async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks.where((task) => task._user.userId == userId && task._finishDate == null).toList();
  }

  static Future<Map<Category, List<AssignedTask>>> getAssignedTasksDictionary() async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    final Map<Category, List<AssignedTask>> tasksByCategory = {};

    for (var task in assignedTasks) {
      final category = task._task.category;
      if (!tasksByCategory.containsKey(category)) {
        tasksByCategory[category] = [];
      }
      tasksByCategory[category]?.add(task);
    }
    return tasksByCategory;
  }

  static Future<Map<Category, List<AssignedTask>>> getAssignedButNotCompletedTasksDictionary() async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    final Map<Category, List<AssignedTask>> tasksByCategory = {};

    for (var task in assignedTasks) {
      if (task.finishDate != null) {
        continue;
      }

      final category = task._task.category;
      if (!tasksByCategory.containsKey(category)) {
        tasksByCategory[category] = [];
      }
      tasksByCategory[category]?.add(task);
    }
    return tasksByCategory;
  }

  // Get assigned tasks dictionary
  static Future<Map<Category, List<AssignedTask>>> getAssignedAndCompletedTasksDictionary() async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    final Map<Category, List<AssignedTask>> tasksByCategory = {};

    for (var task in assignedTasks) {
      if (task.finishDate == null) {
        continue;
      }

      final category = task._task.category;
      if (!tasksByCategory.containsKey(category)) {
        tasksByCategory[category] = [];
      }
      tasksByCategory[category]?.add(task);
    }
    return tasksByCategory;
  }

  Map<String, dynamic> toJson() => {
        'assignedTaskId': _assignedTaskId,
        'user': _user.toJson(),
        'task': _task.toJson(),
        'dueDate': _dueDate.toIso8601String(),
        'finishDate': _finishDate?.toIso8601String(),
      };

  AssignedTask.fromJson(Map<String, dynamic> json)
      : _assignedTaskId = json['assignedTaskId'],
        _user = User.fromJson(json['user']),
        _task = Task.fromJson(json['task']),
        _dueDate = DateTime.parse(json['dueDate']),
        _finishDate = json['finishDate'] != null ? DateTime.parse(json['finishDate']) : null;
}
