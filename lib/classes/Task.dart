import 'Subtask.dart';
import 'DBHandler.dart';

enum Frequency {daily, weekly, monthly, yearly}
// just add or remove some :)
enum Category {Cleaning, Laundry, Cooking, Outdoor, Childcare, Admin}

class Task {
  int _taskId;
  String _name;
  Category _category;
  Frequency _frequency;
  String _notes;
  String _imgDst;
  bool _isPrivate;
  int _difficulty;
  int _priority;
  List<Subtask> _subtasks;

  // Getters & Setters
  int get taskId => _taskId;
  String get name => _name;
  Category get category => _category;
  Frequency get frequency => _frequency;
  String get notes => _notes;
  String get imgDst => _imgDst;
  bool get isPrivate => _isPrivate;
  int get difficulty => _difficulty;
  int get priority => _priority;
  List<Subtask> get subtasks => _subtasks;

  set name(value) => {_name = value, DBHandler().saveTask(this)};
  set category(value) => {_category = value, DBHandler().saveTask(this)};
  set frequency(value) => {_frequency = value, DBHandler().saveTask(this)};
  set notes(value) => {_notes = value, DBHandler().saveTask(this)};
  set imgDst(value) => {_imgDst = value, DBHandler().saveTask(this)};
  set isPrivate(value) => {_isPrivate = value, DBHandler().saveTask(this)};
  set difficulty(value) => {_difficulty = value, DBHandler().saveTask(this)};
  set priority(value) => {_priority = value, DBHandler().saveTask(this)};
  set subtasks(value) => {_subtasks = value, DBHandler().saveTask(this)};

  // Private Constructor
  Task._({
    required int taskId,
    required String name,
    required Category category,
    required Frequency frequency,
    required String notes,
    required String imgDst,
    required bool isPrivate,
    required int difficulty,
    required int priority,
    List<Subtask> subtasks = const [],
  })  : _taskId = taskId,
        _name = name,
        _category = category,
        _frequency = frequency,
        _notes = notes,
        _imgDst = imgDst,
        _isPrivate = isPrivate,
        _difficulty = difficulty,
        _priority = priority,
        _subtasks = List.from(subtasks);

  // Factory Constructor with Auto ID
  static Future<Task> create({
    required String name,
    required Category category,
    required Frequency frequency,
    required String notes,
    required String imgDst,
    required bool isPrivate,
    required int difficulty,
    required int priority,
    List<Subtask> subtasks = const [],
  }) async {
    final id = await DBHandler().getNextTaskId();
    Task task = Task._(
      taskId: id,
      name: name,
      category: category,
      frequency: frequency,
      notes: notes,
      imgDst: imgDst,
      isPrivate: isPrivate,
      difficulty: difficulty,
      priority: priority,
      subtasks: subtasks,
    );
    await DBHandler().saveTask(task);
    return task;
  }

  // Find a Task by ID
  static Future<Task?> findById(int taskId) async {
    final tasks = await DBHandler().getTasks();
    return tasks.cast<Task?>().firstWhere(
      (task) => task?._taskId == taskId,
      orElse: () => null,
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': _taskId,
        'name': _name,
        'category': _category.toString(),
        'frequency': _frequency.toString(),
        'notes': _notes,
        'imgDst': _imgDst,
        'isPrivate': _isPrivate,
        'difficulty': _difficulty,
        'priority': _priority,
        'subtasks': _subtasks.map((subtask) => subtask.toJson()).toList(),
      };

  Task.fromJson(Map<String, dynamic> json)
      : _taskId = json['taskId'],
        _name = json['name'],
        _category = Category.values.firstWhere((e) => e.toString() == json['category']),
        _frequency = Frequency.values.firstWhere((e) => e.toString() == json['frequency']),
        _notes = json['notes'],
        _imgDst = json['imgDst'],
        _isPrivate = json['isPrivate'],
        _difficulty = json['difficulty'],
        _priority = json['priority'],
        _subtasks = (json['subtasks'] as List).map((item) => Subtask.fromJson(item)).toList();

        @override
        String toString() {
          return 'Task: {\n'
        '  taskId: $_taskId,\n'
        '  name: $_name,\n'
        '  category: $_category,\n'
        '  frequency: $_frequency,\n'
        '  notes: $_notes,\n'
        '  imgDst: $_imgDst,\n'
        '  isPrivate: $_isPrivate,\n'
        '  difficulty: $_difficulty,\n'
        '  priority: $_priority,\n'
        '  subtasks: [\n'
        '${_subtasks.map((subtask) => '    ${subtask.toString()}').join(',\n')}\n'
        '  ]\n'
        '}';
}

}




