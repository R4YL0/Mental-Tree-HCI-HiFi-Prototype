import 'package:flutter/material.dart';
import 'package:mental_load/Screens/assigned_tasks_screen.dart';
import 'package:mental_load/Screens/waiting_for_others_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/main.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class TaskSubmissionScreen extends StatefulWidget {
  final TabController tabController;

  const TaskSubmissionScreen({Key? key, required this.tabController}) : super(key: key);

  @override
  _TaskSubmissionScreenState createState() => _TaskSubmissionScreenState();
}

class _TaskSubmissionScreenState extends State<TaskSubmissionScreen> {
  late Future<List<Task>> _likedTasksFuture;
  late Future<List<Task>> _dislikedTasksFuture;
  late Future<List<Task>> _undecidedTasksFuture;

  final DBHandler _dbHandler = DBHandler();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _fetchSubmissionStatus();
    _fetchTasks();
  }

  void _showTaskOverlay(BuildContext context, Task task) {
    TaskState? currentState = currUser.taskStates[task.taskId];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Cards(
                      thisTask: Future.value(task),
                      sState: SmallState.info,
                      bState: BigState.info,
                      size: Size.big,
                    ),
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      // "Liked" button
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              currUser.taskStates[task.taskId] = TaskState.Like;
                              currentState = TaskState.Like;
                            });

                            currUser.updateTaskState(task.taskId, TaskState.Like).then((_) {
                              setState(() {});
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: currentState == TaskState.Like ? Colors.green : Colors.grey[300],
                            shape: RoundedRectangleBorder(
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
                          onPressed: () {
                            setModalState(() {
                              currUser.taskStates[task.taskId] = TaskState.Dislike;
                              currentState = TaskState.Dislike;
                            });

                            currUser.updateTaskState(task.taskId, TaskState.Dislike).then((_) {
                              setState(() {});
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: currentState == TaskState.Dislike ? Colors.red : Colors.grey[300],
                            shape: RoundedRectangleBorder(
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
                          onPressed: () {
                            setModalState(() {
                              currUser.taskStates.remove(task.taskId);
                              currentState = null;
                            });

                            currUser.updateTaskState(task.taskId, null).then((_) {
                              _fetchTasks().then((_) => setState(() {}));
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: currentState == null ? Colors.blue : Colors.grey[300],
                            shape: RoundedRectangleBorder(
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
                  ),
                  SizedBox(height: 20),
                  // Save Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (currentState == null) {
                        await currUser.updateTaskState(task.taskId, null);
                      } else {
                        await currUser.updateTaskState(task.taskId, currentState);
                      }

                      await _fetchTasks();
                      setState(() {});

                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text(
                      "Save",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF008080),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      shadowColor: Colors.black45,
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _fetchSubmissionStatus() async {
    List<int> submittedUsers = await _dbHandler.getSubmittedUsers();
    setState(() {
      _submitted = submittedUsers.contains(currUser.userId);
    });
  }

  Future<void> _fetchTasks() async {
    _likedTasksFuture = _dbHandler.getLikedTasksByUserId(currUser.userId);
    _dislikedTasksFuture = _dbHandler.getDislikedTasksByUserId(currUser.userId);
    _undecidedTasksFuture = _dbHandler.getUndecidedTasksByUserID(currUser.userId);
  }

  Future<void> _submitSelection() async {
    await _dbHandler.saveSubmittedUser(currUser.userId);

    setState(() {
      _submitted = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selection Submitted"),
        content: const Text("Your task preferences have been submitted successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.tabController.animateTo(2);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _editSubmission() {
    setState(() {
      _submitted = false;
    });
  }

  Widget _confirmationScreen() {
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
    required Future<List<Task>> tasksFuture,
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
        FutureBuilder<List<Task>>(
          future: tasksFuture,
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
                            child: Cards(
                              thisTask: Future.value(task),
                              sState: SmallState.info,
                              bState: BigState.info,
                              size: Size.small,
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
    return _submitted
        ? _confirmationScreen()
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
                        tasksFuture: _likedTasksFuture,
                        icon: Icons.favorite,
                        iconColor: Colors.green,
                      ),
                      _buildTaskSection(
                        title: "Disliked Tasks",
                        tasksFuture: _dislikedTasksFuture,
                        icon: Icons.thumb_down,
                        iconColor: Colors.red,
                      ),
                      _buildTaskSection(
                        title: "Undecided Tasks",
                        tasksFuture: _undecidedTasksFuture,
                        icon: Icons.help_outline,
                        iconColor: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _submitSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    "Submit Selection",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
  }
}
