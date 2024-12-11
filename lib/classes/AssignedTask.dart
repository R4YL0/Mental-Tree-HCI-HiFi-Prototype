import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';

class AssignedTask {
  String assignedTaskId;
  User user;
  Task task;
  DateTime dueDate;
  DateTime? finishDate;

  AssignedTask({
    required this.assignedTaskId,
    required this.user,
    required this.task,
    required this.dueDate,
    this.finishDate,
  });

  Future<void> setUser(User newUser) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Update the user field in memory
      user = newUser;

      // Save the updated user ID to Firestore
      await firestore.collection('assigned_tasks').doc(assignedTaskId).update({
        'userId': newUser.userId,
      });
    } catch (e) {
      print('Error updating user in AssignedTask: $e');
    }
  }

  // Save AssignedTask to Firebase
  Future<void> saveToFirebase() async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('assigned_tasks').doc(assignedTaskId).set(toJson());
    } catch (e) {
      print('Error saving AssignedTask to Firebase: $e');
    }
  }

  // Remove AssignedTask from Firebase
  Future<void> removeFromFirebase() async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('assigned_tasks').doc(assignedTaskId).delete();
    } catch (e) {
      print('Error removing AssignedTask from Firebase: $e');
    }
  }

  /// Update specific fields of an AssignedTask in Firebase
  Future<void> updateFieldsInFirebase({
    User? user,
    Task? task,
    DateTime? dueDate,
    DateTime? finishDate,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      Map<String, dynamic> fieldsToUpdate = {};

      // Add fields to update map if not null
      if (user != null) fieldsToUpdate['userId'] = user.userId;
      if (task != null) fieldsToUpdate['taskId'] = task.taskId;
      if (dueDate != null) fieldsToUpdate['dueDate'] = dueDate.toIso8601String();
      if (finishDate != null) {
        fieldsToUpdate['finishDate'] = finishDate.toIso8601String();
      } else {
        fieldsToUpdate['finishDate'] = null; // Handle nullable finishDate
      }

      if (fieldsToUpdate.isNotEmpty) {
        await firestore.collection('assigned_tasks').doc(assignedTaskId).update(fieldsToUpdate);
        print('AssignedTask fields updated successfully in Firebase.');
      } else {
        print('No fields to update.');
      }
    } catch (e) {
      print('Error updating fields in Firebase: $e');
      throw e;
    }
  }

  // Convert AssignedTask to JSON for Firebase
  Map<String, dynamic> toJson() => {
        'assignedTaskId': assignedTaskId,
        'userId': user.userId, // Save userId from the User object
        'taskId': task.taskId, // Save taskId from the Task object
        'dueDate': dueDate.toIso8601String(),
        'finishDate': finishDate?.toIso8601String(),
      };

  // Create AssignedTask from Firebase JSON
  static Future<AssignedTask> fromJson(String id, Map<String, dynamic> json) async {
    final dbHandler = DBHandler();
    final user = await dbHandler.getUserById(json['userId']); // Fetch User object
    if (user == null) {
      throw Exception('User with ID ${json['userId']} not found');
    }

    final task = await dbHandler.getTaskById(json['taskId']); // Fetch Task object
    if (task == null) {
      throw Exception('Task with ID ${json['taskId']} not found');
    }

    return AssignedTask(
      assignedTaskId: id,
      user: user,
      task: task,
      dueDate: DateTime.parse(json['dueDate']),
      finishDate: json['finishDate'] != null ? DateTime.parse(json['finishDate']) : null,
    );
  }

  // Factory Constructor to Create New AssignedTask
  static Future<AssignedTask> create({
    required User user,
    required Task task,
    required DateTime dueDate,
    DateTime? finishDate,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final id = firestore.collection('assigned_tasks').doc().id; // Generate a unique ID
    final assignedTask = AssignedTask(
      assignedTaskId: id,
      user: user,
      task: task,
      dueDate: dueDate,
      finishDate: finishDate,
    );
    await assignedTask.saveToFirebase();
    return assignedTask;
  }

  static Future<List<AssignedTask>> getTasksForUser(String? userId) async {
    final firestore = FirebaseFirestore.instance;

    // If userId is null, fetch the first user from the database
    if (userId == null) {
      final users = await DBHandler().getUsers();
      if (users.isNotEmpty) {
        userId = users.first.userId;
      } else {
        // Handle the case where no users exist in the database
        throw Exception("No users found in the database.");
      }
    }

    // Query assigned tasks for the given userId
    final snapshot = await firestore.collection('assigned_tasks').where('userId', isEqualTo: userId).get();

    // Map Firestore documents to AssignedTask objects
    return Future.wait(snapshot.docs.map((doc) async => await AssignedTask.fromJson(doc.id, doc.data() as Map<String, dynamic>)));
  }

  static Future<List<AssignedTask>> getAllCompletedTasks() async {
    final firestore = FirebaseFirestore.instance;

    // Query all assigned tasks that have a non-null finishDate (completed tasks)
    final snapshot = await firestore.collection('assigned_tasks').get();

    final result = await Future.wait(snapshot.docs
      .where((doc) => doc.data()['finishDate'] != null) // Filter documents with non-null finishDate
      .map((doc) async => AssignedTask.fromJson(doc.id, doc.data() as Map<String, dynamic>))
      .toList());


    result.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    // Convert Firestore documents to a list of AssignedTask objects
    return result;
  }

  // Retrieve Completed Tasks for a Specific User
  static Future<List<AssignedTask>> getCompletedTasksForUser(User user) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('assigned_tasks').where('userId', isEqualTo: user.userId).where('finishDate', isNotEqualTo: null).get();
    return Future.wait(snapshot.docs.map((doc) async => await AssignedTask.fromJson(doc.id, doc.data() as Map<String, dynamic>)));
  }

  // Retrieve Incomplete Tasks for a Specific User
  static Future<List<AssignedTask>> getIncompleteTasksForUser(User user) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('assigned_tasks').where('userId', isEqualTo: user.userId).where('finishDate', isEqualTo: null).get();
    return Future.wait(snapshot.docs.map((doc) async => await AssignedTask.fromJson(doc.id, doc.data() as Map<String, dynamic>)));
  }

  // Retrieve All Assigned Tasks Grouped by Category
  static Future<Map<Category, List<AssignedTask>>> getTasksByCategory() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('assigned_tasks').get();

    final assignedTasks = await Future.wait(snapshot.docs.map((doc) async => await AssignedTask.fromJson(doc.id, doc.data() as Map<String, dynamic>)));

    final Map<Category, List<AssignedTask>> categorizedTasks = {};

    for (var assignedTask in assignedTasks) {
      final category = assignedTask.task.category;
      categorizedTasks.putIfAbsent(category, () => []).add(assignedTask);
    }
    return categorizedTasks;
  }

  // Retrieve Assigned and Completed Tasks Grouped by Category
  static Future<Map<Category, List<AssignedTask>>> getAssignedAndCompletedTasksDictionary() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('assigned_tasks').where('finishDate', isNotEqualTo: null).get();

    // Parse the snapshot into a list of AssignedTasks
    final assignedTasks = await Future.wait(snapshot.docs.map((doc) async => await AssignedTask.fromJson(doc.id, doc.data() as Map<String, dynamic>)));

    final Map<Category, List<AssignedTask>> categorizedTasks = {};

    for (var assignedTask in assignedTasks) {
      final category = assignedTask.task.category;
      categorizedTasks.putIfAbsent(category, () => []).add(assignedTask);
    }

    return categorizedTasks;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignedTask && other.assignedTaskId == assignedTaskId;
  }
}
