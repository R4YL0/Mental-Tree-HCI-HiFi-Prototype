import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getCurUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(constCurrentUserId);

  if (userId != null) {
    return userId;
  }

  // Fetch the first user from the database if no user ID is found
  final users = await DBHandler().getUsers();
  if (users.isNotEmpty) {
    final firstUser = users.first;
    // Optionally save this user as the current user
    await prefs.setString(constCurrentUserId, firstUser.userId);
    return firstUser.userId;
  }

  // Handle the case where no users exist in the database
  throw Exception("No users found in the database.");
}

