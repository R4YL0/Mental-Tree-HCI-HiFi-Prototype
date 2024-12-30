// shows users and maybe settings, ... of one group

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/Screens/user_add_edit_screen.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/functions/sharedPreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _userChanged = false;
  String? _selectedUserId; // Allow null to represent no user selected
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _ownInitState();
  }

  void _ownInitState() async {
    prefs = await SharedPreferences.getInstance();
    String? curUserId = prefs?.getString(constCurrentUserId);

    setState(() {
      _selectedUserId = curUserId; // Can be null if no user is selected
    });
  }

  onPressedAdd(BuildContext context) async {
    final bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserAddEditScreen()),
    );
    if (result) {
      setState(() {
        _userChanged = true;
      });
    }
  }

  void _onChangedUser(String changedUserId) async {
    if (prefs != null) {
      await prefs!.setString(constCurrentUserId, changedUserId);

      setState(() {
        _userChanged = true;
        _selectedUserId = changedUserId;
      });
    }
  }

  void _onPressedEdit(User user) async {
    final bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserAddEditScreen(user: user)),
    );
    if (result) {
      setState(() {
        _userChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Awesome User Group"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _userChanged);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FutureBuilder<List<User>?>(
          future: DBHandler().getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return const Center(
                child: Text(
                  'No users found. Add a user to get started.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return Column(
              children: [
                if (_selectedUserId == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text(
                      "No user selected. Please select a user or add a new one.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      User user = users[index];

                      return RadioListTile<String>(
                        value: user.userId,
                        groupValue: _selectedUserId,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        title: Text(user.name),
                        tileColor: user.flowerColor,
                        onChanged: (String? changedUserId) {
                          if (changedUserId != null) {
                            _onChangedUser(changedUserId);
                          }
                        },
                        secondary: IconButton(
                          onPressed: () => _onPressedEdit(user),
                          icon: const Icon(Icons.edit),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 5),
                  ),
                ),
              ],
            );
          },
        ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
