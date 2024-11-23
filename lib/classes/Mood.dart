import 'package:mental_load/classes/DBHandler.dart';

enum Moods { good, mid, bad }

class Mood {
  final int _moodId;
  int _userId;
  DateTime _date;
  Moods _mood;

  // Getters & Setters
  int get moodId => _moodId;
  int get userId => _userId;
  DateTime get date => _date;
  Moods get mood => _mood;

  set userId(value) => {_userId = value, DBHandler().saveMood(this)};
  set date(value) => {_date = value, DBHandler().saveMood(this)};
  set mood(value) => {_mood = value, DBHandler().saveMood(this)};

  // Private Constructor
  Mood._({
    required int moodId,
    required int userId,
    required DateTime date,
    required Moods mood,
  })  : _moodId = moodId,
        _userId = userId,
        _date = date,
        _mood = mood;

  // Factory Constructor with Auto ID
  static Future<Mood> create({
    required int userId,
    required DateTime date,
    required Moods mood,
  }) async {
    final id = await DBHandler().getNextMoodId();
    Mood mood2 = Mood._(
      moodId: id,
      userId: userId,
      date: date,
      mood: mood,
    );
    await DBHandler().saveMood(mood2);
    return mood2;
  }

  Map<String, dynamic> toJson() => {
        'moodId': _moodId,
        'userId': _userId,
        'date': _date.toIso8601String(),
        'mood': _mood.toString(),
      };

  static Mood fromJson(Map<String, dynamic> json) {
    return Mood._(
      moodId: json['moodId'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      mood: Moods.values.firstWhere((e) => e.toString() == json['mood']),
    );
  }

  @override
  String toString() {
    return 'Mood: {\n'
        '  moodId: $_moodId,\n'
        '  userId: $_userId,\n'
        '  date: ${_date.toIso8601String()},\n'
        '  mood: $_mood\n'
        '}';
  }
}
