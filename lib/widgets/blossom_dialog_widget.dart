import 'package:flutter/material.dart';
import 'package:mental_load/Screens/assigned_tasks_screen.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/widgets/cards_bottom_sheet.dart';
import 'package:mental_load/widgets/cards_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BlossomDialogWidget extends StatefulWidget {
  final Category category;

  const BlossomDialogWidget({super.key, required this.category});

  @override
  State<BlossomDialogWidget> createState() => _BlossomDialogWidgetState();
}

class _BlossomDialogWidgetState extends State<BlossomDialogWidget> {
  String testVersion = "A";

  @override
  void initState() {
    super.initState();
    _ownInitState();
  }

  void _ownInitState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      testVersion = prefs.getString(constTestVersion) ?? "A";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Updated Title
              Text(
                "${widget.category.name} Overview", // Dynamically set category name
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(thickness: 1.5, color: Colors.grey[300]),
              SizedBox(height: 8),

              // Reduced Chart Height
              SizedBox(
                height: 200, // Set a fixed height for the chart
                child: CategoryChartWidget(
                  category: widget.category,
                  completed: testVersion == "A",
                ),
              ),

              SizedBox(height: 8),

              // Subheading
              Text(
                "List of Open Tasks (Click to see the Task)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 80, 80, 80),
                ),
              ),

              SizedBox(height: 8),

              // Category List Widget
              Expanded(
                child: CategoryListWidget(
                  category: widget.category,
                ),
              ),

              SizedBox(height: 12),

              // Close Button
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryChartWidget extends StatefulWidget {
  final Category category;
  final bool completed;
  const CategoryChartWidget({
    super.key,
    required this.category,
    required this.completed,
  });

  @override
  State<CategoryChartWidget> createState() => _CategoryChartWidgetState();
}

class _CategoryChartWidgetState extends State<CategoryChartWidget> {
  List<User> users = [];
  List<_CategoryCount> chartData = [];
  List<_CategoryCount> chartData2 = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    users = await DBHandler().getUsers();
    final Map<Category, List<AssignedTask>> allAssignedTasks = await AssignedTask.getAssignedAndCompletedTasksDictionary();
    final Map<Category, List<AssignedTask>> openAssignedTasks = await DBHandler().getAssignedButNotCompletedTasksDictionary();

    final allCategoryAssignedTasks = allAssignedTasks[widget.category];
    if (allCategoryAssignedTasks != null) {
      for (AssignedTask aTask in allCategoryAssignedTasks) {
        if (aTask.finishDate != null && aTask.finishDate!.difference(DateTime.now()).inDays < 30) {
          _addOrUpdateChartData(chartData, aTask);
        }
      }
    }

    final openCategoryAssignedTasks = openAssignedTasks[widget.category];
    if (openCategoryAssignedTasks != null) {
      for (AssignedTask aTask in openCategoryAssignedTasks) {
        _addOrUpdateChartData(chartData2, aTask);
      }
    }

    setState(() {
      isLoading = false; // Data is ready
    });
  }

  void _addOrUpdateChartData(List<_CategoryCount> chartDataList, AssignedTask aTask) {
    bool entryExists = false;
    for (_CategoryCount catCount in chartDataList) {
      if (catCount.userId == aTask.user.userId && catCount.category == aTask.task.category.name) {
        catCount.count += 1;
        entryExists = true;
      }
    }
    if (!entryExists) {
      chartDataList.add(_CategoryCount(aTask.task.category.name, 1, aTask.user.userId));
    }
    chartDataList.sort((a, b) => a.category.compareTo(b.category));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator()); // Show a loading indicator
    }

    double maxAll = chartData.isNotEmpty ? chartData.map((data) => data.count).reduce((a, b) => a > b ? a : b).toDouble() : 0.0;

    double maxOpen = chartData2.isNotEmpty ? chartData2.map((data) => data.count).reduce((a, b) => a > b ? a : b).toDouble() : 0.0;

    return Row(
      children: [
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              title: AxisTitle(text: "Done Tasks", textStyle: TextStyle(fontSize: 12)),
              labelStyle: TextStyle(fontSize: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: maxAll,
              interval: 1,
            ),
            legend: const Legend(isVisible: true),
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              for (User tmpUser in users)
                ColumnSeries<_CategoryCount, String>(
                  dataSource: chartData.where((data) => data.userId == tmpUser.userId).toList(),
                  xValueMapper: (_CategoryCount data, _) => data.category,
                  yValueMapper: (_CategoryCount data, _) => data.count,
                  name: widget.completed ? tmpUser.name : tmpUser.name.substring(0, 1), // Full or abbreviated name
                  color: tmpUser.flowerColor, // User-specific color
                ),
            ],
          ),
        ),
        if (!widget.completed)
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(
                title: AxisTitle(text: "Open Tasks", textStyle: TextStyle(fontSize: 12)),
                labelStyle: TextStyle(fontSize: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: maxOpen,
                interval: 1,
                opposedPosition: true,
              ),
              legend: const Legend(isVisible: true),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                for (User tmpUser in users)
                  ColumnSeries<_CategoryCount, String>(
                    dataSource: chartData2.where((data) => data.userId == tmpUser.userId).toList(),
                    xValueMapper: (_CategoryCount data, _) => data.category,
                    yValueMapper: (_CategoryCount data, _) => data.count,
                    name: tmpUser.name.substring(0, 1), // Abbreviated name for open tasks
                    color: tmpUser.flowerColor, // User-specific color
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoryCount {
  final String category;
  int count;
  final String userId;

  _CategoryCount(this.category, this.count, this.userId);
}

class Info extends StatelessWidget {
  const Info({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: 16,
        ),
        Text("You can click on a name to deactivate its data!", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class CategoryListWidget extends StatefulWidget {
  final Category category;

  const CategoryListWidget({
    super.key,
    required this.category,
  });

  @override
  State<CategoryListWidget> createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  late User currUser;

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  void _myInit() async {
    final prefs = await SharedPreferences.getInstance();
    String? curUserId = prefs.getString(constCurrentUserId);
    if (curUserId != null) {
      User? newCurrUser = await DBHandler().getUserById(curUserId);
      if (newCurrUser != null) setState(() => currUser = newCurrUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<Category, List<AssignedTask>>>(
      future: DBHandler().getAssignedButNotCompletedTasksDictionary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          final Map<Category, List<AssignedTask>> assignedTasks = snapshot.data ?? {};
          final List<AssignedTask> categoryAssignedTasks = assignedTasks[widget.category] ?? [];

          if (categoryAssignedTasks.isNotEmpty) {
            // Separate tasks of the current user
            List<AssignedTask> currentUserTasks = categoryAssignedTasks.where((task) => task.user.userId == currUser.userId).toList();

            // Separate tasks of other users
            List<AssignedTask> otherUserTasks = categoryAssignedTasks.where((task) => task.user.userId != currUser.userId).toList();

            // Sort other user tasks alphabetically by user name
            otherUserTasks.sort((a, b) => a.user.name.compareTo(b.user.name));

            // Combine the sorted tasks
            categoryAssignedTasks
              ..clear()
              ..addAll(otherUserTasks)
              ..addAll(currentUserTasks); // Current user's tasks at the end
          }

          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 306),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: categoryAssignedTasks.length,
              itemBuilder: (context, index) {
                AssignedTask curTask = categoryAssignedTasks[index];

                return GestureDetector(
                  onTap: () {
                    if (curTask.user.userId == currUser.userId) {
                      showTaskBottomSheet(context: context, task: curTask, size: Size.big);
                    } else {
                      showOthersTaskAction(context, curTask, currUser, () {
                        setState(() {});
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8), // Added margin for better spacing
                    padding: const EdgeInsets.all(12), // Increased padding for a clean look
                    decoration: BoxDecoration(
                      color: curTask.user.flowerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2), // Shadow for card effect
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center alignment for better look
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: curTask.user.flowerColor,
                          child: Text(
                            curTask.user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12), // Adjusted spacing between avatar and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                curTask.task.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4), // Adjusted spacing between title and notes
                              Text(
                                curTask.task.notes,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10), // Increased spacing between items
            ),
          );
        }
      },
    );
  }
}
