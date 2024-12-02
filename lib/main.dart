import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/Screens/navigator_screen.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/Subtask.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize DBHandler
  await DBHandler().initDb();

  ///DELETE ALL DATA///
  await DBHandler().getUsers().then((user) async {
    for (User currUser in user) {
      await DBHandler().removeUser(currUser.userId);
    }
  });
  //await DBHandler().getUsers().then((user){print("user number: ${user.length}");});

  await DBHandler().getTasks().then((tasks) async {
    for (Task currTask in tasks) {
      await DBHandler().removeTask(currTask.taskId);
    }
  });
  //await DBHandler().getTasks().then((task){print("task number: ${task.length}");});

  await DBHandler().getAssignedTasks().then((assignedTasks) async {
    for (AssignedTask currAssTask in assignedTasks) {
      await DBHandler().removeAssignedTask(currAssTask.assignedTaskId);
    }
  });

  await DBHandler().getSubmittedUsers().then((indices) async {
    for (int index in indices) {
      await DBHandler().removeSubmittedUser(index);
    }
  });

  Future<Map<String, Uint8List>> loadImages() async {
    List<String> imagePaths = [
      'lib/assets/images/bakeCookies.jpg',
      'lib/assets/images/cleanLivingRoom.jpg',
      'lib/assets/images/deepCleanBathroom.jpg',
      'lib/assets/images/doLaundry.jpg',
      'lib/assets/images/fileTaxes.jpg',
      'lib/assets/images/mealPrep.jpg',
      'lib/assets/images/mowTheLawn.jpg',
      'lib/assets/images/pickUpKids.jpg',
      'lib/assets/images/washBedsheets.jpg',
      'lib/assets/images/weedGarden.jpeg',
    ];

    List<Uint8List> images = await Future.wait(
      imagePaths.map((path) async {
        ByteData byteData = await rootBundle.load(path);
        return byteData.buffer.asUint8List();
      }).toList(),
    );

    return Map.fromIterables(imagePaths, images);
  }

  //await DBHandler().getAssignedTasks().then((assignedTask){print("assignedtask number: ${assignedTask.length}");});
  ///DELETE ALL DATA///

  ///CREATE USERS AND TASKS///
  User theo = await User.create(name: "Theo", flowerColor: Colors.red);
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(constCurrentUserId, theo.userId);
  User anna = await User.create(name: "Anna", flowerColor: Colors.blue);
  User sebi = await User.create(name: "Sebi", flowerColor: Colors.yellow);

  Map<String, Uint8List> images = await loadImages();
  Uint8List bakeCookiesImg = images['lib/assets/images/bakeCookies.jpg']!;
  Uint8List cleanLivingRoomImg =
      images['lib/assets/images/cleanLivingRoom.jpg']!;
  Uint8List deepCleanBathroomImg =
      images['lib/assets/images/deepCleanBathroom.jpg']!;
  Uint8List doLaundryImg = images['lib/assets/images/doLaundry.jpg']!;
  Uint8List fileTaxesImg = images['lib/assets/images/fileTaxes.jpg']!;
  Uint8List mealPrepImg = images['lib/assets/images/mealPrep.jpg']!;
  Uint8List mowTheLawnImg = images['lib/assets/images/mowTheLawn.jpg']!;
  Uint8List pickUpKidsImg = images['lib/assets/images/pickUpKids.jpg']!;
  Uint8List washBedsheetsImg = images['lib/assets/images/washBedsheets.jpg']!;
  Uint8List weedGardenImg = images['lib/assets/images/weedGarden.jpeg']!;

  Task task1 = await Task.create(
    name: "Clean Living Room",
    frequency: Frequency.weekly,
    notes: "Vacuum the carpet and dust the furniture.",
    isPrivate: false,
    difficulty: 3,
    priority: 4,
    category: Category.Cleaning,
    subtasks: [
      await Subtask.create(name: "Vacuum the carpet"),
      await Subtask.create(name: "Dust the furniture"),
      await Subtask.create(name: "Organize the shelves"),
    ],
    img: cleanLivingRoomImg,
  );

  Task task2 = await Task.create(
    name: "Wash Bedsheets",
    frequency: Frequency.weekly,
    notes: "Use gentle cycle and fabric softener.",
    isPrivate: true,
    difficulty: 2,
    priority: 3,
    category: Category.Laundry,
    subtasks: [
      await Subtask.create(name: "Remove bedsheets from all rooms"),
      await Subtask.create(name: "Sort bedsheets by color"),
      await Subtask.create(name: "Wash and dry"),
    ],
    img: washBedsheetsImg,
  );

  Task task3 = await Task.create(
    name: "Meal Prep",
    frequency: Frequency.daily,
    notes: "Chop vegetables and prepare ingredients for dinner.",
    isPrivate: false,
    difficulty: 3,
    priority: 4,
    category: Category.Cooking,
    subtasks: [
      await Subtask.create(name: "Chop vegetables"),
      await Subtask.create(name: "Prepare protein (chicken, tofu, etc.)"),
      await Subtask.create(name: "Marinate ingredients"),
    ],
    img: mealPrepImg,
  );

  Task task4 = await Task.create(
    name: "Weed the Garden",
    frequency: Frequency.weekly,
    notes: "Remove weeds and trim hedges.",
    isPrivate: false,
    difficulty: 4,
    priority: 3,
    category: Category.Outdoor,
    subtasks: [
      await Subtask.create(name: "Remove weeds from flower beds"),
      await Subtask.create(name: "Trim hedges"),
      await Subtask.create(name: "Rake and collect debris"),
    ],
    img: weedGardenImg,
  );

  Task task5 = await Task.create(
    name: "Pick Up Kids from School",
    frequency: Frequency.daily,
    notes: "Arrive 10 minutes early to avoid traffic.",
    isPrivate: false,
    difficulty: 2,
    priority: 5,
    category: Category.Childcare,
    subtasks: [
      await Subtask.create(name: "Pack snacks and water"),
      await Subtask.create(name: "Check traffic route"),
      await Subtask.create(name: "Pick up and return home safely"),
    ],
    img: pickUpKidsImg,
  );

  Task task6 = await Task.create(
    name: "File Taxes",
    frequency: Frequency.yearly,
    notes: "Organize all receipts and documents before filing.",
    isPrivate: true,
    difficulty: 5,
    priority: 5,
    category: Category.Admin,
    subtasks: [
      await Subtask.create(name: "Gather all income statements"),
      await Subtask.create(name: "Organize deductible receipts"),
      await Subtask.create(name: "Submit forms online"),
    ],
    img: fileTaxesImg,
  );

  Task task7 = await Task.create(
    name: "Deep Clean Bathroom",
    frequency: Frequency.monthly,
    notes: "Scrub tiles, clean mirrors, and disinfect surfaces.",
    isPrivate: true,
    difficulty: 4,
    priority: 5,
    category: Category.Cleaning,
    subtasks: [
      await Subtask.create(name: "Scrub tiles and grout"),
      await Subtask.create(name: "Clean mirrors"),
      await Subtask.create(name: "Disinfect sink and toilet"),
    ],
    img: deepCleanBathroomImg,
  );

  Task task8 = await Task.create(
    name: "Do Laundry",
    frequency: Frequency.weekly,
    notes: "Wash whites and colored clothes separately.",
    isPrivate: false,
    difficulty: 2,
    priority: 4,
    category: Category.Laundry,
    subtasks: [
      await Subtask.create(name: "Sort clothes by color"),
      await Subtask.create(name: "Load the washing machine"),
      await Subtask.create(name: "Fold and put away clothes"),
    ],
    img: doLaundryImg,
  );

  Task task9 = await Task.create(
    name: "Bake Cookies",
    frequency: Frequency.monthly,
    notes: "Bake a batch of chocolate chip cookies for the family.",
    isPrivate: false,
    difficulty: 3,
    priority: 3,
    category: Category.Cooking,
    subtasks: [
      await Subtask.create(name: "Gather ingredients"),
      await Subtask.create(name: "Mix ingredients"),
      await Subtask.create(name: "Bake in the oven"),
    ],
    img: bakeCookiesImg,
  );

  Task task10 = await Task.create(
    name: "Mow the Lawn",
    frequency: Frequency.weekly,
    notes: "Ensure even cutting and dispose of grass clippings.",
    isPrivate: false,
    difficulty: 3,
    priority: 4,
    category: Category.Outdoor,
    subtasks: [
      await Subtask.create(name: "Start the lawn mower"),
      await Subtask.create(name: "Mow the lawn evenly"),
      await Subtask.create(name: "Dispose of grass clippings"),
    ],
    img: mowTheLawnImg,
  );

  /* UNCOMPLETED TASKS */
  AssignedTask utask1 = await AssignedTask.create(
      user: theo, task: task1, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask2 = await AssignedTask.create(
      user: theo, task: task2, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask3 = await AssignedTask.create(
      user: theo, task: task3, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask4 = await AssignedTask.create(
      user: theo, task: task4, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask5 = await AssignedTask.create(
      user: theo, task: task1, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask6 = await AssignedTask.create(
      user: theo, task: task1, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask7 = await AssignedTask.create(
      user: theo, task: task3, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask8 = await AssignedTask.create(
      user: theo, task: task1, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask9 = await AssignedTask.create(
      user: theo, task: task2, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask10 = await AssignedTask.create(
      user: theo, task: task3, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask11 = await AssignedTask.create(
      user: theo, task: task4, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask12 = await AssignedTask.create(
      user: theo, task: task1, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask13 = await AssignedTask.create(
      user: theo, task: task2, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask14 = await AssignedTask.create(
      user: theo, task: task3, dueDate: DateTime(2024, 12, 1));
  AssignedTask utask15 = await AssignedTask.create(
      user: theo, task: task1, dueDate: DateTime(2024, 12, 1));

  /* UNCOMPLETED TASKS */

/* COMPLETED TASKS */
  /* AssignedTask atask1 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 1));
  AssignedTask atask2 = await AssignedTask.create(user: theo, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 1));
  AssignedTask atask3 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 2));
  AssignedTask atask4 = await AssignedTask.create(user: theo, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 3));
  AssignedTask atask5 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 3));
  AssignedTask atask6 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 4));
  AssignedTask atask7 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 4));
  AssignedTask atask8 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 4));
  AssignedTask atask9 = await AssignedTask.create(user: theo, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 4));
  AssignedTask atask10 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 5));
  AssignedTask atask11 = await AssignedTask.create(user: theo, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 5));
  AssignedTask atask12 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 6));
  AssignedTask atask13 = await AssignedTask.create(user: theo, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 6));
  AssignedTask atask14 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 6));
  AssignedTask atask15 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 8));
  AssignedTask atask16 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 8));
  AssignedTask atask17 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 8));
  AssignedTask atask18 = await AssignedTask.create(user: theo, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 9));
  AssignedTask atask19 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 9));
  AssignedTask atask20 = await AssignedTask.create(user: theo, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 9));
  AssignedTask atask21 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 10));
  AssignedTask atask22 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 10));
  AssignedTask atask23 = await AssignedTask.create(user: theo, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 11));
  AssignedTask atask24 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 12));
  AssignedTask atask25 = await AssignedTask.create(user: theo, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 12));
  AssignedTask atask26 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 12));
  AssignedTask atask27 = await AssignedTask.create(user: theo, task: task5, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 14));
  AssignedTask atask28 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 14));
  AssignedTask atask29 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 14));
  AssignedTask atask30 = await AssignedTask.create(user: theo, task: task6, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 15));
  AssignedTask atask31 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 15));
  AssignedTask atask32 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 15));
  AssignedTask atask33 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask atask34 = await AssignedTask.create(user: theo, task: task6, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask atask35 = await AssignedTask.create(user: theo, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 17));
  AssignedTask atask36 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 17));
  AssignedTask atask37 = await AssignedTask.create(user: theo, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 18));
  AssignedTask atask38 = await AssignedTask.create(user: theo, task: task6, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 18));
  AssignedTask atask39 = await AssignedTask.create(user: theo, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 19));
  AssignedTask atask40 = await AssignedTask.create(user: theo, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 19));
  AssignedTask atask41 = await AssignedTask.create(user: theo, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 19));
  AssignedTask atask42 = await AssignedTask.create(user: theo, task: task5, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 20));
  AssignedTask btask1 = await AssignedTask.create(user: anna, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 1));
  AssignedTask btask2 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 1));
  AssignedTask btask3 = await AssignedTask.create(user: anna, task: task5, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 1));
  AssignedTask btask4 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 2));
  AssignedTask btask5 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 13));
  AssignedTask btask6 = await AssignedTask.create(user: anna, task: task5, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 3));
  AssignedTask btask7 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 3));
  AssignedTask btask8 = await AssignedTask.create(user: anna, task: task5, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 3));
  AssignedTask btask9 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 4));
  AssignedTask btask10 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 4));
  AssignedTask btask11 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 5));
  AssignedTask btask12 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 5));
  AssignedTask btask13 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 5));
  AssignedTask btask14 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 6));
  AssignedTask btask15 = await AssignedTask.create(user: anna, task: task6, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 8));
  AssignedTask btask16 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 8));
  AssignedTask btask17 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 8));
  AssignedTask btask18 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 9));
  AssignedTask btask19 = await AssignedTask.create(user: anna, task: task6, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 9));
  AssignedTask btask20 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 10));
  AssignedTask btask21 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 10));
  AssignedTask btask22 = await AssignedTask.create(user: anna, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 11));
  AssignedTask btask23 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 11));
  AssignedTask btask24 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 11));
  AssignedTask btask25 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 12));
  AssignedTask btask26 = await AssignedTask.create(user: anna, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 12));
  AssignedTask btask27 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 13));
  AssignedTask btask28 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 13));
  AssignedTask btask29 = await AssignedTask.create(user: anna, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 13));
  AssignedTask btask30 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 15));
  AssignedTask btask31 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask btask32 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask btask33 = await AssignedTask.create(user: anna, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask btask34 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask btask35 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask btask36 = await AssignedTask.create(user: anna, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 17));
  AssignedTask btask37 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 17));
  AssignedTask btask38 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 17));
  AssignedTask btask39 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 19));
  AssignedTask btask40 = await AssignedTask.create(user: anna, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 19));
  AssignedTask btask41 = await AssignedTask.create(user: anna, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 20));
  AssignedTask btask42 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 20));
  AssignedTask btask43 = await AssignedTask.create(user: anna, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 21));
  AssignedTask btask44 = await AssignedTask.create(user: anna, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 21));
  AssignedTask ctask1 = await AssignedTask.create(user: sebi, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 19));
  AssignedTask ctask2 = await AssignedTask.create(user: sebi, task: task3, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 21));
  AssignedTask ctask3 = await AssignedTask.create(user: sebi, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 21));
  AssignedTask ctask4 = await AssignedTask.create(user: sebi, task: task5, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 16));
  AssignedTask ctask5 = await AssignedTask.create(user: sebi, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 18));
  AssignedTask ctask6 = await AssignedTask.create(user: sebi, task: task6, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 23));
  AssignedTask ctask7 = await AssignedTask.create(user: sebi, task: task2, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 23));
  AssignedTask ctask8 = await AssignedTask.create(user: sebi, task: task1, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 23));
  AssignedTask ctask9 = await AssignedTask.create(user: sebi, task: task4, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024, 11, 20));*/

  final tasks = [
    task1,
    task2,
    task3,
    task4,
    task5,
    task6,
    task7,
    task8,
    task9,
    task10,
  ];

  final random = Random();
  final now = DateTime.now();
  final taskHistory = <AssignedTask>[];

  for (int i = 0; i < 70; i++) {
    final task = tasks[random.nextInt(tasks.length)];
    final daysAgo =
        random.nextInt(20) + 1; // Random day within the last 20 days
    final dueDate = now.subtract(Duration(days: daysAgo));
    final finishDate = dueDate.subtract(
        Duration(days: random.nextInt(2) + 1)); // Finish before the due date

    User assignedUser;

    // Unfair Distribution Logic
    if (random.nextInt(10) < 5) {
      // Theo does most tasks (50%)
      assignedUser = theo;
    } else if (random.nextInt(10) < 8) {
      // Anna does mid-range (30%)
      assignedUser = anna;
    } else {
      // Sebastian does very few (10%)
      assignedUser = sebi;
    }

    // Theo handles Cleaning and Laundry disproportionately
    if (assignedUser == theo &&
        (task.category == Category.Cleaning ||
            task.category == Category.Laundry)) {
      assignedUser = theo;
    }

    final assignedTask = await AssignedTask.create(
      user: assignedUser,
      task: task,
      dueDate: dueDate,
      finishDate: finishDate,
    );

    taskHistory.add(assignedTask);
  }

  print("Task history with 50 tasks created successfully!");

  ///CREATE USERS AND TASKS///

  ///CREATE MOODS PER USER///
  /* await Mood.create(date: DateTime(2024, 11, 1), mood: Moods.bad, userId: theo.userId);
  await Mood.create(date: DateTime(2024, 11, 1), mood: Moods.good, userId: anna.userId);
  await Mood.create(date: DateTime(2024, 11, 1), mood: Moods.mid, userId: sebi.userId);*/

  final users = [theo, anna, sebi];
  final moods = [Moods.bad, Moods.mid, Moods.good];

  for (int i = 0; i < 20; i++) {
    final date = now.subtract(Duration(days: i));
    for (final user in users) {
      final mood = moods[random.nextInt(moods.length)];
      await Mood.create(date: date, mood: mood, userId: user.userId);
    }
  }

  // Tasks example
  /*Task myTask = await Task.create( // always use create not constructor! (also for mood, subtasks,...)
    name: "Grocery Shopping 2",
    frequency: Frequency.weekly,
    category: Category.Admin,
    notes: "bla bla bla",
    //imgDst: "lib/assets/image1.png",
    isPrivate: false,
    difficulty: 3,
    priority: 4,
  );

  DBHandler().saveTask(myTask);

  /*User usertmp = await User.create(name: "Theo", flowerColor: Colors.lightGreenAccent);
  DBHandler().saveUser(usertmp);
  User usertmp2 = await User.create(name: "Anna", flowerColor: Colors.orange);
  DBHandler().saveUser(usertmp2);*/

  User usertmp = await User.create(name: "", flowerColor: Colors.red);
  User usertmp2 = await User.create(name: "", flowerColor: Colors.red);
  await DBHandler().getUsers().then((user){
    for(User usertmpp in user){
      if(usertmpp.userName == "Theo"){
        usertmp = usertmpp;
      }else if(usertmpp.userName == "Anna"){
        usertmp2 = usertmpp;
      }
    }
  });

  AssignedTask task = await AssignedTask.create(user: usertmp, task: myTask, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024,11,18));
  DBHandler().saveAssignedTask(task);
  task = await AssignedTask.create(user: usertmp, task: myTask, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024,11,17));
  DBHandler().saveAssignedTask(task);
  task = await AssignedTask.create(user: usertmp, task: myTask, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024,11,17));
  DBHandler().saveAssignedTask(task);
  task = await AssignedTask.create(user: usertmp2, task: myTask, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024,11,12));
  DBHandler().saveAssignedTask(task);
  task = await AssignedTask.create(user: usertmp2, task: myTask, dueDate: DateTime(2024, 12, 1), finishDate: DateTime(2024,11,18));
  DBHandler().saveAssignedTask(task);

  await DBHandler().getAssignedTasks().then((element) {
    print(element);
  });

  await DBHandler().getUsers().then((user) {print(user);});
  
  List<Task> allTasks = await DBHandler().getTasks();*/

  // other data
  /*DBHandler().getUsers();
  DBHandler().getTasks();
  DBHandler().getSubtasks();
  DBHandler().getAssignedTasks();

  // helpful functions
  List<AssignedTask> tasksForUser = await AssignedTask.getTasksForUser(1);
  List<AssignedTask> pendingTasks =
      await AssignedTask.getCompletedTasksForUser(1); // sorting pref?
  List<AssignedTask> incompleteTasks =
      await AssignedTask.getIncompleteTasksForUser(1); // sorting pref?
  List<AssignedTask> completedTasks = await AssignedTask
      .getCompletedTasks(); // sorting pref? - already ordered by finish date :)
  List<Mood> moodHistoryAllUsers =
      await DBHandler().getMoods(); // sorting pref?
  List<Mood> moodHistorySingleUser =
      await DBHandler().getMoodsByUserId(1); // sorting pref?
  Mood? lastMoodOfUser = await DBHandler().getLatestMoodByUserId(
      1); // useful for query of new mood? (null if never assigned a mood)
  */
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  runApp(MyApp());
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
