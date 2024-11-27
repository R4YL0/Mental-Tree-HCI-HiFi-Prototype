import 'package:flutter/material.dart';
import 'package:mental_load/Screens/verify_submission_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/main.dart';
import 'package:mental_load/widgets/cards_widget.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipableCardScreen extends StatefulWidget {
  const SwipableCardScreen({super.key});

  @override
  State<SwipableCardScreen> createState() => _SwipableCardScreenState();
}

class _SwipableCardScreenState extends State<SwipableCardScreen> {
  List<Task> _remainingTasks = [];
  late CardSwiperController _cardController;
  int currentTaskIndex = 0; // Index to track the current task
  bool _isLoading = true; // Flag to indicate loading state

  @override
  void initState() {
    super.initState();
    _cardController = CardSwiperController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true; // Set loading to true while data is being fetched
    });

    List<Task> tasks = await DBHandler().getUndecidedTasksByUserID(currUser.userId);
    print(tasks.length);

    if (tasks.isEmpty) {
      // Navigate to IncompletePreferencesScreen if no tasks are left
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TaskSubmissionScreen(),
          ),
        );
      });
    } else {
      setState(() {
        _remainingTasks = tasks;
        _isLoading = false; // Set loading to false once data is initialized
      });
    }
  }

  void _showFeedback(BuildContext context, String message, Color color, {VoidCallback? onUndo}) {
    // Implement your feedback mechanism here if needed
  }

  void _likeTask(Task task) {
    currUser.updateTaskState(task.taskId, TaskState.Like);
    _showFeedback(
      context,
      "Added '${task.name}' to Favorites!",
      Colors.green,
    );
  }

  void _dislikeTask(Task task) {
    currUser.updateTaskState(task.taskId, TaskState.Dislike);
    _showFeedback(
      context,
      "Added '${task.name}' to Dislikes!",
      Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while data is being loaded
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate the number of remaining cards
    int cardsRemaining = _remainingTasks.length - currentTaskIndex;
    print("remaining: $cardsRemaining");
    // Determine how many cards to display at once
    int numberOfCards = cardsRemaining < 3 ? cardsRemaining : 3;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          left: 10,
          bottom: 0,
        ),
        child: Column(
          children: [
            const Text(
              "Task Preferences",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Swipe left to Favorite, Swipe right to Dislike",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Expanded(
              child: CardSwiper(
                controller: _cardController,
                cardsCount: cardsRemaining,
                isLoop: false,
                numberOfCardsDisplayed: numberOfCards,
                cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                  int taskIndex = currentTaskIndex + index;
                  if (taskIndex >= _remainingTasks.length) {
                    print("ERROR NO CARDS LEFT");
                    return Container();
                  }
                  return Cards(
                    thisTask: Future.value(_remainingTasks[taskIndex]),
                    sState: SmallState.info,
                    bState: BigState.info,
                    size: Size.big,
                  );
                },
                onSwipe: (previousIndex, currentIndex, direction) async {
                  int taskIndex = currentIndex ?? 0 + previousIndex ?? 0;

                  print("taskindex: $currentIndex");
                  final task = _remainingTasks[taskIndex];
                  if (direction == CardSwiperDirection.left) {
                    _likeTask(task);
                  } else if (direction == CardSwiperDirection.right) {
                    _dislikeTask(task);
                  }

                  return true;
                },
                onEnd: () {
                  print("END OF STACK REACHED");

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TaskSubmissionScreen(),
                      ),
                    );
                  });
                },
                allowedSwipeDirection: AllowedSwipeDirection.only(left: true, right: true),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (currentTaskIndex < _remainingTasks.length) {
                        _cardController.swipe(CardSwiperDirection.left);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.favorite, color: Colors.white, size: 30),
                        SizedBox(width: 8),
                        Text("Like", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentTaskIndex < _remainingTasks.length) {
                        _cardController.swipe(CardSwiperDirection.right);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.thumb_down, color: Colors.white, size: 30),
                        SizedBox(width: 8),
                        Text("Dislike", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
