// shows users and maybe settings, ... of one group

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/Screens/user_add_edit_screen.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _userChanged = false;
  late int _selectedUser;
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _ownInitState();
  }

  void _ownInitState() async {
    prefs = await SharedPreferences.getInstance();
    int? curUserId = prefs.getInt(constCurrentUserId);
    if (curUserId != null) {
      setState(() {
        _selectedUser = curUserId;
      });
    }
  }

  onPressedAdd(BuildContext context) async {
    final bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const UserAddEditScreen()));
    if (result) {
      setState(() {
        _userChanged = true;
      });
    }
  }

  _onChangedUser(int changedUserId) async {
    /*
    final bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => UserAddEditScreen(user: changedUserId)));*/
    await prefs.setInt(constCurrentUserId, changedUserId);
    //if (result) {
    setState(() {
      _userChanged = true;
      _selectedUser = changedUserId;
    });
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Awesome User group"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context, _userChanged);
              }),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder<List<User>?>(
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
                    Expanded(
                      child: ListView.separated(
                          itemCount: usersLength,
                          itemBuilder: (context, index) {
                            User user = users[index];

                            return RadioListTile<int>(
                              value: user.userId,
                              groupValue: _selectedUser,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              title: Text(user.name),
                              tileColor: user.flowerColor,
                              onChanged: (int? changedUserId) {
                                if (changedUserId != null) {
                                  _onChangedUser(changedUserId);
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(
                                height: 5,
                              )),
                    )
                  ]);
                }
              }),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            onPressed: () {
              onPressedAdd(context);
            },
            child: const Icon(Icons.add),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked);
  }
}
