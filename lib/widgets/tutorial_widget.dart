import 'package:flutter/material.dart';
import 'package:mental_load/Screens/settings_screen.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/widgets/flower_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialWidget extends StatefulWidget {
  final User user;

  const TutorialWidget({super.key, required this.user});

  @override
  State<TutorialWidget> createState() => _TutorialWidgetState();
}

class _TutorialWidgetState extends State<TutorialWidget> {
  int _state = 0;
  String _dialogText =
      "Welcome to our app, we're so glad you're here:)\nIt's time to look after your mental health!";
  late Mood _mood;

  void _onPressedNext(BuildContext context) async {
    _state = _state + 1;

    String newDialogText;
    if (_state == 1) {
      newDialogText =
          "What you can see here is our home screen: We'll guide you through the different options you have here.";
    } else if (_state == 2) {
      newDialogText =
          "First you can set your mental state here by clicking on the flower and choosing the corresponding emoji: ";
    } else if (_state == 3) {
      final prefs = await SharedPreferences.getInstance();
      final testVersion = prefs.getString(constTestVersion) ?? "A";
      if (testVersion == "A") {
        newDialogText =
            "The tree shows all the tasks that still need to be done.";
      } else {
        newDialogText = "The tree shows all the done tasks.";
      }
      newDialogText =
          '$newDialogText\nThe bigger a blossom is, the more tasks belong to a user in this category.';
    } else if (_state == 4) {
      newDialogText =
          "Last but not least: At the bottom you can navigate to the cards (left) to manage your tasks and to the diagrams (right) to have an overview of your tasks and mental load at all times!\nIsn't that great?\nAnd the button in the middle brings you back here.";
    } else {
      newDialogText = "That's it, have a nice experience!";
    }

    if (_state == 5) {
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) Navigator.of(context).pop();
    } else {
      setState(() {
        _dialogText = newDialogText;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _ownInitState();
  }

  void _ownInitState() async {
    final newMood = await Mood.create(
        userId: widget.user.userId, date: DateTime.now(), mood: Moods.good);
    setState(() {
      _mood = newMood;
    });
  }

  void _onMoodChanged(Moods newMood) {
    setState(() {
      _mood.mood = newMood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Welcome!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_dialogText),
          if (_state == 2)
            FlowerWidget(mood: _mood, onMoodChanged: _onMoodChanged)
        ],
      ),
      actions: [
        ElevatedButton(
            onPressed: () => _onPressedNext(context), child: const Text("Next"))
      ],
    );
  }
}
