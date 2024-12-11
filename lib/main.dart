import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mental_load/Screens/navigator_screen.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/Subtask.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //await createTasks();
  //await createAssignedTasks();
  //createMoodHistoryForLast20Days();

  runApp(const MyApp());
}

Future<void> createTasks() async {
  final today = DateTime.now();

  final tasks = [
    Task.create(
      name: "Clean Living Room",
      category: Category.Cleaning,
      frequency: Frequency.weekly,
      notes: "Vacuum the carpet and dust the furniture.",
      isPrivate: false,
      difficulty: 3,
      priority: 4,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Vacuum the carpet"),
        await Subtask.create(taskId: "temp", name: "Dust the furniture"),
        await Subtask.create(taskId: "temp", name: "Organize the shelves"),
      ],
      img: await loadImage('lib/assets/images/cleanLivingRoom.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.wednesday),
    ),
    Task.create(
      name: "Wash Bedsheets",
      category: Category.Laundry,
      frequency: Frequency.weekly,
      notes: "Use gentle cycle and fabric softener.",
      isPrivate: true,
      difficulty: 2,
      priority: 3,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Remove bedsheets from all rooms"),
        await Subtask.create(taskId: "temp", name: "Sort bedsheets by color"),
        await Subtask.create(taskId: "temp", name: "Wash and dry"),
      ],
      img: await loadImage('lib/assets/images/washBedsheets.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.thursday),
    ),
    Task.create(
      name: "Meal Prep",
      category: Category.Cooking,
      frequency: Frequency.daily,
      notes: "Chop vegetables and prepare ingredients for dinner.",
      isPrivate: false,
      difficulty: 3,
      priority: 4,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Chop vegetables"),
        await Subtask.create(taskId: "temp", name: "Prepare protein (chicken, tofu, etc.)"),
        await Subtask.create(taskId: "temp", name: "Marinate ingredients"),
      ],
      img: await loadImage('lib/assets/images/mealPrep.jpg'),
      startDate: calculateNextStartDate(today, Frequency.daily),
    ),
    Task.create(
      name: "Weed the Garden",
      category: Category.Outdoor,
      frequency: Frequency.weekly,
      notes: "Remove weeds and trim hedges.",
      isPrivate: false,
      difficulty: 4,
      priority: 3,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Remove weeds from flower beds"),
        await Subtask.create(taskId: "temp", name: "Trim hedges"),
        await Subtask.create(taskId: "temp", name: "Rake and collect debris"),
      ],
      img: await loadImage('lib/assets/images/weedGarden.jpeg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.tuesday),
    ),
    Task.create(
      name: "Pick Up Kids from School",
      category: Category.Childcare,
      frequency: Frequency.daily,
      notes: "Arrive 10 minutes early to avoid traffic.",
      isPrivate: false,
      difficulty: 2,
      priority: 5,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Pack snacks and water"),
        await Subtask.create(taskId: "temp", name: "Check traffic route"),
        await Subtask.create(taskId: "temp", name: "Pick up and return home safely"),
      ],
      img: await loadImage('lib/assets/images/pickUpKids.jpg'),
      startDate: calculateNextStartDate(today, Frequency.daily),
    ),
    Task.create(
      name: "File Taxes",
      category: Category.Admin,
      frequency: Frequency.yearly,
      notes: "Organize all receipts and documents before filing.",
      isPrivate: true,
      difficulty: 5,
      priority: 5,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Gather all income statements"),
        await Subtask.create(taskId: "temp", name: "Organize deductible receipts"),
        await Subtask.create(taskId: "temp", name: "Submit forms online"),
      ],
      img: await loadImage('lib/assets/images/fileTaxes.jpg'),
      startDate: calculateNextStartDate(today, Frequency.yearly),
    ),
    Task.create(
      name: "Deep Clean Bathroom",
      category: Category.Cleaning,
      frequency: Frequency.monthly,
      notes: "Scrub tiles, clean mirrors, and disinfect surfaces.",
      isPrivate: true,
      difficulty: 4,
      priority: 5,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Scrub tiles and grout"),
        await Subtask.create(taskId: "temp", name: "Clean mirrors"),
        await Subtask.create(taskId: "temp", name: "Disinfect sink and toilet"),
      ],
      img: await loadImage('lib/assets/images/deepCleanBathroom.jpg'),
      startDate: calculateNextStartDate(today, Frequency.monthly),
    ),
    Task.create(
      name: "Do Laundry",
      category: Category.Laundry,
      frequency: Frequency.weekly,
      notes: "Wash whites and colored clothes separately.",
      isPrivate: false,
      difficulty: 2,
      priority: 4,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Sort clothes by color"),
        await Subtask.create(taskId: "temp", name: "Load the washing machine"),
        await Subtask.create(taskId: "temp", name: "Fold and put away clothes"),
      ],
      img: await loadImage('lib/assets/images/doLaundry.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.friday),
    ),
    Task.create(
      name: "Bake Cookies",
      category: Category.Cooking,
      frequency: Frequency.monthly,
      notes: "Bake a batch of chocolate chip cookies for the family.",
      isPrivate: false,
      difficulty: 3,
      priority: 3,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Gather ingredients"),
        await Subtask.create(taskId: "temp", name: "Mix ingredients"),
        await Subtask.create(taskId: "temp", name: "Bake in the oven"),
      ],
      img: await loadImage('lib/assets/images/bakeCookies.jpg'),
      startDate: calculateNextStartDate(today, Frequency.monthly),
    ),
    Task.create(
      name: "Mow the Lawn",
      category: Category.Outdoor,
      frequency: Frequency.weekly,
      notes: "Ensure even cutting and dispose of grass clippings.",
      isPrivate: false,
      difficulty: 3,
      priority: 4,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Start the lawn mower"),
        await Subtask.create(taskId: "temp", name: "Mow the lawn evenly"),
        await Subtask.create(taskId: "temp", name: "Dispose of grass clippings"),
      ],
      img: await loadImage('lib/assets/images/mowTheLawn.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.saturday),
    ),
    Task.create(
      name: "Clean Kitchen",
      category: Category.Cleaning,
      frequency: Frequency.daily,
      notes: "Wipe counters, wash dishes, and take out the trash.",
      isPrivate: false,
      difficulty: 3,
      priority: 5,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Wash the dishes"),
        await Subtask.create(taskId: "temp", name: "Wipe kitchen counters"),
        await Subtask.create(taskId: "temp", name: "Take out the trash"),
      ],
      img: await loadImage('lib/assets/images/cleanKitchen.jpg'),
      startDate: calculateNextStartDate(today, Frequency.daily),
    ),
    Task.create(
      name: "Restock Shared Pantry",
      category: Category.Admin,
      frequency: Frequency.weekly,
      notes: "Check supplies and make a list of needed items.",
      isPrivate: false,
      difficulty: 2,
      priority: 4,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Check pantry inventory"),
        await Subtask.create(taskId: "temp", name: "Make a shopping list"),
        await Subtask.create(taskId: "temp", name: "Buy needed items"),
      ],
      img: await loadImage('lib/assets/images/restockPantry.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.monday),
    ),
    Task.create(
      name: "Clean Windows",
      category: Category.Cleaning,
      frequency: Frequency.monthly,
      notes: "Use glass cleaner and a squeegee for streak-free windows.",
      isPrivate: false,
      difficulty: 3,
      priority: 3,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Remove curtains or blinds"),
        await Subtask.create(taskId: "temp", name: "Spray and clean windows"),
        await Subtask.create(taskId: "temp", name: "Wipe edges and replace curtains"),
      ],
      img: await loadImage('lib/assets/images/cleanWindows.jpg'),
      startDate: calculateNextStartDate(today, Frequency.monthly),
    ),
    Task.create(
      name: "Vacuum Hallway",
      category: Category.Cleaning,
      frequency: Frequency.weekly,
      notes: "Ensure a clean and welcoming shared space.",
      isPrivate: false,
      difficulty: 2,
      priority: 3,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Pick up items off the floor"),
        await Subtask.create(taskId: "temp", name: "Vacuum all floor areas"),
        await Subtask.create(taskId: "temp", name: "Empty vacuum cleaner"),
      ],
      img: await loadImage('lib/assets/images/vacuumHallway.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.wednesday),
    ),
    Task.create(
      name: "Organize Recycling",
      category: Category.Admin,
      frequency: Frequency.weekly,
      notes: "Separate recyclables and take them to the designated bin.",
      isPrivate: false,
      difficulty: 2,
      priority: 4,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Sort paper, plastic, and glass"),
        await Subtask.create(taskId: "temp", name: "Rinse out containers"),
        await Subtask.create(taskId: "temp", name: "Take to recycling bins"),
      ],
      img: await loadImage('lib/assets/images/recycling.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.friday),
    ),
    Task.create(
      name: "Water Indoor Plants",
      category: Category.Outdoor,
      frequency: Frequency.weekly,
      notes: "Water all plants and check for any dry leaves.",
      isPrivate: false,
      difficulty: 1,
      priority: 3,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Check soil moisture"),
        await Subtask.create(taskId: "temp", name: "Water as needed"),
        await Subtask.create(taskId: "temp", name: "Trim dry leaves"),
      ],
      img: await loadImage('lib/assets/images/waterPlants.jpg'),
      startDate: calculateNextStartDate(today, Frequency.weekly, weekday: DateTime.tuesday),
    ),
    Task.create(
      name: "Host Flat Meeting",
      category: Category.Admin,
      frequency: Frequency.monthly,
      notes: "Discuss tasks, bills, and any concerns.",
      isPrivate: false,
      difficulty: 3,
      priority: 5,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Set a meeting time"),
        await Subtask.create(taskId: "temp", name: "Prepare agenda"),
        await Subtask.create(taskId: "temp", name: "Discuss and assign tasks"),
      ],
      img: await loadImage('lib/assets/images/flatMeeting.jpg'),
      startDate: calculateNextStartDate(today, Frequency.monthly),
    ),
    Task.create(
      name: "Deep Clean Fridge",
      category: Category.Cleaning,
      frequency: Frequency.monthly,
      notes: "Remove expired items and clean shelves.",
      isPrivate: false,
      difficulty: 4,
      priority: 4,
      subtasks: [
        await Subtask.create(taskId: "temp", name: "Empty fridge shelves"),
        await Subtask.create(taskId: "temp", name: "Clean shelves with disinfectant"),
        await Subtask.create(taskId: "temp", name: "Restock items"),
      ],
      img: await loadImage('lib/assets/images/deepCleanFridge.jpg'),
      startDate: calculateNextStartDate(today, Frequency.monthly),
    ),
  ];

  await Future.wait(tasks);
}

Future<void> createAssignedTasks() async {
  final dbHandler = DBHandler();
  final users = await dbHandler.getUsers();
  final tasks = await dbHandler.tasksStream.first;

  if (users.isEmpty || tasks.isEmpty) {
    print('No users or tasks available. Cannot create assigned tasks.');
    return;
  }

  final random = Random();
  final today = DateTime.now();

  // Generate an unfair distribution of tasks per user.
  // Example: some users get many tasks, some get very few.
  final userTaskCounts = List.generate(users.length, (index) {
    return random.nextInt(30) + 1; // Random number of tasks (1-30) per user
  });

  // Normalize to ensure we generate 100 tasks.
  final totalTasks = userTaskCounts.reduce((a, b) => a + b);
  userTaskCounts.asMap().forEach((index, count) {
    userTaskCounts[index] = (count / totalTasks * 100).round();
  });

  int createdTasks = 0;
  for (int i = 0; i < users.length; i++) {
    if (createdTasks >= 100) break;

    final user = users[i];
    final taskCountForUser = userTaskCounts[i];

    for (int j = 0; j < taskCountForUser && createdTasks < 100; j++) {
      final task = tasks[random.nextInt(tasks.length)];

      // Assign a random due date in the last 30 days.
      final dueDate = today.subtract(Duration(days: random.nextInt(30)));

      // Create the assigned task.
      await AssignedTask.create(
        user: user,
        task: task,
        dueDate: dueDate,
        finishDate: dueDate,
      );

      createdTasks++;
    }
  }

  print('$createdTasks tasks assigned among ${users.length} users.');
}

Future<Uint8List> loadImage(String path) async {
  try {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  } catch (e) {
    throw Exception("Error loading image: $e");
  }
}

Future<void> createMoodHistoryForLast20Days() async {
  final dbHandler = DBHandler();
  final users = await dbHandler.getUsers();
  final random = Random();
  final moods = Moods.values;

  try {
    for (final userId in users) {
      for (int i = 0; i < 20; i++) {
        final date = DateTime.now().subtract(Duration(days: i));

        // Select a random mood
        final mood = moods[random.nextInt(moods.length)];

        // Create and save the mood using the Mood.create function
        await Mood.create(
          userId: userId.userId,
          date: date,
          mood: mood,
        );

        print('Saved mood for user $userId on ${date.toIso8601String()}');
      }
    }

    print('Mood history created for the last 20 days for all users.');
  } catch (e) {
    print('Error creating mood history: $e');
  }
}

DateTime calculateNextStartDate(DateTime today, Frequency frequency, {int weekday = DateTime.monday}) {
  switch (frequency) {
    case Frequency.daily:
      return today;
    case Frequency.weekly:
      final daysToNextWeekday = (weekday - today.weekday + 7) % 7;
      return today.add(Duration(days: daysToNextWeekday));
    case Frequency.monthly:
      return DateTime(today.year, today.month, 15);
    case Frequency.yearly:
      return DateTime(today.year + 1, 4, 1);
    case Frequency.oneTime:
      return today.add(const Duration(days: 7));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mental Load',
      debugShowCheckedModeBanner: false,
      home: NavigatorScreen(),
    );
  }
}
