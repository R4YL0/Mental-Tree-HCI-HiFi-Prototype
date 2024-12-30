import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/TaskDistributor.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/functions/sharedPreferences.dart';
import 'package:mental_load/widgets/cards_bottom_sheet.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class TaskSubmissionScreen extends StatefulWidget {
  final TabController tabController;
  final VoidCallback onUpdate;

  const TaskSubmissionScreen({
    required this.tabController,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  State<TaskSubmissionScreen> createState() => _TaskSubmissionScreenState();
}

class _TaskSubmissionScreenState extends State<TaskSubmissionScreen> {
  late Future<void> _initFuture;
  late Stream<List<Task>> _likedTasksStream;
  late Stream<List<Task>> _dislikedTasksStream;
  late Stream<List<Task>> _undecidedTasksStream;

  late User currUser;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    currUser = await DBHandler().getCurUser();
    _likedTasksStream = DBHandler().getLikedTasksByUserId(await getCurUserId());
    _dislikedTasksStream = DBHandler().getDislikedTasksByUserId(await getCurUserId());
    _undecidedTasksStream = DBHandler().getUndecidedTasksByUserId(await getCurUserId());

    await _fetchSubmissionStatus();
  }

  void _showTaskOverlay(BuildContext context, Task task) {
    _showTaskBottomSheet(context, task);
  }

  void _showTaskBottomSheet(BuildContext context, Task task) async {
    TaskState? currentState = (await DBHandler().getCurUser()).taskStates[task.taskId];

    showTaskBottomSheet(
      context: context,
      task: task,
      size: Size.big,
      additionalWidgets: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Row(
            children: [
              // "Liked" button
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    setModalState(() {
                      currentState = TaskState.Like;
                    });

                    try {
                      final currentUser = await DBHandler().getCurUser();
                      currentUser.taskStates[task.taskId] = TaskState.Like;
                      await currentUser.updateTaskState(task.taskId, TaskState.Like);
                      setState(() {});
                    } catch (e) {
                      print("Error updating task state to 'Liked': $e");
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: currentState == TaskState.Like ? Colors.green : Colors.grey[300],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Liked",
                    style: TextStyle(
                      color: currentState == TaskState.Like ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // "Disliked" button
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    setModalState(() {
                      currentState = TaskState.Dislike;
                    });

                    try {
                      final currentUser = await DBHandler().getCurUser();
                      currentUser.taskStates[task.taskId] = TaskState.Dislike;
                      await currentUser.updateTaskState(task.taskId, TaskState.Dislike);
                      setState(() {});
                    } catch (e) {
                      print("Error updating task state to 'Disliked': $e");
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: currentState == TaskState.Dislike ? Colors.red : Colors.grey[300],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Disliked",
                    style: TextStyle(
                      color: currentState == TaskState.Dislike ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // "Undecided" button
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    setModalState(() {
                      currentState = null;
                    });

                    try {
                      final currentUser = await DBHandler().getCurUser();
                      currentUser.taskStates.remove(task.taskId);
                      await currentUser.updateTaskState(task.taskId, null);
                      setState(() {});
                    } catch (e) {
                      print("Error updating task state to 'Undecided': $e");
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: currentState == null ? Colors.blue : Colors.grey[300],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    "Undecided",
                    style: TextStyle(
                      color: currentState == null ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _fetchSubmissionStatus() async {
    List<String> submittedUsers = await DBHandler().getSubmittedUsers();
    String curUserId = await getCurUserId();
    setState(() {
      _submitted = submittedUsers.contains(curUserId);
    });
  }

  Future<void> _submitSelection() async {
    final dbHandler = DBHandler();
    final currentUserId = await getCurUserId();

    await DBHandler().addSubmittedUser(currentUserId);

    setState(() {
      _submitted = true;
    });

    final allUsers = await dbHandler.getUsers();
    final submittedUsers = await dbHandler.getSubmittedUsers();

    if (allUsers.length == submittedUsers.length) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 8,
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Preferences Submitted",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(thickness: 1.5, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      "Great news! All users have submitted their preferences. The app has now distributed tasks based on everyone's choices.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Show My Tasks",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      final taskDistributor = TaskDistributor();

      await taskDistributor.createAssignedTaskDistribution();
      print("TASKS DISTRIBUTED");

      widget.onUpdate();
    } else {
      widget.tabController.animateTo(3);
    }
  }

  void _editSubmission() async {
    await DBHandler().removeSubmittedUser(await getCurUserId());

    setState(() {
      _submitted = false;
    });
  }

  Widget showAlreadySubmitted() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "You have submitted your preferences!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _editSubmission,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: const Text(
              "Edit Preferences",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection({
    required String title,
    required Stream<List<Task>> tasksStream,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<Task>>(
          stream: tasksStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text("Error loading tasks");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No tasks found.");
            } else {
              final tasks = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tasks
                      .map(
                        (task) => GestureDetector(
                          onTap: () => _showTaskOverlay(context, task),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: SizedBox(
                              width: 140 * 1.25,
                              height: 200 * 1.25,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double cardHeightBig = constraints.maxHeight;
                                  return Cards(
                                    thisTask: Future.value(task),
                                    sState: SmallState.info,
                                    bState: BigState.info,
                                    size: Size.small,
                                    heightBig: cardHeightBig - 30,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}")); // Handle errors
        } else {
          // Show UI after initialization
          return _submitted
              ? showAlreadySubmitted()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTaskSection(
                              title: "Liked Tasks",
                              tasksStream: _likedTasksStream,
                              icon: Icons.favorite,
                              iconColor: Colors.green,
                            ),
                            _buildTaskSection(
                              title: "Disliked Tasks",
                              tasksStream: _dislikedTasksStream,
                              icon: Icons.thumb_down,
                              iconColor: Colors.red,
                            ),
                            _buildTaskSection(
                              title: "Undecided Tasks",
                              tasksStream: _undecidedTasksStream,
                              icon: Icons.help_outline,
                              iconColor: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _submitSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Submit Preferences",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        }
      },
    );
  }
}
