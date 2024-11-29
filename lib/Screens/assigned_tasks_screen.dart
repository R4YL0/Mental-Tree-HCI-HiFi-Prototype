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
  AssignedTask? selectedTask; // Tracks the selected card

  String _sortOption = "Date"; // Default sorting option
  final List<String> _sortOptions = ["Date", "Priority", "Difficulty"];
  int _currentSortIndex = 0; // Default sort option is "Date"
  Category? _selectedCategory; // Default no category filter

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

  void _fetchSelectedUserAssignedTasks(int userId) {
    _selectedUserAssignedTasksFuture = AssignedTask.getTasksForUser(userId);
  }

  void _fetchUsers() async {
    _usersFuture = DBHandler().getUsers();
  }

  void _rotateSortOption() {
    setState(() {
      _currentSortIndex = (_currentSortIndex + 1) % _sortOptions.length;
      _sortOption = _sortOptions[_currentSortIndex];
    });
  }

  void _showYourTaskAction(BuildContext context, AssignedTask assignedTask) {
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
                  maxHeight: MediaQuery.of(context).size.height * 0.85, // 85% of screen height
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
                            final double cardHeightBig = constraints.maxHeight * 0.8;
                            return AspectRatio(
                              aspectRatio: 16 / 9, // Replace `aspectRatio` with a fixed value
                              child: Cards(
                                thisTask: Future.value(assignedTask.task), // Corrected Future.value
                                sState: SmallState.info,
                                bState: BigState.info,
                                size: Size.big,
                                heightBig: cardHeightBig.clamp(100, 600), // Ensure height is within a valid range
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Close Button
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // White button
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey, width: 2), // Grey border
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
          },
        );
      },
    );
  }

  void _showOthersTaskAction(BuildContext context, AssignedTask assignedTask) {
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
                  maxHeight: MediaQuery.of(context).size.height * 0.85, // 85% of screen height
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
                            final double cardHeightBig = constraints.maxHeight * 0.8;
                            return AspectRatio(
                              aspectRatio: 16 / 9, // Replace `aspectRatio` with a fixed value
                              child: Cards(
                                thisTask: Future.value(assignedTask.task), // Corrected Future.value
                                sState: SmallState.info,
                                bState: BigState.info,
                                size: Size.big,
                                heightBig: cardHeightBig.clamp(100, 600), // Ensure height is within a valid range
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
                            _showConfirmationDialog(context, assignedTask);
                          },
                          icon: Icon(Icons.volunteer_activism, color: Colors.white), // White icon
                          label: Text(
                            "Offer Help",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White text
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal, // Teal background
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        // Trade Button
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Close the overlay
                            _showTradeDialog(context, assignedTask);
                          },
                          icon: Icon(Icons.swap_horiz, color: Colors.white), // White icon
                          label: Text(
                            "Trade",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White text
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo, // Indigo background
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                              SnackBar(content: Text("Reminder sent to ${assignedTask.user.name}!")),
                            );
                          },
                          icon: Icon(Icons.notifications, color: Colors.white), // White icon
                          label: Text(
                            "Remind",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White text
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent, // RedAccent background
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // White button
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey, width: 2), // Grey border
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
          },
        );
      },
    );
  }

  void _showTradeDialog(BuildContext context, AssignedTask targetTask) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        AssignedTask? selectedTask; // Tracks the selected card
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 16), // Reduced side padding
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.9, // Ensure compact width
              maxHeight: screenHeight * 0.7, // Height limited to 70% of the screen
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dialog Title
                      Text(
                        "Propose a Trade",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      Divider(thickness: 1.5, color: Colors.grey[300]),
                      SizedBox(height: 8),

                      // Trade Overview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround, // Equal spacing
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Card (Target Card)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "You Receive",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87, // High contrast text color
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 140, // Fixed width for consistent aspect ratio
                                height: 200, // Fixed height for consistent aspect ratio
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                  gradient: LinearGradient(
                                    colors: [Colors.green[100]!, Colors.green[300]!], // Intuitive "Receive" color
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(2, 4), // Subtle shadow for depth
                                    ),
                                  ],
                                ),
                                child: Cards(
                                  thisTask: Future.value(targetTask.task),
                                  sState: SmallState.info,
                                  bState: BigState.info,
                                  size: Size.small,
                                  heightBig: 200, // Adjusted heightBig
                                ),
                              ),
                            ],
                          ),

                          // Trade Arrow
                          Column(
                            children: [
                              SizedBox(height: 16), // Add space to align with cards
                              Icon(
                                Icons.swap_horiz,
                                size: 36,
                                color: Colors.indigo,
                              ),
                            ],
                          ),

                          // Right Card (Selected Card)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "You Offer",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87, // High contrast text color
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 140, // Fixed width for consistent aspect ratio
                                height: 200, // Fixed height for consistent aspect ratio
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                  gradient: LinearGradient(
                                    colors: [Colors.orange[100]!, Colors.orange[300]!], // Intuitive "Offer" color
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(2, 4), // Subtle shadow for depth
                                    ),
                                  ],
                                ),
                                child: selectedTask != null
                                    ? Cards(
                                        thisTask: Future.value(selectedTask!.task),
                                        sState: SmallState.info,
                                        bState: BigState.info,
                                        size: Size.small,
                                        heightBig: 200, // Adjusted heightBig
                                      )
                                    : Center(
                                        child: Text(
                                          "No card selected",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54, // Better contrast for readability
                                            fontWeight: FontWeight.w600, // Slightly bold for emphasis
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Card Selection Scroll View
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  Expanded(
                                    child: FutureBuilder<List<AssignedTask>>(
                                      future: _myAssignedTasksFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
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
                                                      if (selectedTask == task) {
                                                        selectedTask = null; // Deselect the card
                                                      } else {
                                                        selectedTask = task; // Select the card
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 140, // Fixed width for aspect ratio
                                                    height: 200, // Fixed height for aspect ratio
                                                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: selectedTask == task ? Colors.teal : Colors.transparent,
                                                        width: 2,
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Cards(
                                                      thisTask: Future.value(task.task),
                                                      sState: SmallState.info,
                                                      bState: BigState.info,
                                                      size: Size.small,
                                                      heightBig: 200,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.cancel, color: Colors.white),
                              label: Text("Cancel"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.redAccent,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                textStyle: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: ElevatedButton.icon(
                              onPressed: selectedTask != null
                                  ? () {
                                      // Confirm trade logic here
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Trade proposed with task: ${selectedTask!.task.name}"),
                                        ),
                                      );
                                    }
                                  : null, // Disable when no card is selected
                              icon: Icon(Icons.check_circle, color: Colors.white),
                              label: Text("Confirm"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTask != null ? Colors.teal : Colors.grey, // Grey if disabled
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                textStyle: TextStyle(fontSize: 12),
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

  void _showConfirmationDialog(BuildContext context, AssignedTask assignedTask) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Action"),
          content: Text(
            "Are you sure you want to finish the task '${assignedTask.task.name}' "
            "from ${assignedTask.user.name} that is due on ${assignedTask.dueDate.toLocal().toString().split(' ')[0]}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await assignedTask.setUser(currUser);
                  setState(() {
                    _fetchMyAssignedTasks();
                    if (_selectedUserId != null) {
                      _fetchSelectedUserAssignedTasks(_selectedUserId!);
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Task '${assignedTask.task.name}' is now your responsibility."),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to update task: ${e.toString()}"),
                    ),
                  );
                }
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortAndFilterOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _rotateSortOption, // Rotate through sort options
            ),
            Text("Sort by $_sortOption"),
          ],
        ),
        DropdownButton<String>(
          value: _selectedCategory == null ? "No Filter" : _selectedCategory!.name, // Set default value if no category is selected
          hint: const Text("Filter by Category"),
          items: [
            const DropdownMenuItem<String>(
              value: "No Filter", // Special value to represent no filter
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
                _selectedCategory = null; // Reset the filter
              } else {
                _selectedCategory = Category.values.firstWhere((category) => category.name == value);
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

    print(_selectedCategory);

    // Apply Sorting
    tasks.sort((a, b) {
      switch (_sortOption) {
        case "Date":
          return a.dueDate.compareTo(b.dueDate);
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
            const Text(
              "Tasks Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.assignment_outlined), text: "My Tasks"),
                Tab(icon: Icon(Icons.group_outlined), text: "Others' Tasks"),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // My Tasks Tab
                  Column(
                    children: [
                      // Sort and Filter Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.sort),
                                onPressed: _rotateSortOption, // Rotate through sort options
                              ),
                              Text("Sort by $_sortOption"),
                            ],
                          ),
                          DropdownButton<String>(
                            value: _selectedCategory == null ? "No Filter" : _selectedCategory!.name,
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
                                  _selectedCategory = null; // Reset the filter
                                } else {
                                  _selectedCategory = Category.values.firstWhere((category) => category.name == value);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tasks GridView
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

                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 4); // Min 2, Max 4 columns
                                  final aspectRatio = 140 / 200; // Maintain the card's aspect ratio

                                  return GridView.builder(
                                    padding: const EdgeInsets.all(8.0),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16.0,
                                      mainAxisSpacing: 16.0,
                                      childAspectRatio: aspectRatio,
                                    ),
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];
                                      return GestureDetector(
                                        onTap: () => _showYourTaskAction(context, task),
                                        child: Cards(
                                          thisTask: Future.value(task.task),
                                          sState: SmallState.info,
                                          bState: BigState.info,
                                          size: Size.small,
                                          heightBig: 200, // This height works with the aspect ratio
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
                  ),
                  // Others' Tasks Tab
                  Column(
                    children: [
                      // User Selection Dropdown
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
                            return DropdownButton<int>(
                              value: _selectedUserId,
                              hint: const Text("Select a User"),
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
                      const SizedBox(height: 10),

                      // Sort and Filter Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.sort),
                                onPressed: _rotateSortOption, // Rotate through sort options
                              ),
                              Text("Sort by $_sortOption"),
                            ],
                          ),
                          DropdownButton<String>(
                            value: _selectedCategory == null ? "No Filter" : _selectedCategory!.name,
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
                                  _selectedCategory = null; // Reset the filter
                                } else {
                                  _selectedCategory = Category.values.firstWhere((category) => category.name == value);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tasks GridView or Placeholder
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
                                    return const Center(child: Text("No tasks assigned to this user."));
                                  } else {
                                    final tasks = _applySortingAndFiltering(snapshot.data!);
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        final crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 4); // Min 2, Max 4 columns
                                        final aspectRatio = 140 / 200; // Maintain card aspect ratio

                                        return GridView.builder(
                                          padding: const EdgeInsets.all(8.0),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 16.0,
                                            mainAxisSpacing: 16.0,
                                            childAspectRatio: aspectRatio,
                                          ),
                                          itemCount: tasks.length,
                                          itemBuilder: (context, index) {
                                            final task = tasks[index];
                                            return GestureDetector(
                                              onTap: () => _showOthersTaskAction(context, task),
                                              child: Cards(
                                                thisTask: Future.value(task.task),
                                                sState: SmallState.info,
                                                bState: BigState.info,
                                                size: Size.small,
                                                heightBig: 200, // This height works with the aspect ratio
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
