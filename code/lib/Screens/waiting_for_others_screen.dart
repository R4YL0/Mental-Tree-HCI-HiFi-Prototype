import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/TaskDistributor.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/classes/Task.dart';

class WaitingForOthersScreen extends StatefulWidget {
  final TabController tabController; // Define this property
  final VoidCallback onUpdate;       // Define this property

  const WaitingForOthersScreen({
    required this.tabController,
    required this.onUpdate,
    Key? key,
  }) : super(key: key);

  @override
  _WaitingForOthersScreenState createState() => _WaitingForOthersScreenState();
}


class _WaitingForOthersScreenState extends State<WaitingForOthersScreen> {
  late Future<List<User>> _submittedUsersFuture;
  late Future<List<User>> _notSubmittedUsersFuture;

  @override
  void initState() {
    super.initState();
    _submittedUsersFuture = _getSubmittedUsers();
    _notSubmittedUsersFuture = _getNotSubmittedUsers();
  }

  Future<List<User>> _getSubmittedUsers() async {
    final List<String> submittedUsers = await DBHandler().getSubmittedUsers();
    final List<User> allUsers = await DBHandler().getUsers();
    return allUsers.where((user) => submittedUsers.contains(user.userId)).toList();
  }

  Future<List<User>> _getNotSubmittedUsers() async {
    final List<String> submittedUsers = await DBHandler().getSubmittedUsers();
    final List<User> allUsers = await DBHandler().getUsers();
    return allUsers.where((user) => !submittedUsers.contains(user.userId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([_submittedUsersFuture, _notSubmittedUsersFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading submissions."),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("No data available."),
            );
          } else {
            final List<User> submittedUsers = snapshot.data![0];
            final List<User> notSubmittedUsers = snapshot.data![1];

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Hint message at the top
                _buildHintMessage(),

                const SizedBox(height: 20),

                // Section for users who submitted preferences
                _buildSectionHeader(
                  title: "Submitted Users",
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                if (submittedUsers.isEmpty) _buildEmptyState("No users have submitted preferences yet."),
                ...submittedUsers.map((user) => _buildSubmittedUserCard(user)),

                const SizedBox(height: 20),

                // Section for users who have not submitted preferences
                _buildSectionHeader(
                  title: "Pending Users",
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                ),
                if (notSubmittedUsers.isEmpty) _buildEmptyState("All users have submitted their preferences."),
                ...notSubmittedUsers.map((user) => _buildNotSubmittedUserCard(user)),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _skipSubmission(); // Call the new function here
        },
        child: const Text(
          "Skip",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        tooltip: 'Skip',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _skipSubmission() async {
    final dbHandler = DBHandler();

    // Mark all users as submitted
    final allUsers = await dbHandler.getUsers();
    for (final user in allUsers) {
      await DBHandler().addSubmittedUser(user.userId);
    }

    setState(() {
      //_submitted = true;
    });

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

  Widget _buildHintMessage() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Tasks will be distributed as soon as all members have submitted their preferences.",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ExpansionTile(
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        children: [
          FutureBuilder<List<Widget>>(
            future: _getUserPreferenceWidgets(user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("Error loading preferences."),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: snapshot.data!,
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No preferences found."),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotSubmittedUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Future<List<Widget>> _getUserPreferenceWidgets(User user) async {
  List<Widget> widgets = [];
  for (String taskId in user.taskStates.keys) {
    final Task? task = await DBHandler().getTaskById(taskId);

    // Throw an error if the task is null
    if (task == null) {
      throw Exception('Task with ID $taskId not found.');
    }

    final String taskName = task.name;
    final String taskPreference =
        user.taskStates[taskId] == TaskState.Like ? "Like" : "Dislike";

    final Icon icon = user.taskStates[taskId] == TaskState.Like
        ? const Icon(Icons.thumb_up, color: Colors.green)
        : const Icon(Icons.thumb_down, color: Colors.red);

    widgets.add(
      ListTile(
        leading: icon,
        title: Text(taskName),
        subtitle: Text(taskPreference),
      ),
    );
  }
  return widgets;
}

}
