import 'package:flutter/material.dart';
import 'package:mental_load/Screens/group_screen.dart';
import 'package:mental_load/Screens/home_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/widgets/tutorial_widget.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<String> _segmentAB = {"A"};
  bool _userChanged = false;

  @override
  void initState() {
    super.initState();
    _loadSwitchAB();
  }

  Future<void> _loadSwitchAB() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _segmentAB = {prefs.getString(constTestVersion) ?? "A"};
    });
  }

  void _onSelectionChangedAB(Set<String> newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _segmentAB = newValue;
      prefs.setString(constTestVersion, _segmentAB.first);
    });
  }

  void _onPressedGroup(BuildContext context) async {
    final dynamic result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const GroupScreen()));
    if (result) {
      setState(() {
        _userChanged = true;
      });
    }
  }

  void _onPressedTutorial() async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => HomeScreen(),
    ));
    final prefs = await SharedPreferences.getInstance();
    int? curUserId = prefs.getInt(constCurrentUserId);
    if (curUserId != null) {
      User? curUser = await DBHandler().getUserByUserId(curUserId);
      if (curUser != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) => TutorialWidget(user: curUser));
      }
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
                child: ElevatedButton(
                    onPressed: _onPressedTutorial,
                    child: const Text("Tutorial")))
          ])
        ]));
  }
}
