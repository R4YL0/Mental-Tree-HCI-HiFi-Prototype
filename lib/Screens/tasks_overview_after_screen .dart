import 'package:flutter/material.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/main.dart';
import 'package:mental_load/widgets/cards_bottom_sheet.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class TaskOverviewDistributedScreen extends StatefulWidget {
  @override
  _TaskOverviewDistributedScreenState createState() => _TaskOverviewDistributedScreenState();
}

class _TaskOverviewDistributedScreenState extends State<TaskOverviewDistributedScreen> {
  String _sortOption = "Name";
  String? _selectedUserId;
  Future<List<User>>? _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = DBHandler().getUsers();
  }

  void _rotateSortOption() {
    setState(() {
      if (_sortOption == "Name") {
        _sortOption = "Difficulty";
      } else if (_sortOption == "Difficulty") {
        _sortOption = "Priority";
      } else if (_sortOption == "Priority") {
        _sortOption = "Category";
      } else {
        _sortOption = "Name"; // Rotate back to "Name"
      }
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: _rotateSortOption,
                ),
                Text("Sort by $_sortOption"),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text("Add Task"),
                onPressed: () {
                  _handleAddTask(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<List<Task>>(
            stream: DBHandler().tasksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading tasks."));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No tasks found."));
              } else {
                final tasks = _applySorting(snapshot.data!);
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 4);
                    final aspectRatio = 140 / 200;
                    final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
                    final cardHeight = cardWidth / aspectRatio;

                    return GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return GestureDetector(
                          onTap: () => _showTaskDetails(context, task),
                          child: Cards(
                            thisTask: Future.value(task),
                            sState: SmallState.info,
                            bState: BigState.info,
                            size: Size.small,
                            heightBig: cardHeight - 30,
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}

List<Task> _applySorting(List<Task> tasks) {
  if (_sortOption == "Name") {
    tasks.sort((a, b) => a.name.compareTo(b.name));
  } else if (_sortOption == "Difficulty") {
    tasks.sort((a, b) => a.difficulty.compareTo(b.difficulty));
  } else if (_sortOption == "Priority") {
    tasks.sort((a, b) => a.priority.compareTo(b.priority));
  } else if (_sortOption == "Category") {
    tasks.sort((a, b) => a.category.name.compareTo(b.category.name));
  }

  return tasks;
}


  void _showTaskDetails(BuildContext context, Task task) {
    showTaskBottomSheet(
      context: context,
      task: task,
      size: Size.big,
      bState: BigState.info,
      onClose: () {
        Navigator.pop(context);
        //setState(() {
          //_fetchTasks();
        //});
      },
      additionalWidgets: ElevatedButton.icon(
        onPressed: () async {
          task.removeFromFirebase();
          //await DBHandler().removeTask(task.taskId);
          Navigator.pop(context);
          //setState(() {
            //_fetchTasks();
          //});
        },
        icon: const Icon(Icons.delete),
        label: const Text(
          "Delete",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error, // Use error color for delete
          foregroundColor: Theme.of(context).colorScheme.onError,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5), width: 2),
        ),
      ),
    );
  }

  void _handleAddTask(BuildContext context) async {
    Task task = await Task.createDefaultTask();

    showTaskBottomSheet(
      context: context,
      task: task,
      size: Size.big,
      bState: BigState.edit,
      onClose: () {
        //DBHandler().removeTask(task.taskId);
        Navigator.pop(context);
        setState(() {
         // _fetchTasks();
        });
      },
      additionalWidgets: StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<List<User>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No users available for assignment."),
                      );
                    } else {
                      final users = snapshot.data!;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Dropdown for user selection
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedUserId,
                                  hint: const Text("Assign to User"),
                                  isExpanded: true,
                                  items: users.map((user) {
                                    return DropdownMenuItem<String>(
                                      value: user.userId,
                                      child: Text(user.name),
                                    );
                                  }).toList(),
                                  onChanged: (userId) {
                                    setModalState(() {
                                      _selectedUserId = userId; 
                                    });
                                    setState(() {
                                      _selectedUserId = userId; 
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Save Button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _selectedUserId == null
                                  ? null // Disable button if no user is selected
                                  : () async {
                                      await DBHandler().saveTask(task);

                                      final user = await DBHandler().getUserById(_selectedUserId!);
                                      if (user == null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Error: User not found.")),
                                        );
                                        return;
                                      }

                                      await AssignedTask.create(
                                        user: user,
                                        task: task,
                                        dueDate: calculateNextDueDate(task),
                                      );
                                      Navigator.pop(context);
                                      //setState(() {
                                        //_fetchTasks();
                                      //});
                                    },
                              icon: const Icon(Icons.save),
                              label: const Text(
                                "Save",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedUserId == null
                                    ? Colors.grey // Change button color when disabled
                                    : Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                side: BorderSide(
                                  color: _selectedUserId == null
                                      ? Colors.grey.withOpacity(0.5) // Lighter border when disabled
                                      : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  DateTime calculateNextDueDate(Task task) {
    final DateTime referenceDate = task.dueDate ?? task.startDate ?? DateTime.now();
    final DateTime currentDate = DateTime.now();

    if (task.frequency == Frequency.oneTime) {
      return task.dueDate ?? referenceDate;
    }

    DateTime nextDate;
    if (referenceDate.isBefore(currentDate)) {
      switch (task.frequency) {
        case Frequency.daily:
          nextDate = currentDate.add(const Duration(days: 1));
          break;
        case Frequency.weekly:
          final int referenceWeekday = referenceDate.weekday;
          final int daysUntilNextWeekday = (referenceWeekday - currentDate.weekday + 7) % 7;
          nextDate = currentDate.add(Duration(days: daysUntilNextWeekday == 0 ? 7 : daysUntilNextWeekday));
          break;
        case Frequency.monthly:
          final int referenceDay = referenceDate.day;
          nextDate = DateTime(currentDate.year, currentDate.month, referenceDay);
          if (nextDate.isBefore(currentDate)) {
            nextDate = DateTime(currentDate.year, currentDate.month + 1, referenceDay);
          }
          break;
        case Frequency.yearly:
          final int referenceMonth = referenceDate.month;
          final int referenceDay = referenceDate.day;
          nextDate = DateTime(currentDate.year, referenceMonth, referenceDay);
          if (nextDate.isBefore(currentDate)) {
            nextDate = DateTime(currentDate.year + 1, referenceMonth, referenceDay);
          }
          break;
        default:
          nextDate = currentDate;
      }
    } else {
      nextDate = referenceDate;
    }

    return nextDate;
  }
}
