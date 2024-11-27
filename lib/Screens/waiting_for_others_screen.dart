import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/main.dart';

class WaitingForOthersScreen extends StatefulWidget {
  const WaitingForOthersScreen({Key? key}) : super(key: key);

  @override
  _WaitingForOthersScreenState createState() => _WaitingForOthersScreenState();
}

class _WaitingForOthersScreenState extends State<WaitingForOthersScreen> {
  late Future<List<User>> _notSubmittedUsers;

  @override
  void initState() {
    super.initState();
    _notSubmittedUsers = _getNotSubmittedUsers();
  }

  Future<List<User>> _getNotSubmittedUsers() async {
    final List<User> allUsers = await DBHandler().getUsers();
    return allUsers.where((user) => user.taskStates.isEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Incomplete Preferences"),
      ),
      body: FutureBuilder<List<User>>(
        future: _notSubmittedUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading submissions."),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("All users have submitted their preferences."),
            );
          } else {
            final List<User> users = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Waiting for the following users to submit their preferences:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(user.name),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
