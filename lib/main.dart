import 'package:flutter/material.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/Screens/navigator_screen.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/Task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DBHandler
  await DBHandler().initDb();

  /////////////////////////////////// Only for presenting :) ////////////////////////////////////////

  // Tasks example
  Task myTask = await Task.create( // always use create not constructor! (also for mood, subtasks,...)
    name: "Grocery Shopping 2",
    frequency: Frequency.weekly,
    category: Category.Admin,
    notes: "bla bla bla",
    isPrivate: false,
    difficulty: 3,
    priority: 4,
  );

  DBHandler().saveTask(myTask);
  

  List<Task> allTasks = await DBHandler().getTasks();

  // other data
  DBHandler().getUsers();
  DBHandler().getTasks();
  DBHandler().getSubtasks();
  DBHandler().getAssignedTasks();

  // helpful functions
  List<AssignedTask> tasksForUser = await AssignedTask.getTasksForUser(1);
  List<AssignedTask> pendingTasks = await AssignedTask.getCompletedTasksForUser(1); // sorting pref?
  List<AssignedTask> incompleteTasks = await AssignedTask.getIncompleteTasksForUser(1); // sorting pref?
  List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks(); // sorting pref? - already ordered by finish date :)
  List<Mood> moodHistoryAllUsers = await DBHandler().getMoods(); // sorting pref?
  List<Mood> moodHistorySingleUser = await DBHandler().getMoodsByUserId(1); // sorting pref?
  Mood? lastMoodOfUser = await DBHandler().getLatestMoodByUserId(1); // useful for query of new mood? (null if never assigned a mood)


 ////////////////////////////////////////////////////////////////////////////////////////////////////

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Load',
      debugShowCheckedModeBanner: false,
      home: NavigatorScreen(),
    );
  }
}
