import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'Subtask.dart';
import 'package:flutter/services.dart';

enum Frequency { daily, weekly, monthly, yearly, oneTime }

enum Category { Cleaning, Laundry, Cooking, Outdoor, Childcare, Admin }

class Task {
  static Uint8List? _cachedDefaultImage;

  final String taskId;
  String name;
  Category category;
  Frequency frequency;
  String notes;
  bool isPrivate;
  int difficulty;
  int priority;
  List<Subtask> subtasks;
  String? imageUrl;
  late Uint8List img; // Ensure img is always initialized
  DateTime? startDate;
  DateTime? dueDate;
  bool isSaved;

  static const String defaultImagePath = 'lib/assets/images/defaultTaskImg.jpg';

  Task({
    required this.taskId,
    required this.name,
    required this.category,
    required this.frequency,
    required this.notes,
    required this.isPrivate,
    required this.difficulty,
    required this.priority,
    required this.isSaved,
    this.subtasks = const [],
    this.imageUrl,
    required this.img, // img is now required
    this.startDate,
    this.dueDate,
  });

  // Create a new Task in Firestore
  static Future<Task> create({
    required String name,
    required Category category,
    required Frequency frequency,
    required String notes,
    required bool isPrivate,
    required int difficulty,
    required int priority,
    List<Subtask> subtasks = const [],
    Uint8List? img,
    DateTime? startDate,
    DateTime? dueDate,
    bool saveTask = true,
  }) async {
    String taskId = saveTask ? FirebaseFirestore.instance.collection('tasks').doc().id : 'temporary-task-id';
    String? imageUrl;

    // Use default image if none is provided
    img ??= await _loadDefaultImage();

    if (saveTask) {
      // Upload image to Firebase Storage and get the download URL
      try {
        final ref = FirebaseStorage.instance.ref().child('tasks/$taskId.jpg');
        final uploadTask = await ref.putData(img);
        imageUrl = await uploadTask.ref.getDownloadURL();

        // Download the image back into the Uint8List format to ensure consistency
        img = await ref.getData();
        if (img == null) {
          throw Exception('Failed to download the uploaded image back as Uint8List.');
        }
      } catch (e) {
        throw Exception('Error uploading image: $e');
      }

      // Save subtasks to Firestore and update their taskId
      for (var subtask in subtasks) {
        subtask.taskId = taskId; // Link to the current task
        await subtask.saveToFirebase();
      }

      // Save the Task object to Firestore
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('tasks').doc(taskId).set({
        'name': name,
        'category': category.index,
        'frequency': frequency.index,
        'notes': notes,
        'isPrivate': isPrivate,
        'difficulty': difficulty,
        'priority': priority,
        'subtaskIds': subtasks.map((subtask) => subtask.subtaskId).toList(),
        'imageUrl': imageUrl,
        'startDate': startDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
      });
    }

    // Return Task object with isSaved set appropriately
    return Task(
      taskId: taskId,
      name: name,
      category: category,
      frequency: frequency,
      notes: notes,
      isPrivate: isPrivate,
      difficulty: difficulty,
      priority: priority,
      subtasks: subtasks,
      img: img,
      imageUrl: imageUrl,
      startDate: startDate,
      dueDate: dueDate,
      isSaved: saveTask, // Set isSaved based on saveTask
    );
  }

  Task copy() {
    return Task(
      taskId: taskId,
      name: name,
      priority: priority,
      difficulty: difficulty,
      subtasks: subtasks.map((subtask) => subtask.copy()).toList(),
      img: Uint8List.fromList(img),
      dueDate: dueDate,
      startDate: startDate,
      notes: notes,
      category: category,
      frequency: frequency,
      isPrivate: false,
      isSaved: isSaved,
    );
  }

  // Convert Task to JSON for Firestore
  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.index,
        'frequency': frequency.index,
        'notes': notes,
        'isPrivate': isPrivate,
        'difficulty': difficulty,
        'priority': priority,
        'subtaskIds': subtasks.map((subtask) => subtask.subtaskId).toList(),
        'imageUrl': imageUrl,
        'startDate': startDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'isSaved': isSaved,
      };

  // Create Task from JSON, including loading subtasks
  static Future<Task> fromJson(String taskId, Map<String, dynamic> json) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // Fetch subtasks based on the stored subtask IDs
    final List<Subtask> subtasks = [];
    if (json['subtaskIds'] != null) {
      for (var subtaskId in List<String>.from(json['subtaskIds'])) {
        final subtaskDoc = await firestore.collection('subtasks').doc(subtaskId).get();
        if (subtaskDoc.exists) {
          subtasks.add(Subtask.fromJson(subtaskId, subtaskDoc.data() as Map<String, dynamic>));
        }
      }
    }

    // Fetch the image from Firebase Storage or load the default image if imageUrl is not present
    Uint8List img;
    try {
      if (json['imageUrl'] != null && json['imageUrl'].isNotEmpty) {
        final ref = storage.refFromURL(json['imageUrl']);
        img = await ref.getData() ?? await _loadDefaultImage();
      } else {
        img = await _loadDefaultImage();
      }
    } catch (e) {
      img = await _loadDefaultImage();
    }

    return Task(
      taskId: taskId,
      name: json['name'],
      category: Category.values[json['category']],
      frequency: Frequency.values[json['frequency']],
      notes: json['notes'],
      isPrivate: json['isPrivate'],
      difficulty: json['difficulty'],
      priority: json['priority'],
      subtasks: subtasks,
      imageUrl: json['imageUrl'],
      img: img,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isSaved: true, // Tasks loaded from Firestore are saved
    );
  }

  static Future<Uint8List> _loadDefaultImage() async {
    if (_cachedDefaultImage != null) {
      return _cachedDefaultImage!;
    }

    try {
      final byteData = await rootBundle.load(defaultImagePath);
      _cachedDefaultImage = byteData.buffer.asUint8List();
      return _cachedDefaultImage!;
    } catch (e) {
      throw Exception('Error loading default image: $e');
    }
  }

  // Create a default Task with pre-set values
  static Future<Task> createDefaultTask() async {
    final defaultName = "Add Title";
    final defaultCategory = Category.Cleaning;
    final defaultFrequency = Frequency.oneTime;
    final defaultNotes = "Click to add notes";
    final defaultIsPrivate = false;
    final defaultDifficulty = 1; // Example difficulty range from 1 to 5
    final defaultPriority = 1; // Example priority range from 1 to 10
    final defaultSubtasks = <Subtask>[]; // Empty subtasks
    final defaultStartDate = DateTime.now();
    final defaultDueDate = DateTime.now().add(Duration(days: 7)); // One week from now

    // Load the default image
    Uint8List defaultImage = await _loadDefaultImage();

    return await Task.create(
      name: defaultName,
      category: defaultCategory,
      frequency: defaultFrequency,
      notes: defaultNotes,
      isPrivate: defaultIsPrivate,
      difficulty: defaultDifficulty,
      priority: defaultPriority,
      subtasks: defaultSubtasks,
      img: defaultImage,
      startDate: defaultStartDate,
      dueDate: defaultDueDate,
      saveTask: false,
    );
  }

  Future<void> removeFromFirebase() async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    try {
      // Remove associated subtasks
      for (final subtask in subtasks) {
        await firestore.collection('subtasks').doc(subtask.subtaskId).delete();
      }

      // Remove the task's image from Firebase Storage, if it exists
      if (imageUrl != null && imageUrl!.isNotEmpty) {
        try {
          final ref = storage.refFromURL(imageUrl!);
          await ref.delete();
        } catch (e) {
          print('Error deleting image from Firebase Storage: $e');
        }
      }

      // Remove the task document from Firestore
      await firestore.collection('tasks').doc(taskId).delete();

      print('Task $taskId and its associated data were successfully removed.');
    } catch (e) {
      print('Error removing task $taskId from Firebase: $e');
      throw Exception('Error removing task from Firebase: $e');
    }
  }

  Future<void> saveToFirebase() async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    try {
      // Check if the task already exists
      final taskDoc = firestore.collection('tasks').doc(taskId);
      final taskSnapshot = await taskDoc.get();

      // Upload the image to Firebase Storage
      String? uploadedImageUrl;
      if (img.isNotEmpty) {
        final ref = storage.ref().child('tasks/$taskId.jpg');
        await ref.putData(img);
        uploadedImageUrl = await ref.getDownloadURL();
      }

      // Update the imageUrl property if the upload was successful
      if (uploadedImageUrl != null) {
        imageUrl = uploadedImageUrl;
      }

      final taskData = toJson(); // Convert the task to a JSON map
      taskData['imageUrl'] = imageUrl; // Ensure the imageUrl is updated in Firestore

      // If the task exists, update it; otherwise, create a new one
      if (taskSnapshot.exists) {
        await taskDoc.update(taskData);
        print('Task updated successfully.');
      } else {
        await taskDoc.set(taskData);
        print('Task saved successfully.');
      }

      // Save subtasks if any
      for (final subtask in subtasks) {
        subtask.taskId = taskId; // Link subtasks to this task
        await subtask.saveToFirebase();
      }

      isSaved = true; // Mark the task as saved
    } catch (e) {
      print('Error saving/updating task: $e');
      throw Exception('Error saving/updating task: $e');
    }
  }
}
