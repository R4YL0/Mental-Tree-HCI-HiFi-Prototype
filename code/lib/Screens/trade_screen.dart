import 'package:flutter/material.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class TradeScreen extends StatelessWidget {
  final AssignedTask targetTask;
  final Future<List<AssignedTask>> myTasksFuture;

  TradeScreen({required this.targetTask, required this.myTasksFuture});

  void _proposeTrade(BuildContext context, AssignedTask targetTask, AssignedTask offeredTask) {
    // Implement the logic to handle the trade offer.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "You offered '${offeredTask.task.name}' in exchange for '${targetTask.task.name}'.",
        ),
      ),
    );
    Navigator.pop(context); // Go back after the trade is proposed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Propose Trade"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target card to acquire
            Text(
              "You want this card:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Cards(
                thisTask: Future.value(targetTask.task),
                sState: SmallState.info,
                bState: BigState.info,
                size: Size.big,
                heightBig: 200,
              ),
            ),
            SizedBox(height: 20),

            // Scrollable list of user's cards
            Text(
              "Select one of your cards to offer:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<AssignedTask>>(
                future: myTasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("You don't have any cards to trade."));
                  } else {
                    final myTasks = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: myTasks.length,
                      itemBuilder: (context, index) {
                        final offeredTask = myTasks[index];
                        return GestureDetector(
                          onTap: () => _proposeTrade(context, targetTask, offeredTask),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Cards(
                                thisTask: Future.value(offeredTask.task),
                                sState: SmallState.info,
                                bState: BigState.info,
                                size: Size.small,
                                heightBig: 200,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.cancel),
                  label: Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle confirm logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Trade proposed successfully!"),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.check_circle),
                  label: Text("Confirm Trade"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
