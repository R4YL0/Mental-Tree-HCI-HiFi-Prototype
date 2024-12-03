import 'package:flutter/material.dart';
import 'package:mental_load/Screens/cards_screen.dart';
import 'package:mental_load/Screens/diagrams_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/widgets/flower_widget.dart';

class TutorialWidget extends StatefulWidget {
  final User user;
  final int startIndex;

  const TutorialWidget({super.key, required this.user, this.startIndex = 0});

  @override
  State<TutorialWidget> createState() => _TutorialWidgetState();
}

class _TutorialWidgetState extends State<TutorialWidget> {
  int _state = 0;
  String _dialogText =
      "Welcome to our app, we're so glad you're here:)\nIt's time to look after your mental health!";
  late Mood _mood;

  @override
  void initState() {
    super.initState();
    _ownInitState();
  }

  void _ownInitState() async {
    final lastUserMood =
        await DBHandler().getLatestMoodByUserId(widget.user.userId);
    if (lastUserMood != null) {
      _state = widget.startIndex;
      _setNewDialogText();
      setState(() {
        _mood = lastUserMood;
      });
    }
  }

  void _setNewDialogText() {
    String newDialogText;
    if (_state == 1) {
      newDialogText =
          "What you can see here is our home screen: We'll guide you through the different options you have here.";
    } else if (_state == 2) {
      newDialogText =
          "First you can set your mental state here by clicking on the flower and choosing the corresponding emoji: ";
    } else if (_state == 3) {
      newDialogText =
          "The tree gives an overview of all the assigned and completed tasks of the last thirty days.";
    } else if (_state == 4) {
      newDialogText =
          "There is a blossom for each user in each category. There are 6 categories shown by the six branches in the tree. The bigger a blossom is, the more tasks belong to a user in this category.";
    } else if (_state == 5) {
      newDialogText =
          "Then there are two other screens you can navigate to on this home screen via the bottom navigation bar.";
    } else if (_state == 6) {
      newDialogText =
          "First diagrams where you have an overview over the task distributions.";
    } else if (_state == 7) {
      newDialogText =
          "Here on the Cards screen, you can see the task of your household represented as cards. At the top you see four more options to navigate to:";
    } else if (_state == 8) {
      newDialogText =
          "Overview allows you to see all tasks you’ve created, can create new ones and edit them";
    } else if (_state == 9) {
      newDialogText =
          "Swipe allows you to pick your favorites by swiping to the left and dislike by swiping to the right";
    } else if (_state == 10) {
      newDialogText =
          "On Preferences you can see which Tasks you liked and disliked";
    } else if (_state == 11) {
      newDialogText =
          "On Group you can see who has already chosen their favorites";
    } else if (_state == 12) {
      newDialogText =
          "After everyone has chosen their favorites, the cards get shuffled and everybody gets their tasks assigned";
    } else if (_state == 13) {
      newDialogText =
          "If we click on a Card, we’ll open up it’s Info-view, which consists of the General Page, Subtasks, and Notes";
    } else if (_state == 14) {
      newDialogText =
          "Within a card, you can click the edit button on the top-right to open up the Edit-View. By Clicking on any Button or Text, you can to change it";
    } else if (_state == 15) {
      newDialogText =
          "Important: The Priority and Difficulty Ratings are not only for you to judge how much effort a Task takes, but is also taken into consideration for Shuffling";
    } else if (_state == 16) {
      newDialogText =
          "To leave the Edit-View you need to press the Accept button on the Top-right, then you'll get back to the Info-View";
    } else if (_state == 17) {
      newDialogText =
          "You’re all caught up now! We hope this helps your household to manage the tasks and reduce your Mental Load ;)";
    } else {
      // default state
      newDialogText = _dialogText;
    }

    _dialogText = newDialogText;
  }

  void _onPressedNext(BuildContext context) async {
    _state = _state + 1;

    _setNewDialogText();

    if (_state == 6) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DiagramsScreen(),
      ));
      await showDialog(
          context: context,
          builder: (BuildContext context) => TutorialWidget(
                user: widget.user,
                startIndex: 6,
              ));
    } else if (_state == 7) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CardsScreen(),
      ));
      await showDialog(
          context: context,
          builder: (BuildContext context) => TutorialWidget(
                user: widget.user,
                startIndex: 7,
              ));
    } else if (_state == 18) {
      Navigator.of(context).pop(); // pop dialog
      Navigator.of(context).pop(); // pop cards screen
      Navigator.of(context).pop(); // pop dialog
      Navigator.of(context).pop(); // pop diagrams screen
      Navigator.of(context).pop(); // pop dialog
    }

    setState(() {});
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
