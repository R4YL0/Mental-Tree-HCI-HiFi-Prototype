import 'User.dart';
import 'Task.dart';
import 'DBHandler.dart';

class AssignedTask {
  int _assignedTaskId;
  User _user;
  Task _task;
  DateTime _dueDate;
  DateTime? _finishDate;

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
    return AssignedTask._(
      assignedTaskId: assignedTaskId,
      user: user,
      task: task,
      dueDate: dueDate,
      finishDate: finishDate,
    );
  }

   // Find all tasks assigned to a specific user
  static Future<List<AssignedTask>> getTasksForUser(int userId) async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks.where((task) => task._user.userId == userId).toList();
  }

  // Find all pending tasks for a specific user
  static Future<List<AssignedTask>> getCompletedTasksForUser(int userId) async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks
        .where((task) =>
            task._user.userId == userId && task._finishDate != null)
        .toList();
  }

  // Find all completed tasks ordered by the finish date
  static Future<List<AssignedTask>> getCompletedTasks() async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks
        .where((task) => task._finishDate != null)
        .toList()
      ..sort((a, b) => a._finishDate!.compareTo(b._finishDate!));
  }

  // Get all tasks not completed for a specific user
  static Future<List<AssignedTask>> getIncompleteTasksForUser(int userId) async {
    final assignedTasks = await DBHandler().getAssignedTasks();
    return assignedTasks
        .where((task) => task._user.userId == userId && task._finishDate == null)
        .toList();
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

  // Getters for accessing private fields
  int get assignedTaskId => _assignedTaskId;
  User get user => _user;
  Task get task => _task;
  DateTime get dueDate => _dueDate;
  DateTime? get finishDate => _finishDate;


  @override
  String toString() {
    return 'AssignedTask(Id: $_assignedTaskId, User: ${_user.userName}, Task: ${_task.name}, Due Date: $_dueDate, Finish Date: $_finishDate)';
  }
}
