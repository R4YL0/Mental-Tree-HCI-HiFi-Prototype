import 'package:cloud_firestore/cloud_firestore.dart';

enum Moods { good, mid, bad }

class Mood {
  final String moodId;
  String userId;
  DateTime date;
  Moods mood;

  // Constructor
  Mood({
    required this.moodId,
    required this.userId,
    required this.date,
    required this.mood,
  });

  // Create Mood with Unique ID
static Future<Mood> create({
  required String userId, // Change this to match your userId type
  required DateTime date,
  required Moods mood,
}) async {
  final docRef = FirebaseFirestore.instance.collection('moods').doc();
  final moodObj = Mood(
    moodId: docRef.id,
    userId: userId, // Pass userId as a string
    date: date,
    mood: mood,
  );
  await docRef.set(moodObj.toJson());
  return moodObj;
}


  // Save Mood to Firebase
  Future<void> saveToFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Save mood data to Firestore
      await firestore.collection('moods').doc(moodId).set(toJson());
      print('Mood saved successfully to Firebase.');
    } catch (e) {
      print('Error saving mood to Firebase: $e');
    }
  }

  // Remove Mood from Firebase
  Future<void> removeFromFirebase() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Delete mood document from Firestore
      await firestore.collection('moods').doc(moodId).delete();
      print('Mood removed successfully from Firebase.');
    } catch (e) {
      print('Error removing mood from Firebase: $e');
    }
  }

  // Convert Mood to JSON
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'date': date.toIso8601String(),
        'mood': mood.name, // Convert enum to string
      };

  // Parse JSON to Create a Mood Object
  factory Mood.fromJson(String moodId, Map<String, dynamic> json) {
    return Mood(
      moodId: moodId,
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      mood: Moods.values.firstWhere((e) => e.name == json['mood']),
    );
  }

  @override
  String toString() {
    return 'Mood: {\n'
        '  moodId: $moodId,\n'
        '  userId: $userId,\n'
        '  date: $date,\n'
        '  mood: $mood\n'
        '}';
  }
}
