import 'package:flutter/material.dart';
import 'DBHandler.dart';

class User {
  int _userId;
  String _name;
  Color _flowerColor;

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
    return User._(userId: id, name: name, flowerColor: flowerColor);
  }

  // Getter for userId
  int get userId => _userId;

  Map<String, dynamic> toJson() => {
        'userId': _userId,
        'name': _name,
        'flowerColor': _flowerColor.value, // Store color as an integer
      };

  User.fromJson(Map<String, dynamic> json)
      : _userId = json['userId'],
        _name = json['name'],
        _flowerColor = Color(json['flowerColor']);
}
