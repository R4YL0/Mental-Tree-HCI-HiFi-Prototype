import 'package:flutter/material.dart';
import 'package:mental_load/Screens/group_screen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testVersion = "test_version";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _switchAB = true; // true = A, false = B

  @override
  void initState() {
    super.initState();
    _loadSwitchAB();
  }

  Future<void> _loadSwitchAB() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _switchAB = prefs.getBool(testVersion) ?? true;
    });
  }

  void _onSwitchAB(bool newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _switchAB = !_switchAB;
      prefs.setBool(testVersion, _switchAB);
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
            SettingsTile.switchTile(
                initialValue: _switchAB,
                onToggle: _onSwitchAB,
                title: const Text("Test A/B"))
          ])
        ]));
  }
}
