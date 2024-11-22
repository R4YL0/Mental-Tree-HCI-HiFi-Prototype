import 'package:flutter/material.dart';
import '../classes/widgets/card_big.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:swipeable_card_stack/swipeable_card_stack.dart';

// Example Task for testingclear

Future<Task> test = Task.create(
  name: "Antidisestablishment (very long example)",
  category: Category.Cleaning,
  frequency: Frequency.daily,
  notes: "none",
  isPrivate: false,
  difficulty: 3,
  priority: 3,
);

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a SwipeableCardSectionController
    SwipeableCardSectionController _cardController = SwipeableCardSectionController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Swipeable Cards"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Swipeable Cards Section
          Expanded(
            child: SwipeableCardsSection(
              cardController: _cardController,
              context: context,
              // Add the first set of BigCard widgets
              items: [
                CardBig(thisTask: test),
                CardBig(thisTask: test),
                CardBig(thisTask: test),
              ],
              // Card swipe callback
              onCardSwiped: (dir, index, widget) {
                // Add the next card dynamically
                _cardController.addItem(CardBig(thisTask: test));
                
                // Optional: Handle swipe direction
                if (dir == Direction.left) {
                  print("Card $index swiped left");
                } else if (dir == Direction.right) {
                  print("Card $index swiped right");
                }
              },
              enableSwipeUp: false,
              enableSwipeDown: false,
            ),
          ),
          // Additional UI or buttons (if needed)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _cardController.triggerSwipeLeft(),
                  child: Text("Swipe Left"),
                ),
                ElevatedButton(
                  onPressed: () => _cardController.triggerSwipeRight(),
                  child: Text("Swipe Right"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
