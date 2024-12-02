import 'package:flutter/material.dart';
import 'package:mental_load/Screens/assigned_tasks_screen.dart';
import 'package:mental_load/Screens/swipable_card_screen.dart';
import 'package:mental_load/Screens/tasks_overview_screen.dart';
import 'package:mental_load/Screens/verify_submission_screen.dart';
import 'package:mental_load/Screens/waiting_for_others_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({Key? key}) : super(key: key);

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _allUsersSubmitted = false; // Track submission status
  String _currentTitle = "Tasks Overview";

  final List<String> _titles = [
    "Tasks Overview",
    "Swipe Preferences",
    "Preferences Overview",
    "Group Overview",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAssignedTasksIfSubmitted();
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTitle = _titles[_tabController.index];
        });
      }
    });
  }

  Future<void> showAssignedTasksIfSubmitted() async {
    final allUsers = await DBHandler().getUsers();
    final submittedUsers = await DBHandler().getSubmittedUsers();

    setState(() {
      _allUsersSubmitted = allUsers.length == submittedUsers.length;
    });
  }

  void updateScreen() {
    setState(() {
      showAssignedTasksIfSubmitted();
    });
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
        child: _allUsersSubmitted
            ? AssignedTasksOverview()
            : Column(
                children: [
                  if (_tabController.index != 4)
                    Column(
                      children: [
                        Text(
                          _currentTitle,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(icon: Icon(Icons.task), text: "Overview"),
                            Tab(icon: Icon(Icons.swipe), text: "Swipe"),
                            Tab(icon: Icon(Icons.assignment), text: "Preferences"),
                            Tab(icon: Icon(Icons.people), text: "Group"),
                          ],
                          indicatorColor: Colors.blue,
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TaskOverviewScreen(),
                        SwipableCardScreen(tabController: _tabController),
                        TaskSubmissionScreen(
                          tabController: _tabController,
                          onUpdate: updateScreen, 
                        ),
                        WaitingForOthersScreen(
                           tabController: _tabController,
                           onUpdate: updateScreen, 
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
