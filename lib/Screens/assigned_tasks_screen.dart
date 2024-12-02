import 'package:flutter/material.dart';
import 'package:mental_load/Screens/tasks_overview_after_screen%20.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/functions/sharedPreferences.dart';
import 'package:mental_load/widgets/cards_bottom_sheet.dart';
import 'package:mental_load/widgets/cards_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignedTasksOverview extends StatefulWidget {
  const AssignedTasksOverview({Key? key}) : super(key: key);

  @override
  _AssignedTasksOverviewState createState() => _AssignedTasksOverviewState();
}

class _AssignedTasksOverviewState extends State<AssignedTasksOverview>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<AssignedTask>> _myAssignedTasksFuture;
  late Future<List<User>> _usersFuture;
  int? _selectedUserId;
  late Future<List<AssignedTask>> _selectedUserAssignedTasksFuture;
  AssignedTask? selectedTask;
  bool _showCompletedTasks = false;

  String _sortOption = "Date";
  final List<String> _sortOptions = ["Date", "Name", "Priority", "Difficulty"];
  int _currentSortIndex = 0;
  Category? _selectedCategory;

  late User currUser;

  @override
  void initState() {
    super.initState();
    _myInit();
    _tabController = TabController(length: 3, initialIndex: 1, vsync: this);
  }

  void _myInit() async {
    int? curUserId = await getCurUserId();
    User? newCurrUser = await DBHandler().getUserByUserId(curUserId);
    if (newCurrUser != null) setState(() => currUser = newCurrUser);

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _myAssignedTasksFuture = _fetchMyAssignedTasks();
      _usersFuture = _fetchUsers();
    });
  }

  Future<List<AssignedTask>> _fetchMyAssignedTasks() async {
    final curUserId = await getCurUserId();
    return AssignedTask.getTasksForUser(curUserId);
  }

  Future<List<User>> _fetchUsers() async {
    return DBHandler().getUsers();
  }

  void _fetchSelectedUserAssignedTasks(int userId) {
    setState(() {
      _selectedUserAssignedTasksFuture = AssignedTask.getTasksForUser(userId);
    });
  }

  void _rotateSortOption() {
    setState(() {
      _currentSortIndex = (_currentSortIndex + 1) % _sortOptions.length;
      _sortOption = _sortOptions[_currentSortIndex];
    });
  }

  void _showYourTaskAction(BuildContext context, AssignedTask assignedTask) {
    showTaskBottomSheet(context: context, task: assignedTask, size: Size.big);
  }

  Widget _buildSortAndFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _rotateSortOption,
            ),
            Text("Sort by $_sortOption"),
          ],
        ),
        DropdownButton<String>(
          value:
              _selectedCategory == null ? "No Filter" : _selectedCategory!.name,
          hint: const Text("Filter by Category"),
          items: [
            const DropdownMenuItem<String>(
              value: "No Filter",
              child: Text("No Filter"),
            ),
            ...Category.values.map((category) {
              return DropdownMenuItem<String>(
                value: category.name,
                child: Text(category.name),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              if (value == "No Filter") {
                _selectedCategory = null;
              } else {
                _selectedCategory = Category.values
                    .firstWhere((category) => category.name == value);
              }
            });
          },
        ),
      ],
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: ["Date", "Priority", "Difficulty"].map((option) {
            return ListTile(
              title: Text(option),
              onTap: () {
                setState(() {
                  _sortOption = option;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  List<AssignedTask> _applySortingAndFiltering(List<AssignedTask> tasks) {
    // Apply Category Filtering
    if (_selectedCategory != null) {
      tasks = tasks.where((task) {
        return task.task.category == _selectedCategory!;
      }).toList();
    }
    // Apply Sorting
    tasks.sort((a, b) {
      switch (_sortOption) {
        case "Date":
          return a.dueDate.compareTo(b.dueDate);
        case "Name":
          return a.task.name.compareTo(b.task.name);
        case "Priority":
          return a.task.priority.compareTo(b.task.priority);
        case "Difficulty":
          return a.task.difficulty.compareTo(b.task.difficulty);
        default:
          return 0;
      }
    });

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 0, right: 10, left: 10),
        child: Column(
          children: [
            // TabBar
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.task), text: "All Tasks"),
                Tab(icon: Icon(Icons.assignment_outlined), text: "My Tasks"),
                Tab(icon: Icon(Icons.group_outlined), text: "Others' Tasks"),
              ],
            ),
            const SizedBox(height: 10),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All Tasks Tab
                  TaskOverviewDistributedScreen(),

                  // My Tasks Tab
                  _buildMyTasksTab(),

                  // Others' Tasks Tab
                  _buildOthersTasksTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// My Tasks Tab
  Widget _buildMyTasksTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: _rotateSortOption,
                ),
                Text("Sort by $_sortOption"),
              ],
            ),
            DropdownButton<String>(
              value: _selectedCategory == null
                  ? "No Filter"
                  : _selectedCategory!.name,
              hint: const Text("Filter by Category"),
              items: [
                const DropdownMenuItem<String>(
                  value: "No Filter",
                  child: Text("No Filter"),
                ),
                ...Category.values.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == "No Filter") {
                    _selectedCategory = null;
                  } else {
                    _selectedCategory = Category.values
                        .firstWhere((category) => category.name == value);
                  }
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Show Completed Tasks"),
            Switch(
              value: _showCompletedTasks,
              onChanged: (value) {
                setState(() {
                  _showCompletedTasks = value;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<AssignedTask>>(
            future: _myAssignedTasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading tasks."));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No tasks assigned to you."));
              } else {
                final tasks = _applySortingAndFiltering(snapshot.data!);
                final filteredTasks = tasks.where((task) {
                  return _showCompletedTasks || task.finishDate == null;
                }).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        (constraints.maxWidth ~/ 200).clamp(2, 4);
                    final aspectRatio = 140 / 200;

                    final cardWidth =
                        (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                            crossAxisCount;
                    final cardHeight = cardWidth / aspectRatio;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final SmallState sState = task.finishDate != null
                            ? SmallState.done
                            : SmallState.todo;

                        return GestureDetector(
                          onTap: () => _showYourTaskAction(context, task),
                          child: Cards(
                            thisTask: Future.value(task.task),
                            sState: sState,
                            bState: BigState.info,
                            size: Size.small,
                            heightBig: cardHeight,
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

// Others' Tasks Tab
  Widget _buildOthersTasksTab() {
    return Column(
      children: [
        FutureBuilder<List<User>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Text("Error loading users.");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No users found.");
            } else {
              final users = snapshot.data!;
              return FutureBuilder<int>(
                future: getCurUserId(),
                builder: (context, userIdSnapshot) {
                  if (userIdSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (userIdSnapshot.hasError) {
                    return const Text("Error loading current user ID.");
                  } else if (!userIdSnapshot.hasData) {
                    return const Text("No current user ID found.");
                  }

                  final curUserId = userIdSnapshot.data!;
                  return DropdownButton<int>(
                    value: _selectedUserId,
                    hint: const Text("Select a User"),
                    isExpanded: true,
                    items: users
                        .where((user) => user.userId != curUserId)
                        .map((user) {
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
                },
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Show Completed Tasks"),
            Switch(
              value: _showCompletedTasks,
              onChanged: (value) {
                setState(() {
                  _showCompletedTasks = value;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: _selectedUserId == null
              ? const Center(child: Text("Select a user to view their tasks."))
              : FutureBuilder<List<AssignedTask>>(
                  future: _selectedUserAssignedTasksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error loading tasks."));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text("No tasks assigned to this user."));
                    } else {
                      final tasks = _applySortingAndFiltering(snapshot.data!);
                      final filteredTasks = tasks.where((task) {
                        return _showCompletedTasks || task.finishDate == null;
                      }).toList();

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              (constraints.maxWidth ~/ 200).clamp(2, 4);
                          final aspectRatio = 140 / 200;

                          final cardWidth = (constraints.maxWidth -
                                  (crossAxisCount - 1) * 16) /
                              crossAxisCount;
                          final cardHeight = cardWidth / aspectRatio;

                          return GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              childAspectRatio: aspectRatio,
                            ),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return GestureDetector(
                                onTap: () => showOthersTaskAction(
                                    context, task, currUser, () {
                                  setState(() {
                                    _fetchMyAssignedTasks();
                                    if (_selectedUserId != null) {
                                      _fetchSelectedUserAssignedTasks(
                                          _selectedUserId!);
                                    }
                                  });
                                }),
                                child: Cards(
                                  thisTask: Future.value(task.task),
                                  sState: SmallState.info,
                                  bState: BigState.info,
                                  size: Size.small,
                                  heightBig: cardHeight,
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }
}

void showOthersTaskAction(BuildContext context, AssignedTask assignedTask,
    User currUser, Function fnCallback) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height *
                    0.85, // 85% of screen height
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Task Card with Correct Aspect Ratio
                  Expanded(
                    child: Container(
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double cardHeightBig =
                              constraints.maxHeight * 0.8;
                          return AspectRatio(
                            aspectRatio: 16 /
                                9, // Replace `aspectRatio` with a fixed value
                            child: Cards(
                              thisTask: Future.value(
                                  assignedTask.task), // Corrected Future.value
                              sState: SmallState.info,
                              bState: BigState.info,
                              size: Size.big,
                              heightBig: cardHeightBig.clamp(100,
                                  600), // Ensure height is within a valid range
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Offer Help Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close the overlay
                          showHelpConfirmationDialog(
                              context, assignedTask, fnCallback);
                        },
                        icon: Icon(Icons.volunteer_activism,
                            color: Colors.white), // White icon
                        label: Text(
                          "Offer Help",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold), // White text
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal, // Teal background
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Trade Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close the overlay
                          showTradeDialog(context, assignedTask, currUser);
                        },
                        icon: Icon(Icons.swap_horiz,
                            color: Colors.white), // White icon
                        label: Text(
                          "Trade",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold), // White text
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo, // Indigo background
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      // Remind Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close the overlay
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Reminder sent to ${assignedTask.user.name}!")),
                          );
                        },
                        icon: Icon(Icons.notifications,
                            color: Colors.white), // White icon
                        label: Text(
                          "Remind",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold), // White text
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.redAccent, // RedAccent background
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Close Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White button
                      foregroundColor: Colors.black,
                      side: BorderSide(
                          color: Colors.grey, width: 2), // Grey border
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showHelpConfirmationDialog(
    BuildContext context, AssignedTask assignedTask, Function fnCallback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Confirm Action",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You are about to take responsibility for the following task:",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    "'${assignedTask.task.name}'",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assigned To: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    "${assignedTask.user.name}",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Due Date: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${assignedTask.dueDate.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
        contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    try {
                      final curUserId = await getCurUserId();
                      final User? curUser =
                          await DBHandler().getUserByUserId(curUserId);
                      if (curUser != null) {
                        await assignedTask.setUser(curUser);
                        fnCallback();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Task '${assignedTask.task.name}' is now your responsibility.",
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Failed to update task: ${e.toString()}",
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Confirm",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void showTradeDialog(
    BuildContext context, AssignedTask targetTask, User currUser) {
  final screenHeight = MediaQuery.of(context).size.height;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      AssignedTask? selectedTask;
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.75,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Propose a Trade",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Divider(thickness: 1.5, color: Colors.grey[300]),
                    SizedBox(height: 8),

                    // Trade Overview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Card = Receive
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "You Receive",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context).colorScheme.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double width =
                                      MediaQuery.of(context).size.width * 0.35;
                                  final double height = width * (200 / 140);
                                  return Container(
                                    width: width,
                                    height: height,
                                    child: Cards(
                                      thisTask: Future.value(targetTask.task),
                                      sState: SmallState.info,
                                      bState: BigState.info,
                                      size: Size.small,
                                      heightBig: height,
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),

                        // Trade Arrow
                        Column(
                          children: [
                            SizedBox(height: 24),
                            Icon(
                              Icons.swap_horiz,
                              size: 36,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),

                        // Right Card = Selected Card
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "You Offer",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Theme.of(context).colorScheme.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double width =
                                      MediaQuery.of(context).size.width * 0.35;
                                  final double height = width * (200 / 140);

                                  return Container(
                                    width: width,
                                    height: height,
                                    child: selectedTask != null
                                        ? Cards(
                                            thisTask: Future.value(
                                                selectedTask!.task),
                                            sState: SmallState.info,
                                            bState: BigState.info,
                                            size: Size.small,
                                            heightBig: height,
                                          )
                                        : Center(
                                            child: Text(
                                              "No card selected",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Card Selection Scroll View
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select one of your cards to offer:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double width =
                                  MediaQuery.of(context).size.width * 0.35;
                              final double height = width * (200 / 140);

                              return SizedBox(
                                height: height,
                                child: FutureBuilder<List<AssignedTask>>(
                                  future: fetchMyAssignedTasks(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                        child: Text(
                                          "No cards to trade.",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      );
                                    } else {
                                      final tasks = snapshot.data!;
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: tasks.map((task) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedTask =
                                                      selectedTask == task
                                                          ? null
                                                          : task;
                                                });
                                              },
                                              child: Container(
                                                width: width,
                                                height: height,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: selectedTask == task
                                                        ? Colors.teal
                                                        : Colors.transparent,
                                                    width: 4,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Cards(
                                                  thisTask:
                                                      Future.value(task.task),
                                                  sState: SmallState.info,
                                                  bState: BigState.info,
                                                  size: Size.small,
                                                  heightBig: height,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 120,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: selectedTask != null
                                ? () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Trade proposed with task: ${selectedTask!.task.name}"),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTask != null
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Confirm",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<List<AssignedTask>> fetchMyAssignedTasks() async {
  final curUserId = await getCurUserId();
  return AssignedTask.getTasksForUser(curUserId);
}
