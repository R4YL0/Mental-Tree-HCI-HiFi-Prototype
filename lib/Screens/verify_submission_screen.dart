import 'package:flutter/material.dart';
import 'package:mental_load/Screens/assigned_tasks_screen.dart';
import 'package:mental_load/Screens/waiting_for_others_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/main.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class TaskSubmissionScreen extends StatefulWidget {
  const TaskSubmissionScreen({Key? key}) : super(key: key);

  @override
  _TaskSubmissionScreenState createState() => _TaskSubmissionScreenState();
}

class _TaskSubmissionScreenState extends State<TaskSubmissionScreen> {
  late Future<List<Task>> _favoritesFuture;
  late Future<List<Task>> _othersFuture;
  final DBHandler _dbHandler = DBHandler();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    _favoritesFuture = _dbHandler.getLikedTasksByUserId(currUser.userId);
    _othersFuture = _dbHandler.getUndecidedTasksByUserID(currUser.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Task Selection"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Favorites Section
              Text(
                "Your Favorites",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<Task>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error loading tasks");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No favorite tasks found.");
                  } else {
                    final favoriteTasks = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: favoriteTasks
                            .map((task) => Cards(
                                  thisTask: Future.value(task),
                                  sState: SmallState.info,
                                  bState: BigState.info,
                                  size: Size.small,
                                ))
                            .toList(),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),

              // Others Section
              Text(
                "Others",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<Task>>(
                future: _othersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error loading tasks");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No other tasks found.");
                  } else {
                    final otherTasks = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: otherTasks
                            .map((task) => Cards(
                                  thisTask: Future.value(task),
                                  sState: SmallState.info,
                                  bState: BigState.info,
                                  size: Size.small,
                                ))
                            .toList(),
                      ),
                    );
                  }
                },
              ),

              SizedBox(height: 30),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    /*WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WaitingForOthersScreen(),
                        ),
                      );
                    });*/
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasksOverviewScreen(),
                        ),
                      );
                    });
                    
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text("Submit Selection"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
