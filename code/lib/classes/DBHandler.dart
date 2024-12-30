import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/Message.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/functions/sharedPreferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Task.dart';
import 'Subtask.dart';
import 'Mood.dart';
import 'User.dart';

class DBHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton instance
  static final DBHandler _instance = DBHandler._internal();

  factory DBHandler() {
    return _instance;
  }

  DBHandler._internal() {
    _initializeTasksStream();
    _initializeUserStream();
    _initializeMessagesStream();
    //_initializeCurrentUserStream();
  }

  // STREAMS
  final BehaviorSubject<List<Task>> _tasksSubject = BehaviorSubject<List<Task>>();
  Stream<List<Task>> get tasksStream => _tasksSubject.stream;

  final BehaviorSubject<List<User>> _usersSubject = BehaviorSubject<List<User>>();
  //Stream<List<User>> get usersStream => _usersSubject.stream;

  final Map<String, BehaviorSubject<Map<String, TaskState>>> _userTaskStateSubjects = {};
  Stream<Map<String, TaskState>> getUserTaskStateStream(String userId) {
    if (!_userTaskStateSubjects.containsKey(userId)) {
      _userTaskStateSubjects[userId] = BehaviorSubject<Map<String, TaskState>>();
      _initializeUserTaskStateStream(userId);
    }
    return _userTaskStateSubjects[userId]!.stream;
  }

  final BehaviorSubject<User?> _currentUserSubject = BehaviorSubject<User?>();

  //Stream<User?> get currentUserStream => _currentUserSubject.stream;

  final BehaviorSubject<List<Message>> _messagesSubject = BehaviorSubject<List<Message>>();
  Stream<List<Message>> get messagesStream => _messagesSubject.stream;

  void _initializeMessagesStream() {
    final List<Message> messages = []; // Local cache of messages

    _firestore.collection('messages').snapshots().listen((messageSnapshot) async {
      for (final change in messageSnapshot.docChanges) {
        final messageId = change.doc.id;
        final messageData = change.doc.data() as Map<String, dynamic>;

        if (change.type == DocumentChangeType.added) {
          // Add new message
          final newMessage = await Message.fromJson(messageData);
          messages.add(newMessage);
        } else if (change.type == DocumentChangeType.modified) {
          // Update existing message
          final index = messages.indexWhere((msg) => msg.messageId == messageId);
          if (index != -1) {
            final updatedMessage = await Message.fromJson(messageData);
            messages[index] = updatedMessage;
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Remove deleted message
          messages.removeWhere((msg) => msg.messageId == messageId);
        }
      }

      // Emit the updated messages list
      _messagesSubject.add(List.from(messages)); // Emit a copy to avoid reference issues
    });
  }

  // Initialize Tasks Stream
  void _initializeTasksStream() {
    final List<Task> tasks = []; // Local cache of tasks

    _firestore.collection('tasks').snapshots().listen((taskSnapshot) async {
      for (final change in taskSnapshot.docChanges) {
        final taskId = change.doc.id;
        final taskData = change.doc.data() as Map<String, dynamic>;

        if (change.type == DocumentChangeType.added) {
          // Fetch subtasks for the new task
          final QuerySnapshot subtaskSnapshot = await _firestore.collection('subtasks').where('parentTaskId', isEqualTo: taskId).get();

          final subtasks = subtaskSnapshot.docs.map((subDoc) {
            final subtaskData = subDoc.data() as Map<String, dynamic>;
            return Subtask.fromJson(subDoc.id, subtaskData);
          }).toList();

          // Create Task object
          final task = await Task.fromJson(taskId, taskData)
            ..subtasks.addAll(subtasks);

          // Add to the local list
          tasks.add(task);
        } else if (change.type == DocumentChangeType.modified) {
          // Update the existing task
          final index = tasks.indexWhere((task) => task.taskId == taskId);
          if (index != -1) {
            final updatedTask = await Task.fromJson(taskId, taskData);
            tasks[index] = updatedTask;
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Remove the task
          tasks.removeWhere((task) => task.taskId == taskId);
        }
      }

      // Emit the updated task list
      _tasksSubject.add(List.from(tasks)); // Emit a copy to avoid reference issues
    });
  }

  // Initialize Users Stream
  void _initializeUserStream() {
    final List<User> users = []; // Local cache of users

    _firestore.collection('users').snapshots().listen((userSnapshot) async {
      for (final change in userSnapshot.docChanges) {
        final userId = change.doc.id;
        final userData = change.doc.data() as Map<String, dynamic>;

        if (change.type == DocumentChangeType.added) {
          // Create User object
          final user = User.fromJson(userId, userData);

          // Add to the local list
          users.add(user);
        } else if (change.type == DocumentChangeType.modified) {
          // Update the existing user
          final index = users.indexWhere((user) => user.userId == userId);
          if (index != -1) {
            final updatedUser = User.fromJson(userId, userData);
            users[index] = updatedUser;
          }
        } else if (change.type == DocumentChangeType.removed) {
          // Remove the user
          users.removeWhere((user) => user.userId == userId);
        }
      }

      // Emit the updated user list
      _usersSubject.add(List.from(users)); // Emit a copy to avoid reference issues
    });
  }

  void _initializeUserTaskStateStream(String userId) {
    final userDocRef = _firestore.collection('users').doc(userId);

    userDocRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final rawTaskStates = userData['taskStates'] ?? {};

        final taskStates = Map<String, TaskState>.from(
          (rawTaskStates as Map<String, dynamic>).map(
            (key, value) {
              try {
                return MapEntry(
                  key,
                  value is int
                      ? TaskState.values[value] // Handle index
                      : TaskState.values.byName(value), // Handle name
                );
              } catch (e) {
                print('Error parsing task state for key $key: $e');
                return MapEntry(key, TaskState.Undecided); // Fallback value
              }
            },
          ),
        );

        _userTaskStateSubjects[userId]?.add(taskStates);
      }
    });
  }

  // Cleanup
  void dispose() {
    _tasksSubject.close();
    _usersSubject.close();
    for (final subject in _userTaskStateSubjects.values) {
      subject.close();
    }
    _messagesSubject.close();
  }

  Stream<List<Message>> userMessagesStream(String userId) {
    return messagesStream.map((messages) {
      // Filter messages for the specified userId
      return messages.where((message) => message.to?.userId == userId).toList();
    });
  }

  Stream<List<Task>> getLikedTasksByUserId(String userId) {
    return Rx.combineLatest2(
      tasksStream,
      getUserTaskStateStream(userId),
      (List<Task> tasks, Map<String, TaskState> taskStates) {
        return tasks.where((task) => taskStates[task.taskId] == TaskState.Like).toList();
      },
    );
  }

  Stream<List<Task>> getDislikedTasksByUserId(String userId) {
    return Rx.combineLatest2(
      tasksStream,
      getUserTaskStateStream(userId),
      (List<Task> tasks, Map<String, TaskState> taskStates) {
        return tasks.where((task) => taskStates[task.taskId] == TaskState.Dislike).toList();
      },
    );
  }

  Stream<List<Task>> getUndecidedTasksByUserId(String userId) {
    return Rx.combineLatest2(
      tasksStream,
      getUserTaskStateStream(userId),
      (List<Task> tasks, Map<String, TaskState> taskStates) {
        return tasks.where((task) {
          final taskState = taskStates[task.taskId];
          return taskState == null || taskState == TaskState.Undecided;
        }).toList();
      },
    );
  }

  //

  // **TASK METHODS**

  Future<List<AssignedTask>> getAssignedButUncompletedAssignedTasksOfCurUser() async {
    final curUserId = await getCurUserId();
    final allTasks = await AssignedTask.getTasksForUser(curUserId);

    // Filter tasks to include only uncompleted ones (finishDate == null)
    final uncompletedTasks = allTasks.where((task) => task.finishDate == null).toList();

    return uncompletedTasks;
  }

  Future<Task?> getTaskById(String taskId) async {
    return tasksStream.map((tasks) {
      try {
        // Find the task with the matching ID
        return tasks.firstWhere((task) => task.taskId == taskId);
      } catch (e) {
        // If not found, return null
        return null;
      }
    }).firstWhere((task) => task != null, orElse: () => null); // Return the first non-null task
  }

  Future<void> saveTask(Task task) async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('tasks').doc(task.taskId);

    // Use set() with merge: true to update only changed fields
    await docRef.set(task.toJson(), SetOptions(merge: true));
  }

  Future<void> removeTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
    // Remove associated subtasks
    QuerySnapshot subtasks = await _firestore.collection('subtasks').where('taskId', isEqualTo: taskId).get();
    for (var doc in subtasks.docs) {
      await doc.reference.delete();
    }
  }

  // **ASSIGNED TASK METHODS**
  Future<AssignedTask?> getAssignedTaskById(String assignedTaskId) async {
    DocumentSnapshot snapshot = await _firestore.collection('assigned_tasks').doc(assignedTaskId).get();
    if (snapshot.exists) {
      return AssignedTask.fromJson(snapshot.id, snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<Map<Category, List<AssignedTask>>> getAssignedButNotCompletedTasksDictionary() async {
    final firestore = FirebaseFirestore.instance;

    // Fetch documents with finishDate == null
    final snapshot = await firestore.collection('assigned_tasks').where('finishDate', isNull: true).get();

    final assignedTasks = await Future.wait(snapshot.docs.map((doc) async {
      final assignedTask = await AssignedTask.fromJson(doc.id, doc.data() as Map<String, dynamic>);

      return assignedTask;
    }));

    // Categorize tasks
    final Map<Category, List<AssignedTask>> categorizedTasks = {};

    for (var assignedTask in assignedTasks) {
      final task = await DBHandler().getTaskById(assignedTask.task.taskId);
      if (task != null) {
        categorizedTasks.putIfAbsent(task.category, () => []).add(assignedTask);
      }
    }

    return categorizedTasks;
  }

  // **SUBTASK METHODS**

  Future<List<Subtask>> getSubtasks(String taskId) async {
    QuerySnapshot snapshot = await _firestore.collection('subtasks').where('taskId', isEqualTo: taskId).get();
    return snapshot.docs.map((doc) => Subtask.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> saveSubtask(Subtask subtask) async {
    await _firestore.collection('subtasks').doc(subtask.subtaskId).set(subtask.toJson());
  }

  Future<void> removeSubtask(String subtaskId) async {
    await _firestore.collection('subtasks').doc(subtaskId).delete();
  }

  // **USER METHODS**

  Future<List<User>> getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => User.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<User?> getUserById(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return User.fromJson(userId, snapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<User> getCurUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(constCurrentUserId);

    if (userId != null) {
      // Fetch the user from Firestore using the userId
      final user = await DBHandler().getUserById(userId);
      if (user != null) {
        return user;
      }
      throw Exception("User with ID $userId not found in the database.");
    }

    // If no userId is found in SharedPreferences, fetch the first user from the database
    final users = await DBHandler().getUsers();
    if (users.isNotEmpty) {
      // Optionally, set the first user as the current user in SharedPreferences
      final firstUser = users.first;
      prefs.setString(constCurrentUserId, firstUser.userId);
      return firstUser;
    }

    // Throw an exception if no user exists in the database
    throw Exception("No users found in the database.");
  }

  Future<void> saveUser(User user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toJson());
  }

  Future<void> removeUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<List<String>> getSubmittedUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('submitted_users').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> addSubmittedUser(String userId) async {
    await _firestore.collection('submitted_users').doc(userId).set({});
  }

  Future<void> removeSubmittedUser(String userId) async {
    await _firestore.collection('submitted_users').doc(userId).delete();
  }

  // **MOOD METHODS**

  Future<List<Mood>> getMoods() async {
    QuerySnapshot snapshot = await _firestore.collection('moods').get();
    return snapshot.docs.map((doc) => Mood.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<Mood>> getMoodsByUserId(String userId) async {
    QuerySnapshot snapshot = await _firestore.collection('moods').where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Mood.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> saveMood(Mood mood) async {
    await _firestore.collection('moods').doc(mood.moodId).set(mood.toJson());
  }

  Future<void> removeMood(String moodId) async {
    await _firestore.collection('moods').doc(moodId).delete();
  }

  /// Retrieve a Message by ID
  Future<Message?> retrieveMessageById(String messageId) async {
    try {
      final snapshot = await _firestore.collection('messages').doc(messageId).get();

      if (snapshot.exists) {
        return await Message.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error retrieving message by ID: $e');
      throw e;
    }
  }

  /// Retrieve all Messages
  Future<List<Message>> getAllMessages() async {
    try {
      final snapshot = await _firestore.collection('messages').get();

      return await Future.wait(
        snapshot.docs.map((doc) async {
          return await Message.fromJson(doc.data() as Map<String, dynamic>);
        }),
      );
    } catch (e) {
      print('Error retrieving all messages: $e');
      throw e;
    }
  }

  // **UTILITY METHODS**

  Future<Mood?> getLatestMoodByUserId(String userId) async {
    List<Mood> moods = await getMoodsByUserId(userId);
    if (moods.isNotEmpty) {
      moods.sort((a, b) => b.date.compareTo(a.date));
      return moods.first;
    }
    return null;
  }

  Future<void> removeAllAssignedTasks() async {
    QuerySnapshot snapshot = await _firestore.collection('assigned_tasks').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> resetAllSubmittedUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('submitted_users').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> resetAllUserPreferences() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();

    for (var doc in snapshot.docs) {
      // Fetch current user data
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

      // Reset taskStates field
      userData['taskStates'] = {};

      // Update user document
      await _firestore.collection('users').doc(doc.id).update(userData);
    }
  }
}
