import 'DBHandler.dart';

class Subtask {
  int _id;
  String _name;
  bool _isDone;

  // Getters & Setters
  int get subtaskId => _id;
  String get name => _name;
  bool get isDone => _isDone;

  set name(value) => {_name = value, DBHandler().saveSubtask(this)};
  set isDone(value) => {_isDone = value, DBHandler().saveSubtask(this)};

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
    Subtask subtask = Subtask._(id: id, name: name, isDone: isDone);
    await DBHandler().saveSubtask(subtask);
    return subtask;
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

  @override
  String toString() {
    return 'Subtask: {\n'
        '  id: $_id,\n'
        '  name: $_name,\n'
        '  isDone: $_isDone\n'
        '}';
}

}




