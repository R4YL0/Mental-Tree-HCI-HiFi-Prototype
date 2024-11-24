// shows users and maybe settings, ... of one group

import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        CircularProgressIndicator,
        Column,
        ConnectionState,
        Expanded,
        FloatingActionButton,
        FloatingActionButtonLocation,
        FutureBuilder,
        Icon,
        Icons,
        ListTile,
        ListView,
        Scaffold,
        StatelessWidget,
        Text,
        Widget,
        showDialog;
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/widgets/user_add_widget.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

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
          child: const Icon(Icons.add),
          onPressed: () => {
            showDialog(
                context: context,
                builder: (context) {
                  return const UserAddWidget();
                })
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked);
  }
}
