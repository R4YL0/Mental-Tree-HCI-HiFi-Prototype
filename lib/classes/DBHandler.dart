import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/functions/sharedPreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Task.dart';
import 'Subtask.dart';
import 'User.dart';
import 'AssignedTask.dart';

class DBHandler {
  late Uint8List defaultTaskImg;

  // Singleton instance
  static final DBHandler _instance = DBHandler._internal();

  factory DBHandler() {
    return _instance;
  }

  DBHandler._internal();

  // Storage keys
  static const String userKey = 'last_user_id';
  static const String taskKey = 'last_task_id';
  static const String subtaskKey = 'last_subtask_id';
  static const String assignedTaskKey = 'last_assigned_task_id';
  static const String moodKey = 'last_mood_id';
  static const String submittedUsersKey =
      'submitted_users'; // Key for submitted users

  final LocalStorage _storage = LocalStorage('db_handler');
  final LocalStorage _taskStorage = LocalStorage('tasks');
  final LocalStorage _subtaskStorage = LocalStorage('subtasks');
  final LocalStorage _userStorage = LocalStorage('users');
  final LocalStorage _assignedTaskStorage = LocalStorage('assigned_tasks');
  final LocalStorage _moodStorage = LocalStorage('moods');

  late final SharedPreferences prefs;

  //Save Indices for different DataSet Sizes
  final dataSet = List<int>.empty(growable: true);
  String dataSize = "S";

  Future<void> initDb() async {
    prefs = await SharedPreferences.getInstance();

    await Future.wait([
      _storage.ready,
      _taskStorage.ready,
      _subtaskStorage.ready,
      _userStorage.ready,
      _assignedTaskStorage.ready,
      _moodStorage.ready,
    ]);
    try {
      ByteData byteData =
          await rootBundle.load('lib/assets/images/defaultTaskImg.jpg');
      defaultTaskImg = byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception("Error loading default image: $e");
    }
  }

  Future<User> getCurUser() async {
    int userId = await getCurUserId();
    User? user = await getUserByUserId(userId);

    if (user == null) {
      throw Exception("No user found for the provided userId: $userId");
    }

    return user;
  }

  Future<void> saveSubmittedUser(int userId) async {
    List<int> submittedUsers = await getSubmittedUsers();

    if (!submittedUsers.contains(userId)) {
      submittedUsers.add(userId);
      await _storage.setItem(submittedUsersKey, submittedUsers);
    }
  }

  Future<void> removeSubmittedUser(int userId) async {
    List<int> submittedUsers = await getSubmittedUsers();

    if (submittedUsers.contains(userId)) {
      submittedUsers.remove(userId);
      await _storage.setItem(submittedUsersKey, submittedUsers);
    }
  }

  Future<List<int>> getSubmittedUsers() async {
    final List<dynamic> submittedUsers =
        _storage.getItem(submittedUsersKey) ?? [];
    return List<int>.from(submittedUsers);
  }

  // Next id handlers
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

  Future<int> getNextMoodId() async {
    final id = await _getLastId(moodKey) + 1;
    await _setLastId(moodKey, id);
    return id;
  }

  // get from db functions
  Future<List<Task>> getTasks() async {
    final tasksJson = _taskStorage.getItem('tasks') ?? [];
    return List<Map<String, dynamic>>.from(tasksJson)
        .map<Task>((json) => Task.fromJson(json))
        .toList();
  }

  Future<List<Subtask>> getSubtasks() async {
    final subtasksJson = _subtaskStorage.getItem('subtasks') ?? [];
    return List<Map<String, dynamic>>.from(subtasksJson)
        .map<Subtask>((json) => Subtask.fromJson(json))
        .toList();
  }

  Future<List<AssignedTask>> getAssignedTasks({bool open = true,}) async {
    final assignedTasksJson =
        _assignedTaskStorage.getItem('assigned_tasks') ?? [];

    List<AssignedTask> allAssigned = List<Map<String, dynamic>>.from(assignedTasksJson)
        .map<AssignedTask>((json) => AssignedTask.fromJson(json))
        .toList();

    if(!open) {
      return allAssigned;
    }

    dataSize = prefs.getString(constDataSet) ?? "S";

    int dataSizeLength = dataSize == "S" ? 5 : dataSize == "M" ? 10 : 20;
    dataSizeLength = allAssigned.length < dataSizeLength ? allAssigned.length : dataSizeLength;
    if(dataSet.length != dataSizeLength) {
      dataSet.clear();
      allAssigned.shuffle();
      for(int i = 0; i < dataSizeLength; i++) {
        dataSet.add(allAssigned[i].assignedTaskId);
      }
    }

    List<AssignedTask> assignedDataSet = List<AssignedTask>.empty(growable: true);
    for(int i = 0; i < dataSizeLength; i++) {
      if(dataSet[i] != -1) { //If Task deleted from Assigned
        assignedDataSet.add(allAssigned.singleWhere((aTask)=>aTask.assignedTaskId == dataSet[i]));
      }
    }

    return assignedDataSet;
  }

  Future<List<AssignedTask>> getAssignedTasksByTaskId() async {
    final assignedTasksJson =
        _assignedTaskStorage.getItem('assigned_tasks') ?? [];
    return List<Map<String, dynamic>>.from(assignedTasksJson)
        .map<AssignedTask>((json) => AssignedTask.fromJson(json))
        .toList();
  }

  Future<List<User>> getUsers() async {
    final usersJson = _userStorage.getItem('users') ?? [];
    return List<Map<String, dynamic>>.from(usersJson)
        .map<User>((json) => User.fromJson(json))
        .toList();
  }

  Future<Task> getTaskByTaskId(int taskId) async {
    final List<Task> tasks = await getTasks();
    for (Task t in tasks) {
      if (t.taskId == taskId) {
        return t;
      }
    }

    print("ERRRRRRORRRRR: no task with taskId: $taskId");
    return tasks[0];
  }

  Future<User?> getUserByUserId(int userId) async {
    final List<User> users = await getUsers();
    for (User u in users) {
      if (u.userId == userId) {
        return u;
      }
    }
    return null;
  }

  Future<List<Mood>> getMoods() async {
    final moodsJson = _moodStorage.getItem('moods') ?? [];
    return List<Map<String, dynamic>>.from(moodsJson)
        .map<Mood>((json) => Mood.fromJson(json))
        .toList();
  }

  Future<List<Mood>> getMoodsByUserId(int userId) async {
    final moods = await getMoods();
    return moods.where((mood) => mood.userId == userId).toList();
  }

  Future<Mood?> getLatestMoodByUserId(int userId) async {
    final moods = await getMoodsByUserId(userId);
    if (moods.isNotEmpty) {
      moods.sort((a, b) => b.date.compareTo(a.date));
      return moods.first;
    }
    return null;
  }

  Future<List<Task>> getLikedTasksByUserId(int userId) async {
    User? user = await getUserByUserId(userId);
    if (user == null) {
      throw Exception("User with userId $userId not found");
    }

    final List<Task> tasks = await getTasks();

    return tasks.where((task) {
      return user.taskStates[task.taskId] == TaskState.Like;
    }).toList();
  }

  Future<List<Task>> getDislikedTasksByUserId(int userId) async {
    User? user = await getUserByUserId(userId);
    if (user == null) {
      throw Exception("User with userId $userId not found");
    }

    final List<Task> tasks = await getTasks();

    return tasks.where((task) {
      return user.taskStates[task.taskId] == TaskState.Dislike;
    }).toList();
  }

  Future<List<Task>> getUndecidedTasksByUserID(int userId) async {
    User? user = await getUserByUserId(userId);
    if (user == null) {
      throw Exception("User with userId $userId not found");
    }

    final List<Task> tasks = await getTasks();

    // Filter out the tasks which the user has not yet liked or disliked
    List<Task> undecidedTasks = tasks.where((task) {
      return !user.taskStates.containsKey(task.taskId);
    }).toList();

    return undecidedTasks;
  }

  // save data in DB
  Future<void> saveTask(Task newTask) async {
    final tasks = await getTasks();

    // Update if already in DB
    int index = tasks.indexWhere((task) => task.taskId == newTask.taskId);
    if (index != -1) {
      tasks.removeAt(index);
    }
    tasks.add(newTask);

    await _taskStorage.setItem(
        'tasks', tasks.map((task) => task.toJson()).toList());
  }

  Future<void> saveSubtask(Subtask newSubtask) async {
    final subtasks = await getSubtasks();

    // Update if already in DB
    int index = subtasks
        .indexWhere((subtask) => subtask.subtaskId == newSubtask.subtaskId);
    if (index != -1) {
      subtasks.removeAt(index);
    }
    subtasks.add(newSubtask);

    await _subtaskStorage.setItem(
      'subtasks',
      subtasks.map((subtask) => subtask.toJson()).toList(),
    );
  }

  Future<void> saveUser(User newUser) async {
    final users = await getUsers();

    // Update if already in DB
    int index = users.indexWhere((user) => user.userId == newUser.userId);
    if (index != -1) {
      users.removeAt(index);
    }
    users.add(newUser);

    await _userStorage.setItem(
        'users', users.map((user) => user.toJson()).toList());
  }

  Future<void> saveAssignedTask(AssignedTask newAssignedTask) async {
    final assignedTasks = await getAssignedTasks(open:false);

    // Update if already in DB
    int index = assignedTasks.indexWhere((assignedTask) =>
        assignedTask.assignedTaskId == newAssignedTask.assignedTaskId);
    if (index != -1) {
      assignedTasks.removeAt(index);
    }
    assignedTasks.add(newAssignedTask);

    int dataSetIndex = dataSet.indexWhere((idx) => idx == index);

    if(dataSetIndex != -1) {
      dataSet[dataSetIndex] = newAssignedTask.assignedTaskId;
    }

    await _assignedTaskStorage.setItem(
      'assigned_tasks',
      assignedTasks.map((task) => task.toJson()).toList(),
    );
  }

  Future<void> saveMood(Mood newMood) async {
    final moods = await getMoods();

    // Update if already in DB
    int index = moods.indexWhere((mood) => mood.moodId == newMood.moodId);
    if (index != -1) {
      moods.removeAt(index);
    }
    moods.add(newMood);

    await _moodStorage.setItem(
        'moods', moods.map((mood) => mood.toJson()).toList());
  }

  // Remove from db

  Future<void> removeTask(int id) async {
    final tasks = await getTasks();

    int index = tasks.indexWhere((task) => task.taskId == id);
    if (index != -1) {
      tasks.removeAt(index);
    }

    await _taskStorage.setItem(
        'tasks', tasks.map((task) => task.toJson()).toList());
  }

  Future<void> removeSubtask(int id) async {
    final subtasks = await getSubtasks();

    int index = subtasks.indexWhere((subtask) => subtask.subtaskId == id);
    if (index != -1) {
      subtasks.removeAt(index);
    }

    await _subtaskStorage.setItem(
      'subtasks',
      subtasks.map((subtask) => subtask.toJson()).toList(),
    );
  }

  Future<void> removeUser(int id) async {
    final users = await getUsers();

    int index = users.indexWhere((user) => user.userId == id);
    if (index != -1) {
      users.removeAt(index);
    }

    await _userStorage.setItem(
        'users', users.map((user) => user.toJson()).toList());
  }

  Future<void> removeAssignedTask(int id) async {
    final assignedTasks = await getAssignedTasks(open:false);

    int index = assignedTasks
        .indexWhere((assignedTask) => assignedTask.assignedTaskId == id);
    if (index != -1) {
      assignedTasks.removeAt(index);
    }

    int dataSetIndex = dataSet.indexWhere((idx) => idx == index);
    
    if(dataSetIndex != -1) {
      dataSet[dataSetIndex] = -1;
    }

    await _assignedTaskStorage.setItem(
      'assigned_tasks',
      assignedTasks.map((task) => task.toJson()).toList(),
    );
  }

  Future<void> removeMood(int id) async {
    final moods = await getMoods();

    // Update if already in DB
    int index = moods.indexWhere((mood) => mood.moodId == id);
    if (index != -1) {
      moods.removeAt(index);
    }

    await _moodStorage.setItem(
        'moods', moods.map((mood) => mood.toJson()).toList());
  }
}
