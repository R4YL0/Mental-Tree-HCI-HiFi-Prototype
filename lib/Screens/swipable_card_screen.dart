import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/main.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class SwipableCardScreen extends StatefulWidget {
  final TabController tabController;

  const SwipableCardScreen({Key? key, required this.tabController}) : super(key: key);

  @override
  State<SwipableCardScreen> createState() => _SwipableCardScreenState();
}

class _SwipableCardScreenState extends State<SwipableCardScreen> {
  List<Task> _remainingTasks = [];
  List<Task> _cardsAtStart = [];
  late CardSwiperController _cardController;
  bool _isLoading = true;
  List<int> _submittedUsers = [];

  @override
  void initState() {
    super.initState();
    _cardController = CardSwiperController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });
    _submittedUsers = await DBHandler().getSubmittedUsers();
    _remainingTasks = await DBHandler().getUndecidedTasksByUserID(currUser.userId);
    _cardsAtStart = await DBHandler().getUndecidedTasksByUserID(currUser.userId);
    _isLoading = false;
    setState(() {});
  }

  void _likeTask(Task task) {
    _remainingTasks.remove(task);
    currUser.updateTaskState(task.taskId, TaskState.Like);
  }

  void _dislikeTask(Task task) {
    _remainingTasks.remove(task);
    currUser.updateTaskState(task.taskId, TaskState.Dislike);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_remainingTasks.isEmpty || _submittedUsers.contains(currUser.userId)) {
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
              const Text(
                "You're all caught up!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (_submittedUsers.contains(currUser.userId)) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Restart Swiping"),
                          content: const Text(
                            "You have already submitted your preferences. Restarting will remove your submission and reset your preferences. Do you want to continue?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await DBHandler().removeSubmittedUser(currUser.userId);
                                currUser.taskStates = {};
                                await _initializeData();
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: const Text(
                                "Continue",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      currUser.taskStates = {};
                      await _initializeData();
                      setState(() {});
                    }
                  } catch (e) {
                    print("Error fetching submitted users: $e");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  "Restart Swiping",
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
 

    int cardsToShow = _remainingTasks.length < 3 ? _remainingTasks.length : 3;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Swipe left to Like, Swipe right to Dislike",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double cardHeightBig = constraints.maxHeight - 50;
              final double cardWidthBig = cardHeightBig * (140 / 200);

              return SizedBox(
                width: cardWidthBig,
                height: cardHeightBig,
                child: CardSwiper(
                  controller: _cardController,
                  cardsCount: _remainingTasks.length,
                  isLoop: false,
                  duration: const Duration(milliseconds: 300),
                  numberOfCardsDisplayed: cardsToShow,
                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                    return Cards(
                      thisTask: Future.value(_cardsAtStart[index]),
                      sState: SmallState.info,
                      bState: BigState.swipe,
                      size: Size.big,
                      heightBig: cardHeightBig,
                    );
                  },
                  onSwipe: (previousIndex, currentIndex, direction) async {
                    final task = _remainingTasks[0];
                    if (direction == CardSwiperDirection.left) {
                      _likeTask(task);
                    } else if (direction == CardSwiperDirection.right) {
                      _dislikeTask(task);
                    }
                    return true;
                  },
                  onEnd: () {
                    widget.tabController.animateTo(2);
                  },
                  allowedSwipeDirection: AllowedSwipeDirection.only(left: true, right: true),
                  padding: EdgeInsets.only(bottom: 50),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_remainingTasks.isNotEmpty) {
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
                  if (_remainingTasks.isNotEmpty) {
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
      ],
    );
  }
}
