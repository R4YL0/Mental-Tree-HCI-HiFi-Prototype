import 'package:flutter/material.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/main.dart';
import 'package:mental_load/widgets/cards_widget.dart';

class TasksOverviewScreen extends StatefulWidget {
  const TasksOverviewScreen({Key? key}) : super(key: key);

  @override
  _TasksOverviewScreenState createState() => _TasksOverviewScreenState();
}

class _TasksOverviewScreenState extends State<TasksOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<AssignedTask>> _myAssignedTasksFuture;
  late Future<List<User>> _usersFuture;
  int? _selectedUserId;
  late Future<List<AssignedTask>> _selectedUserAssignedTasksFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMyAssignedTasks();
    _fetchUsers();
  }

  void _fetchMyAssignedTasks() {
    _myAssignedTasksFuture = AssignedTask.getTasksForUser(currUser.userId);
  }

  void _fetchUsers() async {
    _usersFuture = DBHandler().getUsers();
  }

  void _fetchSelectedUserAssignedTasks(int userId) {
    _selectedUserAssignedTasksFuture = AssignedTask.getTasksForUser(userId);
  }


void _showTaskActions(BuildContext context, AssignedTask assignedTask) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // Transparent to allow custom background
    builder: (BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width, // Full width of the screen
        decoration: BoxDecoration(
          color: Colors.grey[100], // Lighter background
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enlarged Card
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
                  thisTask: Future.value(assignedTask.task),
                  sState: SmallState.info,
                  bState: BigState.info,
                  size: Size.big, // Bigger size for modal
                ),
              ),
              SizedBox(height: 20),
              // Buttons with Padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    // Implement Offer Help logic
                  },
                  icon: Icon(Icons.volunteer_activism, color: Colors.white),
                  label: Text("Offer Help"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Professional teal color
                    foregroundColor: Colors.white, // Button text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    // Implement Ask for Trade logic
                  },
                  icon: Icon(Icons.swap_horiz, color: Colors.white),
                  label: Text("Ask for Trade"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                    // Implement Remind logic
                  },
                  icon: Icon(Icons.notifications, color: Colors.white),
                  label: Text("Remind ${assignedTask.user.name}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Tasks Overview"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "My Tasks"),
            Tab(text: "Others' Tasks"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Tasks Tab
          FutureBuilder<List<AssignedTask>>(
            future: _myAssignedTasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading your tasks."));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No tasks assigned to you."));
              } else {
                final myTasks = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of cards in each row
                    crossAxisSpacing: 16.0, // Spacing between columns
                    mainAxisSpacing: 16.0, // Spacing between rows
                    childAspectRatio: 3 / 4, // Aspect ratio for the cards
                  ),
                  itemCount: myTasks.length,
                  itemBuilder: (context, index) {
                    final assignedTask = myTasks[index];
                    return Cards(
                      thisTask: Future.value(assignedTask.task),
                      sState: SmallState.info,
                      bState: BigState.info,
                      size: Size.small, // Use a smaller size for grid display
                      //dueDate: assignedTask.dueDate, // Uncomment if needed
                      //finishDate: assignedTask.finishDate, // Uncomment if needed
                    );
                  },
                );
              }
            },
          ),

          // Others' Tasks Tab
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown to select a user
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<User>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error loading users.");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No users found.");
                    } else {
                      final users = snapshot.data!;
                      return DropdownButton<int>(
                        value: _selectedUserId,
                        hint: Text("Select a User"),
                        isExpanded: true,
                        items: users.where((user) => user.userId != currUser.userId).map((user) {
                          return DropdownMenuItem<int>(
                            value: user.userId,
                            child: Text(user.name),
                          );
                        }).toList(),
                        onChanged: (userId) {
                          setState(() {
                            _selectedUserId = userId;
                            _fetchSelectedUserAssignedTasks(userId!);
                          });
                        },
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: _selectedUserId == null
                    ? Center(child: Text("Select a user to view their tasks."))
                    : FutureBuilder<List<AssignedTask>>(
                        future: _selectedUserAssignedTasksFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text("Error loading tasks."));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text("No tasks assigned to this user."));
                          } else {
                            final tasks = snapshot.data!;
                            return GridView.builder(
                              padding: const EdgeInsets.all(16.0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Number of cards per row
                                crossAxisSpacing: 16.0, // Spacing between columns
                                mainAxisSpacing: 16.0, // Spacing between rows
                                childAspectRatio: 3 / 4, // Aspect ratio for the cards
                              ),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final assignedTask = tasks[index];
                                return GestureDetector(
                                  onTap: () => _showTaskActions(context, assignedTask),
                                  child: Cards(
                                    thisTask: Future.value(assignedTask.task),
                                    sState: SmallState.info,
                                    bState: BigState.info,
                                    size: Size.small,
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
