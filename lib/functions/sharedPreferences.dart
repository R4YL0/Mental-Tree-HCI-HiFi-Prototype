import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int> getCurUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(constCurrentUserId) ?? 0;
}
