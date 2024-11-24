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
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: const SingleChildScrollView(
            child: Column(
              children: [
                TreeHomeScreen(),
                FlowersHomeScreen(),
              ]
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

class TreeHomeScreen extends StatelessWidget {
  const TreeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: SvgPicture.asset('lib/assets/tree_3_branches_with_category_names.svg'),
    );
  }
}

class FlowersHomeScreen extends StatelessWidget {
  const FlowersHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Color(0xFFAAD07C),
          height: 220,
          width: MediaQuery.sizeOf(context).width,
        ),
        const Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              FlowerWidget(mood: Moods.bad),
              FlowerWidget(mood: Moods.good),
              FlowerWidget(mood: Moods.okay),
              FlowerWidget(mood: Moods.bad),
              FlowerWidget(mood: Moods.bad),
              FlowerWidget(mood: Moods.good),
              FlowerWidget(mood: Moods.okay),
            ],
          ),
        ),
      ],
    );
  }
}