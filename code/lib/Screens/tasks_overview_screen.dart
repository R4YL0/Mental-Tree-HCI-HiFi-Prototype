import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Subtask.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/functions/sharedPreferences.dart';
import 'package:mental_load/widgets/cards_bottom_sheet.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class TaskOverviewScreen extends StatefulWidget {
  @override
  _TaskOverviewScreenState createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends State<TaskOverviewScreen> {
  String _sortOption = "Name"; // Default sorting option is now "Name"

  @override
  void initState() {
    super.initState();
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
        _sortOption = "Name";
      }
    });
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
              stream: DBHandler().tasksStream, // Use the task stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading tasks."));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No tasks found."));
                } else {
                  final tasks = _applySorting(snapshot.data!); // Apply sorting to the streamed data
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

  void _showTaskDetails(BuildContext context, Task task) {
    showTaskBottomSheet(
      context: context,
      task: task,
      size: Size.big,
      bState: BigState.info,
      onClose: () {
        Navigator.pop(context);
      },
      additionalWidgets: ElevatedButton.icon(
        onPressed: () async {
          task.removeFromFirebase();
          await DBHandler().removeTask(task.taskId);
          Navigator.pop(context);
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
        //Navigator.pop(context);
      },
      additionalWidgets: ElevatedButton.icon(
        onPressed: () async {
          
          DBHandler().removeSubmittedUser((await getCurUserId()));
          Navigator.pop(context);
        },
        icon: const Icon(Icons.save),
        label: const Text(
          "Save",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 2),
        ),
      ),
    );
  }



  
}
