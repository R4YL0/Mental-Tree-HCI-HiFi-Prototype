import 'package:flutter/material.dart';
import 'package:mental_load/Screens/group_screen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const constTestVersion = "test_version";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<String> _segmentAB = {"A"};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SettingsList(sections: [
          SettingsSection(
            title: const Text('User'),
            tiles: [
              SettingsTile.navigation(
                leading: const Icon(Icons.group),
                title: const Text('Group'),
                value: const Text('Awesome User group'),
                onPressed: (context) => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GroupScreen()))
                },
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
          ])
        ]));
  }
}
