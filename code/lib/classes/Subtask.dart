import 'package:cloud_firestore/cloud_firestore.dart';

class Subtask {
  String subtaskId; // Firestore Document ID
  String taskId; // Parent Task ID
  String name;
  bool isDone;

  // Constructor
  Subtask({
    required this.subtaskId,
    required this.taskId,
    required this.name,
    this.isDone = false,
  });

  // Create Subtask with Unique ID
  static Future<Subtask> create({
    required String taskId,
    required String name,
    bool isDone = false,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final docRef = firestore.collection('subtasks').doc();
      final subtask = Subtask(
        subtaskId: docRef.id,
        taskId: taskId,
        name: name,
        isDone: isDone,
      );

      await docRef.set(subtask.toJson());
      return subtask;
    } catch (e) {
      throw Exception('Error creating subtask: $e');
    }
  }
  

  Subtask copy() {
    return Subtask(
      subtaskId: subtaskId, // Copy the same subtaskId
      taskId: taskId, // Copy the parent taskId
      name: name, // Copy the subtask name
      isDone: isDone, // Copy the isDone status
    );
  }

// Static method to create a default subtask
  static Subtask defaultSubtask() {
    return Subtask(
      subtaskId: "default",
      taskId: "default_task",
      name: "Default Subtask",
      isDone: false,
    );
  }

  // Save Subtask to Firebase
  Future<void> saveToFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Save subtask to Firestore
      await firestore.collection('subtasks').doc(subtaskId).set({
        'taskId': taskId,
        'name': name,
        'isDone': isDone,
      });
      print('Subtask saved successfully to Firebase.');
    } catch (e) {
      print('Error saving subtask to Firebase: $e');
    }
  }

  // Remove Subtask from Firebase
  Future<void> removeFromFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Delete the subtask document from Firestore
      await firestore.collection('subtasks').doc(subtaskId).delete();
      print('Subtask removed successfully from Firebase.');
    } catch (e) {
      print('Error removing subtask from Firebase: $e');
    }
  }

  // Convert Subtask to JSON
  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'name': name,
        'isDone': isDone,
      };

  // Parse JSON to Create a Subtask Object
  factory Subtask.fromJson(String subtaskId, Map<String, dynamic> json) {
    return Subtask(
      subtaskId: subtaskId,
      taskId: json['taskId'],
      name: json['name'],
      isDone: json['isDone'],
    );
  }

  @override
  String toString() {
    return 'Subtask: {\n'
        '  subtaskId: $subtaskId,\n'
        '  taskId: $taskId,\n'
        '  name: $name,\n'
        '  isDone: $isDone\n'
        '}';
  }
}
