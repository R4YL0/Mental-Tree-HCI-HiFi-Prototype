import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Task.dart';
import 'Subtask.dart';
import 'User.dart';
import 'AssignedTask.dart';

class TaskDistributor {
  Future<Map<User, List<Task>>> distributeTasksFairly(
    List<User> users, List<Task> tasks) async {
  Map<User, List<Task>> userBuckets = {for (var user in users) user: []};
  Map<User, int> userDifficulty = {for (var user in users) user: 0};
  Map<User, int> taskCount = {for (var user in users) user: 0};

  tasks.sort((a, b) => b.difficulty.compareTo(a.difficulty));

  for (var task in tasks) {
    User? bestUser;
    int minDifficulty = 9223372036854775807;
    int minTasks = 9223372036854775807;

    // Prioritize users who 'Like' the task, balance task count and difficulty
    for (var user in users) {
      var state = user.getTaskState(task.taskId);

      if (state == TaskState.Dislike) continue;

      int userCurrentDifficulty = userDifficulty[user] ?? 0;
      int userCurrentTasks = taskCount[user] ?? 0;

      if (state == TaskState.Like) {
        if (bestUser == null ||
            userCurrentTasks < minTasks ||
            (userCurrentTasks == minTasks && userCurrentDifficulty < minDifficulty)) {
          bestUser = user;
          minDifficulty = userCurrentDifficulty;
          minTasks = userCurrentTasks;
        }
      }
    }

    // Handle 'Undecided' if no users 'Like' the task
    if (bestUser == null) {
      for (var user in users) {
        var state = user.getTaskState(task.taskId);

        if (state == TaskState.Undecided) {
          int userCurrentDifficulty = userDifficulty[user] ?? 0;
          int userCurrentTasks = taskCount[user] ?? 0;

          if (bestUser == null ||
              userCurrentTasks < minTasks ||
              (userCurrentTasks == minTasks && userCurrentDifficulty < minDifficulty)) {
            bestUser = user;
            minDifficulty = userCurrentDifficulty;
            minTasks = userCurrentTasks;
          }
        }
      }
    }

    // Assign task to the best user
    if (bestUser != null) {
      userBuckets[bestUser]!.add(task);
      userDifficulty[bestUser] = userDifficulty[bestUser]! + task.difficulty;
      taskCount[bestUser] = taskCount[bestUser]! + 1;
    }
  }

  _balanceTasks(userBuckets, userDifficulty);

  return userBuckets;
}


  void _balanceTasks(
      Map<User, List<Task>> userBuckets, Map<User, int> userDifficulty) {
    List<User> sortedUsers =
        userDifficulty.keys.toList(growable: false)..sort((a, b) {
          return userDifficulty[a]!.compareTo(userDifficulty[b]!);
        });

    while (true) {
      User lowestUser = sortedUsers.first;
      User highestUser = sortedUsers.last;

      if ((userDifficulty[highestUser]! - userDifficulty[lowestUser]!) <= 1) {
        break;
      }

      for (var task in userBuckets[highestUser]!) {
        if (lowestUser.getTaskState(task.taskId) != TaskState.Dislike) {
          userBuckets[highestUser]!.remove(task);
          userBuckets[lowestUser]!.add(task);

          userDifficulty[highestUser] =
              userDifficulty[highestUser]! - task.difficulty;
          userDifficulty[lowestUser] =
              userDifficulty[lowestUser]! + task.difficulty;

          break;
        }
      }

      sortedUsers.sort((a, b) =>
          userDifficulty[a]!.compareTo(userDifficulty[b]!));
    }
  }

  Future<void> createAssignedTaskDistribution() async {

List<User> users = await DBHandler().getUsers();
List<Task> tasks = await DBHandler().getTasks();
    Map<User, List<Task>> fairDistribution =
        await distributeTasksFairly(users, tasks);

    for (var entry in fairDistribution.entries) {
      User user = entry.key;
      List<Task> assignedTasks = entry.value;

      for (var task in assignedTasks) {
        DateTime dueDate;

        if (task.dueDate != null) {
          dueDate = task.dueDate!;
        } else if (task.startDate != null && task.frequency != null) {
          DateTime nextDueDate = task.startDate!;
          while (nextDueDate.isBefore(DateTime.now())) {
            nextDueDate = _calculateNextDueDate(nextDueDate, task.frequency!);
          }
          dueDate = nextDueDate;
        } else {
          dueDate = DateTime.now().add(Duration(days: 7));
        }

        await AssignedTask.create(user: user, task: task, dueDate: dueDate);
      }
    }
  }

  DateTime _calculateNextDueDate(DateTime startDate, Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return startDate.add(Duration(days: 1));
      case Frequency.weekly:
        return startDate.add(Duration(days: 7));
      case Frequency.monthly:
        return DateTime(
          startDate.year,
          startDate.month + 1,
          startDate.day,
        );
      case Frequency.yearly:
        return DateTime(
          startDate.year + 1,
          startDate.month,
          startDate.day,
        );
      case Frequency.oneTime:
        return startDate;
    }
  }
}
