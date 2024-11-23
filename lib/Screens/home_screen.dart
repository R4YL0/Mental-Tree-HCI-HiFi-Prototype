import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mental_load/Screens/settings_screen.dart';
import 'package:mental_load/widgets/flower_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFFAFF),
        body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, right: 10, left: 10),
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: [
                SvgPicture.asset('lib/assets/tree_3_branches_with_category_names.svg',),
                const Wrap(
                  children: [
                    FlowerWidget(mood: Moods.bad),
                    FlowerWidget(mood: Moods.good),
                    FlowerWidget(mood: Moods.okay),
                    FlowerWidget(mood: Moods.bad),
                  ],
                ),
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
