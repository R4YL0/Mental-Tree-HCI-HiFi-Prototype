import 'DBHandler.dart';

class Subtask {
  int _id;
  String _name;
  bool _isDone;

  // Private Constructor
  Subtask._({
    required int id,
    required String name,
    bool isDone = false,
  })  : _id = id,
        _name = name,
        _isDone = isDone;

  // Factory Constructor with Auto ID
  static Future<Subtask> create({
    required String name,
    bool isDone = false,
  }) async {
    final id = await DBHandler().getNextSubtaskId();
    return Subtask._(id: id, name: name, isDone: isDone);
  }

  static Future<Subtask?> findById(int id) async {
    final subtasks = await DBHandler().getSubtasks();
    return subtasks.cast<Subtask?>().firstWhere(
      (subtask) => subtask?._id == id,
      orElse: () => null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': _name,
        'isDone': _isDone,
      };

  Subtask.fromJson(Map<String, dynamic> json)
      : _id = json['id'],
        _name = json['name'],
        _isDone = json['isDone'];
}
