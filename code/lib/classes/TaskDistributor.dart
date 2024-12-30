import 'package:mental_load/classes/DBHandler.dart';
import 'Task.dart';
import 'User.dart';
import 'AssignedTask.dart';

class TaskDistributor {
  Future<Map<User, List<Task>>> distributeTasksFairly(List<User> users, List<Task> tasks) async {
    // Initialize user task maps
    Map<User, List<Task>> userBuckets = {for (var user in users) user: []};
    Map<User, int> userDifficulty = {for (var user in users) user: 0};
    Map<User, int> taskCount = {for (var user in users) user: 0};

    // Sort tasks by difficulty descending
    tasks.sort((a, b) => b.difficulty.compareTo(a.difficulty));

    // Assign tasks based on user preferences
    for (var task in tasks) {
      User? bestUser;
      int minDifficulty = double.maxFinite.toInt();
      int minTasks = double.maxFinite.toInt();

      for (var user in users) {
        var state = user.getTaskState(task.taskId);

        // Skip if user dislikes the task
        if (state == TaskState.Dislike) continue;

        // Determine current user's task stats
        int userCurrentDifficulty = userDifficulty[user] ?? 0;
        int userCurrentTasks = taskCount[user] ?? 0;

        // Prioritize users based on task state, task count, and difficulty
        if (bestUser == null ||
            userCurrentTasks < minTasks ||
            (userCurrentTasks == minTasks && userCurrentDifficulty < minDifficulty)) {
          bestUser = user;
          minDifficulty = userCurrentDifficulty;
          minTasks = userCurrentTasks;
        }
      }

      // Assign task to the best user if found
      if (bestUser != null) {
        userBuckets[bestUser]!.add(task);
        userDifficulty[bestUser] = userDifficulty[bestUser]! + task.difficulty;
        taskCount[bestUser] = taskCount[bestUser]! + 1;
      }
    }

    // Balance tasks after initial assignment
    _balanceTasks(userBuckets, userDifficulty);

    return userBuckets;
  }

  void _balanceTasks(Map<User, List<Task>> userBuckets, Map<User, int> userDifficulty) {
    List<User> sortedUsers = userDifficulty.keys.toList()
      ..sort((a, b) => userDifficulty[a]!.compareTo(userDifficulty[b]!));

    while (true) {
      User lowestUser = sortedUsers.first;
      User highestUser = sortedUsers.last;

      // Exit if difficulty difference is minimal
      if ((userDifficulty[highestUser]! - userDifficulty[lowestUser]!) <= 1) break;

      // Attempt to move a task from highestUser to lowestUser
      bool moved = false;
      for (var task in userBuckets[highestUser]!) {
        if (lowestUser.getTaskState(task.taskId) != TaskState.Dislike) {
          userBuckets[highestUser]!.remove(task);
          userBuckets[lowestUser]!.add(task);

          userDifficulty[highestUser] = userDifficulty[highestUser]! - task.difficulty;
          userDifficulty[lowestUser] = userDifficulty[lowestUser]! + task.difficulty;

          moved = true;
          break;
        }
      }

      // If no task could be moved, break the loop
      if (!moved) break;

      // Re-sort users by difficulty after rebalancing
      sortedUsers.sort((a, b) => userDifficulty[a]!.compareTo(userDifficulty[b]!));
    }
  }

  Future<void> createAssignedTaskDistribution() async {
    print("Hello World");
    List<User> users = await DBHandler().getUsers();
    List<Task> tasks = await DBHandler().tasksStream.first;
    Map<User, List<Task>> fairDistribution = await distributeTasksFairly(users, tasks);

    for (var entry in fairDistribution.entries) {
      User user = entry.key;
      List<Task> assignedTasks = entry.value;

      for (var task in assignedTasks) {
        DateTime dueDate = _determineDueDate(task);

        // Create the assigned task
        await AssignedTask.create(user: user, task: task, dueDate: dueDate);
      }
    }
  }

  DateTime _determineDueDate(Task task) {
    if (task.dueDate != null) {
      return task.dueDate!;
    } else if (task.startDate != null && task.frequency != null) {
      DateTime nextDueDate = task.startDate!;
      while (nextDueDate.isBefore(DateTime.now())) {
        nextDueDate = _calculateNextDueDate(nextDueDate, task.frequency!);
      }
      return nextDueDate;
    } else {
      return DateTime.now().add(const Duration(days: 7));
    }
  }

  DateTime _calculateNextDueDate(DateTime startDate, Frequency frequency) {
    switch (frequency) {
      case Frequency.daily:
        return startDate.add(const Duration(days: 1));
      case Frequency.weekly:
        return startDate.add(const Duration(days: 7));
      case Frequency.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case Frequency.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
      case Frequency.oneTime:
        return startDate;
    }
  }
}

