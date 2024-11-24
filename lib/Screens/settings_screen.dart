import 'package:flutter/material.dart';
import 'package:mental_load/Screens/group_screen.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SettingsList(sections: [
          SettingsSection(
            title: const Text('User'),
            tiles: <SettingsTile>[
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
        ]));
  }
}
