import 'package:mental_load/classes/DBHandler.dart';

class Mood {
  int _moodId;
  int _userId;
  DateTime _date;
  String _mood;

  // Getters for private fields
  int get moodId => _moodId;
  int get userId => _userId;
  DateTime get date => _date;
  String get mood => _mood;

  // Private Constructor
  Mood._({
    required int moodId,
    required int userId,
    required DateTime date,
    required String mood,
  })  : _moodId = moodId,
        _userId = userId,
        _date = date,
        _mood = mood;

  // Factory Constructor with Auto ID
  static Future<Mood> create({
    required int userId,
    required DateTime date,
    required String mood,
  }) async {
    final id = await DBHandler().getNextMoodId();
    return Mood._(
      moodId: id,
      userId: userId,
      date: date,
      mood: mood,
    );
  }

  Map<String, dynamic> toJson() => {
        'moodId': _moodId,
        'userId': _userId,
        'date': _date.toIso8601String(),
        'mood': _mood,
      };

  static Mood fromJson(Map<String, dynamic> json) {
    return Mood._(
      moodId: json['moodId'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      mood: json['mood'],
    );
  }
}
