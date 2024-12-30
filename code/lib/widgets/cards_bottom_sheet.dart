import 'package:flutter/material.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget cardContent;
  final Widget bottomContent;
  final VoidCallback? onClose; // Callback for the close button

  CustomBottomSheet({
    required this.cardContent,
    required this.bottomContent,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              child: AspectRatio(
                aspectRatio: 140 / 200,
                child: cardContent,
              ),
            ),
            SizedBox(height: 20),
            bottomContent,
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onClose ?? () => Navigator.pop(context), // Default to pop if no callback is provided
              child: Text(
                "Close",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void showTaskBottomSheet({
  required BuildContext context,
  required dynamic task,
  required Size size,
  BigState bState = BigState.info,
  SmallState sState = SmallState.info,
  Widget? additionalWidgets,
  VoidCallback? onClose, 
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      Task? resolvedTask;

      if (task is AssignedTask) {
        resolvedTask = task.task;
      } else if (task is Task) {
        resolvedTask = task;
      } else {
        throw ArgumentError('Invalid task type provided. Must be Task or AssignedTask.');
      }

      return CustomBottomSheet(
        cardContent: LayoutBuilder(
          builder: (context, constraints) {
            final double cardHeightBig = constraints.maxHeight * 0.8;
            return Cards(
              thisTask: Future.value(resolvedTask),
              sState: sState,
              bState: bState,
              size: size,
              heightBig: cardHeightBig.clamp(100, 600),
            );
          },
        ),
        bottomContent: additionalWidgets ?? Container(),
        onClose: onClose, 
      );
    },
  );
}




