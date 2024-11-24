import 'package:flutter/material.dart';
import 'DBHandler.dart';

class User {
  int _userId;
  String _name;
  Color _flowerColor;

   // Getters & Setters
  int get userId => _userId;
  String get name => _name;
  Color get flowerColor => _flowerColor;

  set name(value) => {_name = value, DBHandler().saveUser(this)};
  set flowerColor(value) => {_flowerColor = value, DBHandler().saveUser(this)};

  // Private Constructor
  User._({
    required int userId,
    required String name,
    required Color flowerColor,
  })  : _userId = userId,
        _name = name,
        _flowerColor = flowerColor;

  // Factory Constructor with Auto ID
  static Future<User> create({
    required String name,
    required Color flowerColor,
  }) async {
    final id = await DBHandler().getNextUserId();
    User user = User._(userId: id, name: name, flowerColor: flowerColor);
    await DBHandler().saveUser(user);
    return user;
  }

  // Convert to from Json for DB
  Map<String, dynamic> toJson() => {
        'userId': _userId,
        'name': _name,
        'flowerColor': _flowerColor.value,
      };

  User.fromJson(Map<String, dynamic> json)
      : _userId = json['userId'],
        _name = json['name'],
        _flowerColor = Color(json['flowerColor']);

  @override
  String toString() {
    return 'User: {\n'
        '  userId: $_userId,\n'
        '  name: $_name,\n'
        '  flowerColor: #${_flowerColor.value.toRadixString(16).padLeft(8, '0')}\n'
        '}';
  }
}
