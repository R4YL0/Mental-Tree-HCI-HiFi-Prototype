import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Message.dart';
import 'package:mental_load/widgets/cards_bottom_sheet.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    // Set message-specific attributes
    String title;
    String description;
    IconData icon;
    Color iconColor;

    switch (message.type) {
      case MessageType.help:
        title = "Help Received";
        description = "Great news! ${message.from?.name ?? 'Someone'} took care of \"${message.task?.task.name ?? 'a task'}\" for you. Take a moment to say thank you!";
        icon = Icons.volunteer_activism;
        iconColor = Colors.teal;
        break;
      case MessageType.trade:
        title = "Trade Proposal";
        description = "\"${message.offerTask?.task.name ?? 'Unknown'}\" was offered in exchange for \"${message.receiveTask?.task.name ?? 'Unknown'}\".";
        icon = Icons.swap_horiz;
        iconColor = Colors.indigo;
        break;
      case MessageType.tradeAccepted:
        title = "Trade Accepted";
        description =
            "${message.from?.name ?? 'Someone'} accepted your trade proposal involving \"${message.offerTask?.task.name ?? 'Unknown'}\" and \"${message.receiveTask?.task.name ?? 'Unknown'}\".";
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case MessageType.tradeDeclined:
        title = "Trade Declined";
        description =
            "${message.from?.name ?? 'Someone'} declined your trade proposal involving \"${message.offerTask?.task.name ?? 'Unknown'}\" and \"${message.receiveTask?.task.name ?? 'Unknown'}\".";
        icon = Icons.cancel;
        iconColor = Colors.redAccent;
        break;
      case MessageType.reminder:
        title = "Task Reminder";
        description = "Reminder to complete the task \"${message.task?.task.name ?? 'a task'}\".";
        icon = Icons.notifications;
        iconColor = Colors.redAccent;
        break;
      case MessageType.thanks:
        title = "Thank You Received";
        description = "${message.from?.name ?? 'Someone'} has sent their thanks for your help with \"${message.task?.task.name ?? 'a task'}\"!";
        icon = Icons.thumb_up_alt;
        iconColor = Colors.green;
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
          widget.message.updateFieldsInFirebase(read: true);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: message.read ? Colors.grey[100] : Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: message.read ? Colors.grey[300]! : Colors.blueAccent,
            width: message.read ? 1.0 : 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                switch (message.type) {
                  MessageType.trade => _buildTradeOverview(message),
                  MessageType.help => _buildHelpMessageButtons(message),
                  MessageType.reminder => _buildReminderMessageOptions(message),
                  MessageType.thanks => _buildThanksMessage(message),
                  MessageType.tradeAccepted => _buildTradeAcceptedMessage(message),
                  MessageType.tradeDeclined => _buildTradeDeclinedMessage(message),
                },
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTradeDeclinedMessage(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Your trade proposal was declined. Tasks:\n"
            "You offered: \"${message.offerTask?.task.name ?? 'Unknown'}\"\n"
            "You requested: \"${message.receiveTask?.task.name ?? 'Unknown'}\"",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 16),
        _buildDeleteButton(message),
      ],
    );
  }

  Widget _buildReminderMessageOptions(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          label: "View Task",
          color: Colors.blueAccent,
          onPressed: () {
            showTaskBottomSheet(context: context, task: message.task, size: Size.big);
          },
        ),
        _buildActionButton(
          label: "Mark as Done",
          color: Colors.green,
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Task \"${message.task?.task.name ?? 'Unknown'}\" marked as completed!")),
            );
            print('AssignedTask ID: ${message.task?.assignedTaskId}');

            await message.task!.updateFieldsInFirebase(finishDate: DateTime.now());
            setState(() {});
          },
        ),
        _buildDeleteButton(message),
      ],
    );
  }

  Widget _buildThanksMessage(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "You've been thanked for your help with \"${message.task?.task.name ?? 'Unknown'}\"!",
            style: const TextStyle(fontSize: 16, color: Colors.green),
          ),
        ),
        const SizedBox(height: 16),
        _buildDeleteButton(message),
      ],
    );
  }

  Widget _buildTradeAcceptedMessage(Message message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Your trade proposal was accepted! Tasks exchanged:\n"
            "You receive: \"${message.receiveTask?.task.name ?? 'Unknown'}\"\n"
            "You offered: \"${message.offerTask?.task.name ?? 'Unknown'}\"",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.green),
          ),
        ),
        const SizedBox(height: 16),
        _buildDeleteButton(message),
      ],
    );
  }

  Widget _buildTradeOverview(Message message) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = constraints.maxWidth * 0.4;
            final double aspectRatio = 140 / 200;
            final double cardHeight = cardWidth / aspectRatio;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Card = Receive
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "You Give",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        if (message.receiveTask != null) {
                          showTaskBottomSheet(context: context, task: message.receiveTask, size: Size.big);
                        }
                      },
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: message.receiveTask != null
                            ? Cards(
                                thisTask: Future.value(message.receiveTask!.task),
                                sState: SmallState.info,
                                bState: BigState.info,
                                size: Size.small,
                                heightBig: cardHeight,
                              )
                            : const Center(
                                child: Text(
                                  "No Task",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                // Trade Arrow
                Column(
                  children: [
                    const SizedBox(height: 24),
                    Icon(
                      Icons.swap_horiz,
                      size: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                // Right Card = Offer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "You Receive",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        if (message.offerTask != null) {
                          showTaskBottomSheet(context: context, task: message.offerTask, size: Size.big);
                        }
                      },
                      child: Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.primary,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: message.offerTask != null
                            ? Cards(
                                thisTask: Future.value(message.offerTask!.task),
                                sState: SmallState.info,
                                bState: BigState.info,
                                size: Size.small,
                                heightBig: cardHeight,
                              )
                            : const Center(
                                child: Text(
                                  "No Task",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // Buttons: Accept, Decline, Delete
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              label: "Accept",
              color: Colors.green,
              onPressed: () async {
                await Message.create(
                  task: null,
                  offerTask: message.offerTask,
                  receiveTask: message.receiveTask,
                  from: message.to!,
                  to: message.from!,
                  type: MessageType.tradeAccepted,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trade accepted!")),
                );

                try {
                  // Update the task's user
                  await message.offerTask!.setUser(message.to!);
                  await message.receiveTask!.setUser(message.from!);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Failed to update task: ${e.toString()}",
                      ),
                    ),
                  );
                }
                setState(() {});
              },
            ),
            _buildActionButton(
              label: "Decline",
              color: Colors.orangeAccent,
              onPressed: () async {
                await Message.create(
                  task: null,
                  offerTask: message.offerTask,
                  receiveTask: message.receiveTask,
                  from: message.to!,
                  to: message.from!,
                  type: MessageType.tradeDeclined,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trade declined.")),
                );
                setState(() {});
              },
            ),
            _buildDeleteButton(message),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpMessageButtons(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          label: message.thankYouSent ? "Thanks Sent" : "Send Thanks",
          color: message.thankYouSent ? Colors.grey : Colors.teal,
          onPressed: message.thankYouSent
              ? null // Disabled button if thanks already sent
              : () {
                  _sendThanks(message);
                },
        ),
        _buildActionButton(
          label: "View Task",
          color: Colors.blueAccent,
          onPressed: () {
            if (message.task != null) {
              showTaskBottomSheet(context: context, task: message.task, size: Size.big);
            }
          },
        ),
        _buildDeleteButton(message), // Use reusable delete button
      ],
    );
  }

  /// Helper function to send thanks
  void _sendThanks(Message message) async {
    setState(() {
      message.thankYouSent = true; // Update local state
    });
    await message.saveToFirebase();

    if (message.from != null) {
      await Message.create(
        task: null,
        offerTask: null,
        receiveTask: null,
        from: message.to!,
        to: message.from!,
        type: MessageType.thanks,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Thank you sent to ${message.from!.name}!")),
      );
    }
  }

  /// Reusable action button widget
  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed, // Nullable parameter to handle disabled state
  }) {
    return ElevatedButton(
      onPressed: onPressed, // Pass directly
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDeleteButton(Message message) {
    return Align(
      alignment: Alignment.centerRight, // Align the button to the right
      child: ElevatedButton(
        onPressed: () async {
          bool confirmDelete = await _showDeleteConfirmationDialog();
          if (confirmDelete) {
            await message.removeFromFirebase();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Message deleted!")),
            );
            setState(() {});
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          "Delete",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildThankYouMessageButtons(Message message) {
    return Center(
      child: _buildDeleteButton(message),
    );
  }
}
