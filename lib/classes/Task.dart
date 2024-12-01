import 'dart:convert';
import 'dart:typed_data';
import 'Subtask.dart';
import 'DBHandler.dart';

enum Frequency { daily, weekly, monthly, yearly, oneTime }

enum Category { Cleaning, Laundry, Cooking, Outdoor, Childcare, Admin }

class Task {
  int _taskId;
  String _name;
  Category _category;
  Frequency _frequency;
  String _notes;
  bool _isPrivate;
  int _difficulty;
  int _priority;
  List<Subtask> _subtasks;
  Uint8List _img;
  String _imgBase64;
  DateTime? _startDate;
  DateTime? _dueDate;

  // Getters & Setters
  int get taskId => _taskId;
  String get name => _name;
  Category get category => _category;
  Frequency get frequency => _frequency;
  String get notes => _notes;
  bool get isPrivate => _isPrivate;
  int get difficulty => _difficulty;
  int get priority => _priority;
  List<Subtask> get subtasks => _subtasks;
  Uint8List get img => _img;
  String get imgBase64 => _imgBase64;
  DateTime? get startDate => _startDate;
  DateTime? get dueDate => _dueDate;

  set name(value) => {_name = value, DBHandler().saveTask(this)};
  set category(value) => {_category = value, DBHandler().saveTask(this)};
  set frequency(value) => {_frequency = value, DBHandler().saveTask(this)};
  set notes(value) => {_notes = value, DBHandler().saveTask(this)};
  set img(value) => {_img = value, _updateImg(value), DBHandler().saveTask(this)};
  set isPrivate(value) => {_isPrivate = value, DBHandler().saveTask(this)};
  set difficulty(value) => {_difficulty = value, DBHandler().saveTask(this)};
  set priority(value) => {_priority = value, DBHandler().saveTask(this)};
  set subtasks(value) => {_subtasks = value, DBHandler().saveTask(this)};
  set startDate(value) => {_startDate = value, DBHandler().saveTask(this)};
  set dueDate(value) => {_dueDate = value, DBHandler().saveTask(this)};

  // Private Constructor
  Task._({
    required int taskId,
    required String name,
    required Category category,
    required Frequency frequency,
    required String notes,
    required bool isPrivate,
    required int difficulty,
    required int priority,
    List<Subtask> subtasks = const [],
    required Uint8List img,
    required String imgBase64,
    DateTime? startDate,
    DateTime? dueDate,
  })  : _taskId = taskId,
        _name = name,
        _category = category,
        _frequency = frequency,
        _notes = notes,
        _isPrivate = isPrivate,
        _difficulty = difficulty,
        _priority = priority,
        _subtasks = List.from(subtasks),
        _img = img,
        _imgBase64 = imgBase64,
        _startDate = startDate,
        _dueDate = dueDate;

  // Factory Constructor with Auto ID
  static Future<Task> create({
    required String name,
    required Category category,
    required Frequency frequency,
    required String notes,
    required bool isPrivate,
    required int difficulty,
    required int priority,
    DateTime? startDate,
    DateTime? dueDate,
    List<Subtask> subtasks = const [],
    Uint8List? img,
  }) async {
    final id = await DBHandler().getNextTaskId();
    String imgString = img != null ? base64Encode(img) : base64Encode(DBHandler().defaultTaskImg);

    Task task = Task._(
      taskId: id,
      name: name,
      category: category,
      frequency: frequency,
      notes: notes,
      isPrivate: isPrivate,
      difficulty: difficulty,
      priority: priority,
      subtasks: subtasks,
      img: img ?? DBHandler().defaultTaskImg,
      imgBase64: imgString,
      startDate: startDate,
      dueDate: dueDate,
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

  Future<void> _updateImg(Uint8List img) async {
    _imgBase64 = base64Encode(img);
  }

  Map<String, dynamic> toJson() => {
        'taskId': _taskId,
        'name': _name,
        'category': _category.toString(),
        'frequency': _frequency.toString(),
        'notes': _notes,
        'imgBase64': _imgBase64,
        'isPrivate': _isPrivate,
        'difficulty': _difficulty,
        'priority': _priority,
        'subtasks': _subtasks.map((subtask) => subtask.toJson()).toList(),
        'startDate': _startDate?.toIso8601String(),
        'dueDate': _dueDate?.toIso8601String(),
      };

  Task.fromJson(Map<String, dynamic> json)
      : _taskId = json['taskId'],
        _name = json['name'],
        _category = Category.values.firstWhere((e) => e.toString() == json['category']),
        _frequency = Frequency.values.firstWhere((e) => e.toString() == json['frequency']),
        _notes = json['notes'],
        _imgBase64 = json['imgBase64'],
        _img = base64Decode(json['imgBase64']),
        _isPrivate = json['isPrivate'],
        _difficulty = json['difficulty'],
        _priority = json['priority'],
        _subtasks = (json['subtasks'] as List).map((item) => Subtask.fromJson(item)).toList(),
        _startDate = json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
        _dueDate = json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null;

  @override
  String toString() {
    return 'Task: {\n'
        '  taskId: $_taskId,\n'
        '  name: $_name,\n'
        '  category: $_category,\n'
        '  frequency: $_frequency,\n'
        '  notes: $_notes,\n'
        '  isPrivate: $_isPrivate,\n'
        '  difficulty: $_difficulty,\n'
        '  priority: $_priority,\n'
        '  startDate: $_startDate,\n'
        '  dueDate: $_dueDate,\n'
        '  subtasks: [\n'
        '${_subtasks.map((subtask) => '    ${subtask.toString()}').join(',\n')}\n'
        '  ]\n'
        '}';
  }
}

Future<Task> createDefaultTask() async {
    return Task.create(
      name: "Add name",
      category: Category.Admin,
      frequency: Frequency.oneTime,
      notes: "Add notes or description",
      isPrivate: false,
      difficulty: 1,
      priority: 1,
      startDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
    );
  }
