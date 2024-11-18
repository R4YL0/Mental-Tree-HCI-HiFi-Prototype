import 'package:flutter/material.dart';
import 'package:mental_load/Screens/settings_screen.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/widgets/flower_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            color: AppColors.primary,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(children: [
                Text(
                  "HOME - Todo",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                FlowerWidget(mood: Moods.good)
              ]),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.settings),
          onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()))
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop);
  }
}
