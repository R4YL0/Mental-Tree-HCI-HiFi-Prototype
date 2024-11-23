// shows users and maybe settings, ... of one group

import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/Screens/user_add_screen.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  onPressedAdd(BuildContext context) async {
    final bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const UserAddScreen()));
    if (result) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Awesome User group"),
        ),
        body: FutureBuilder<List<User>?>(
            future: DBHandler().getUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                List<User> users = snapshot.data ?? [];
                int usersLength = users.length;
                return Column(children: [
                  Text('count of users: $usersLength'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: usersLength,
                      itemBuilder: (context, index) {
                        User user = users[index];

                        return ListTile(
                            title: Text(user.name),
                            tileColor: user.flowerColor);
                      },
                    ),
                  )
                ]);
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            onPressedAdd(context);
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked);
  }
}
