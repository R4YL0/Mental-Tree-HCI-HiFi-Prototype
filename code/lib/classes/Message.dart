import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';

enum MessageType { help, trade, tradeAccepted, tradeDeclined, reminder, thanks }

class Message {
  final String messageId;
  final AssignedTask? task;
  final AssignedTask? offerTask;
  final AssignedTask? receiveTask;
  final User? from;
  final User? to;
  final MessageType type;
  final String timestamp;
  bool read;
  bool thankYouSent;

  Message({
    required this.messageId,
    this.task,
    this.offerTask,
    this.receiveTask,
    this.from,
    this.to,
    required this.type,
    required this.timestamp,
    this.read = false, // Default to false
    this.thankYouSent = false, // Default to false
  });

  /// Create a Message with Unique ID and Save to Firebase
  static Future<Message> create({
    required AssignedTask? task,
    required AssignedTask? offerTask,
    required AssignedTask? receiveTask,
    required User from,
    required User to,
    required MessageType type,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Generate a unique document ID for the message
    final docRef = firestore.collection('messages').doc();
    final String messageId = docRef.id;

    // Create a timestamp for the message
    final String timestamp = DateTime.now().toIso8601String();

    // Construct the Message object
    final message = Message(
      messageId: messageId,
      task: task,
      offerTask: offerTask,
      receiveTask: receiveTask,
      from: from,
      to: to,
      type: type,
      timestamp: timestamp,
      read: false, // Default to unread when created
      thankYouSent: false, // Default to false when created
    );

    // Save the message to Firestore
    await docRef.set(message.toJson());

    return message;
  }

  /// Save Message to Firebase
  Future<void> saveToFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('messages').doc(messageId).set(toJson());
      print('Message saved successfully to Firebase.');
    } catch (e) {
      print('Error saving message to Firebase: $e');
      throw e;
    }
  }

  Future<void> updateFieldsInFirebase({
    bool? read,
    bool? thankYouSent,
    AssignedTask? task, // Fixed parameter type
    AssignedTask? offerTask, // Fixed parameter type
    AssignedTask? receiveTask, // Fixed parameter type
    User? from,
    User? to,
    MessageType? type,
    String? timestamp,
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      Map<String, dynamic> fieldsToUpdate = {};

      // Add fields to update map if not null
      if (read != null) fieldsToUpdate['read'] = read;
      if (thankYouSent != null) fieldsToUpdate['thankYouSent'] = thankYouSent;
      if (task != null) fieldsToUpdate['taskId'] = task.assignedTaskId; // Fixed to use assignedTaskId
      if (offerTask != null) fieldsToUpdate['offerTaskId'] = offerTask.assignedTaskId; // Fixed to use assignedTaskId
      if (receiveTask != null) fieldsToUpdate['receiveTaskId'] = receiveTask.assignedTaskId; // Fixed to use assignedTaskId
      if (from != null) fieldsToUpdate['fromUserId'] = from.userId;
      if (to != null) fieldsToUpdate['toUserId'] = to.userId;
      if (type != null) fieldsToUpdate['type'] = type.toString().split('.').last;
      if (timestamp != null) fieldsToUpdate['timestamp'] = timestamp;

      if (fieldsToUpdate.isNotEmpty) {
        await firestore.collection('messages').doc(messageId).update(fieldsToUpdate);
        print('Message fields updated successfully in Firebase.');
      } else {
        print('No fields to update.');
      }
    } catch (e) {
      print('Error updating fields in Firebase: $e');
      throw e;
    }
  }

  /// Remove Message from Firebase
  Future<void> removeFromFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('messages').doc(messageId).delete();
      print('Message removed successfully from Firebase.');
    } catch (e) {
      print('Error removing message from Firebase: $e');
      throw e;
    }
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'taskId': task?.assignedTaskId, // Fixed to use assignedTaskId
        'offerTaskId': offerTask?.assignedTaskId, // Fixed to use assignedTaskId
        'receiveTaskId': receiveTask?.assignedTaskId, // Fixed to use assignedTaskId
        'fromUserId': from?.userId,
        'toUserId': to?.userId,
        'type': type.toString().split('.').last,
        'timestamp': timestamp,
        'read': read, // Include the read status in JSON
        'thankYouSent': thankYouSent, // Include the thank you status in JSON
      };

  /// Create a Message from JSON, fetching tasks and users from Firebase
  static Future<Message> fromJson(Map<String, dynamic> json) async {
    final String messageId = json['messageId'];
    final String? taskId = json['taskId'];
    final String? offerTaskId = json['offerTaskId'];
    final String? receiveTaskId = json['receiveTaskId'];
    final String? assignedTaskId = json['assignedTaskId']; // Load assignedTaskId
    final String? fromUserId = json['fromUserId'];
    final String? toUserId = json['toUserId'];

    final AssignedTask? task = taskId != null ? await DBHandler().getAssignedTaskById(taskId) : null;
    final AssignedTask? offerTask = offerTaskId != null ? await DBHandler().getAssignedTaskById(offerTaskId) : null;
    final AssignedTask? receiveTask = receiveTaskId != null ? await DBHandler().getAssignedTaskById(receiveTaskId) : null;
    final User? from = fromUserId != null ? await DBHandler().getUserById(fromUserId) : null;
    final User? to = toUserId != null ? await DBHandler().getUserById(toUserId) : null;

    final MessageType type = MessageType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
      orElse: () => throw Exception('Invalid MessageType: ${json['type']}'),
    );

    final String timestamp = json['timestamp'];
    final bool read = json['read'] ?? false; // Default to false if not present
    final bool thankYouSent = json['thankYouSent'] ?? false; // Default to false if not present

    return Message(
      messageId: messageId,
      task: task,
      offerTask: offerTask,
      receiveTask: receiveTask,
      from: from,
      to: to,
      type: type,
      timestamp: timestamp,
      read: read, // Load the read status
      thankYouSent: thankYouSent, // Load the thank you status
    );
  }
}
