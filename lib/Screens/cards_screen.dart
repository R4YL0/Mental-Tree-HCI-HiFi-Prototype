import 'package:flutter/material.dart';
import 'package:mental_load/Screens/assigned_tasks_screen.dart';
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

  // Titles for each tab
  final List<String> _titles = [
    "Swipe Preferences",
    "Preferences Overview",
    "Group Overview",
    "", // No title for Tasks Overview
  ];

  String _currentTitle = "Swipe Preferences"; // Default title

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
          // Only show the top bar for tabs other than "Tasks Overview"
          if (_tabController.index != 3)
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
                    Tab(icon: Icon(Icons.swipe), text: "Swipe"),
                    Tab(icon: Icon(Icons.assignment), text: "Preferences"),
                    Tab(icon: Icon(Icons.people), text: "Group"),
                    Tab(icon: Icon(Icons.task), text: "Tasks"),
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
                SwipableCardScreen(tabController: _tabController),
                TaskSubmissionScreen(tabController: _tabController),
                const WaitingForOthersScreen(),
                const TasksOverviewScreen(), // Tasks Overview with no top bar
              ],
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: Container(
      height: 70, // Slightly larger for a modern look
      width: 70,
      decoration: BoxDecoration(
        color: Colors.blue, // Solid color for the button
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4), // Subtle shadow for depth
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context); // Show a dialog or navigate to add task screen
        },
        backgroundColor: Colors.blue, // Matches the container color
        elevation: 0, // No additional shadow
        child: const Icon(
          Icons.add,
          size: 36, // Slightly larger icon for visibility
          color: Colors.white, // White icon for contrast
        ),
        tooltip: 'Add Task', // Accessibility text
      ),
    ),
  );
}


/// Function to show an "Add Task" dialog
void _showAddTaskDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add a New Task"),
        content: const Text("Feature coming soon!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}


  
}
