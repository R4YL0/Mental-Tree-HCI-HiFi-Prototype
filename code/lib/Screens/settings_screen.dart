import 'package:flutter/material.dart';
import 'package:mental_load/Screens/group_screen.dart';
import 'package:mental_load/Screens/home_screen.dart';
import 'package:mental_load/Screens/navigator_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/functions/sharedPreferences.dart';
import 'package:mental_load/widgets/tutorial_widget.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<String> _segmentAB = {"A"};
  Set<String> _segmentSML = {"S"};
  bool _userChanged = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchAB();
    _loadSwitchSML();
  }

  Future<void> _loadSwitchAB() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _segmentAB = {prefs.getString(constTestVersion) ?? "A"};
    });
  }

  Future<void> _loadSwitchSML() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _segmentSML = {prefs.getString(constDataSet) ?? "S"};
    });
  }

  void _onSelectionChangedAB(Set<String> newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _segmentAB = newValue;
      prefs.setString(constTestVersion, _segmentAB.first);
    });
  }

  void _onSelectionChangedSML(Set<String> newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _segmentSML = newValue;
      prefs.setString(constDataSet, _segmentSML.first);
    });
  }

  void _onPressedGroup(BuildContext context) async {
    final dynamic result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupScreen()));
    if (result) {
      setState(() {
        _userChanged = true;
      });
    }
  }

  void _onPressedTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    String? curUserId = prefs.getString(constCurrentUserId);
    print(curUserId);
    if (curUserId != null) {
      User? curUser = await DBHandler().getCurUser();
      if (curUser != null) {
        print(curUser);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NavigatorScreen(),
        ));
        await showDialog(context: context, builder: (BuildContext context) => TutorialWidget(user: curUser));
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _onPressedReset() async {
    final confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Reset"),
          content: const Text("Are you sure you want to reset all open assigned tasks, remove all submitted users, and reset task preferences? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Perform reset actions
      await DBHandler().removeAllAssignedTasks();
      await DBHandler().resetAllSubmittedUsers();
      await DBHandler().resetAllUserPreferences();

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All data has been reset successfully.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, _userChanged);
              }),
        ),
        body: SettingsList(sections: [
          SettingsSection(
            title: const Text('User'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.group),
                title: const Text('Group'),
                value: const Text('Awesome User group'),
                onPressed: _onPressedGroup,
              ),
            ],
          ),
          SettingsSection(tiles: [
            CustomSettingsTile(
              child: SegmentedButton(
                segments: const [
                  ButtonSegment(value: "A", label: Text("Test A")),
                  ButtonSegment<String>(value: "B", label: Text("Test B")),
                ],
                selected: _segmentAB,
                onSelectionChanged: _onSelectionChangedAB,
              ),
            ),
          ]),
          SettingsSection(tiles: [
            CustomSettingsTile(
              child: SegmentedButton(
                segments: const [
                  ButtonSegment(value: "S", label: Text("Small Dataset")),
                  ButtonSegment<String>(value: "M", label: Text("Medium Dataset")),
                  ButtonSegment<String>(value: "L", label: Text("Large Dataset")),
                ],
                selected: _segmentSML,
                onSelectionChanged: _onSelectionChangedSML,
              ),
            ),
          ]),
          SettingsSection(tiles: [
            CustomSettingsTile(child: ElevatedButton(onPressed: _onPressedTutorial, child: const Text("Tutorial"))),
            CustomSettingsTile(child: ElevatedButton(onPressed: _onPressedReset, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Reset All Data"))),
          ])
        ]));
  }
}
