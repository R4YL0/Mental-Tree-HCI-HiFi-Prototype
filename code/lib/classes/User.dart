import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskState { Like, Dislike, Undecided }

class User {
  final String userId;
  String _name;
  Color _flowerColor;
  Map<String, TaskState> _taskStates;

  // Constructor
  User({
    required this.userId,
    required String name,
    required Color flowerColor,
    Map<String, TaskState> taskStates = const {},
  })  : _name = name,
        _flowerColor = flowerColor,
        _taskStates = taskStates;

  // Firebase Reference
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Getters and Setters
  String get name => _name;

  set name(String value) {
    _name = value;
    _updateFieldInFirebase('name', value);
  }

  Color get flowerColor => _flowerColor;

  set flowerColor(Color value) {
    _flowerColor = value;
    _updateFieldInFirebase('flowerColor', value.value);
  }

  Map<String, TaskState> get taskStates => _taskStates;

  set taskStates(Map<String, TaskState> value) {
    _taskStates = value;
    _updateFieldInFirebase(
      'taskStates',
      value.map((key, state) => MapEntry(key, state.name)),
    );
  }

  // Update Specific Field in Firebase
  Future<void> _updateFieldInFirebase(String field, dynamic value) async {
    try {
      await firestore.collection('users').doc(userId).update({field: value});
      print('$field updated in Firebase');
    } catch (e) {
      print('Failed to update $field in Firebase: $e');
    }
  }

  // Create User in Firebase
  static Future<User> create({required String name, required Color flowerColor}) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc();
    final user = User(
      userId: docRef.id,
      name: name,
      flowerColor: flowerColor,
    );
    await docRef.set(user.toJson());
    return user;
  }

  // Save Entire User Object to Firebase
  Future<void> saveToFirebase() async {
    try {
      await firestore.collection('users').doc(userId).set(toJson());
      print('User saved successfully to Firebase.');
    } catch (e) {
      print('Error saving user to Firebase: $e');
    }
  }

  // Remove User from Firebase
  Future<void> removeFromFirebase() async {
    try {
      await firestore.collection('users').doc(userId).delete();
      print('User removed successfully from Firebase.');
    } catch (e) {
      print('Error removing user from Firebase: $e');
    }
  }

  // Update a Specific Task State
  Future<void> updateTaskState(String taskId, TaskState? state) async {
    if (state == null) {
      _taskStates.remove(taskId);
    } else {
      _taskStates[taskId] = state;
    }

    _updateFieldInFirebase(
      'taskStates',
      _taskStates.map((key, value) => MapEntry(key, value.name)),
    );
  }

  // Get a Specific Task State
  Future<TaskState> getTaskState(String taskId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final taskStates = data?['taskStates'] as Map<String, dynamic>?;
        if (taskStates != null && taskStates.containsKey(taskId)) {
          return TaskState.values.byName(taskStates[taskId]);
        }
      }
      return TaskState.Undecided;
    } catch (e) {
      print('Error fetching task state for $taskId: $e');
      throw Exception('Failed to fetch task state.');
    }
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': _name,
      'flowerColor': _flowerColor.value,
      'taskStates': _taskStates.map((key, value) => MapEntry(key, value.name)),
    };
  }

  // Parse JSON to Create a User Object
  factory User.fromJson(String userId, Map<String, dynamic> json) {
    return User(
      userId: userId,
      name: json['name'] as String,
      flowerColor: Color(json['flowerColor'] as int),
      taskStates: (json['taskStates'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, TaskState.values.byName(value)),
          ) ??
          {},
    );
  }
}
