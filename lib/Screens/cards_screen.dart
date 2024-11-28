import 'package:flutter/material.dart';
import 'package:mental_load/Screens/swipable_card_screen.dart';
import 'package:mental_load/Screens/verify_submission_screen.dart';
import 'package:mental_load/Screens/waiting_for_others_screen.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _titles = [
    "Task Preferences",
    "Submission Overview",
    "Waiting for Others",
  ];

  String _currentTitle = "Task Preferences";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _titles.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTitle = _titles[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          right: 10,
          left: 10,
        ),
        child: Column(
          children: [
            Text(
              _currentTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.swipe), text: "Cards"),
                Tab(icon: Icon(Icons.assignment), text: "Submission"),
                Tab(icon: Icon(Icons.people), text: "Waiting"),
              ],
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SwipableCardScreen(tabController: _tabController),
                  TaskSubmissionScreen(tabController: _tabController),
                  const WaitingForOthersScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
