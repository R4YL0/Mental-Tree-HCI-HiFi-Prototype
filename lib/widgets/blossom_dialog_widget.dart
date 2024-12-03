import 'package:flutter/material.dart';
import 'package:mental_load/Screens/assigned_tasks_screen.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/constants/strings.dart';
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
      insetPadding: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryChartWidget(category: widget.category, completed: testVersion == "A"),
            CategoryListWidget(category: widget.category),
          ],
        ),
      ),
    );
  }
}

class CategoryChartWidget extends StatefulWidget {
  final Category category;
  final bool completed;
  const CategoryChartWidget(
      {super.key, required this.category, required this.completed});

  @override
  State<CategoryChartWidget> createState() => _CategoryChartWidgetState();
}

class _CategoryChartWidgetState extends State<CategoryChartWidget> {
  List<User> users = [];
  List<_CategoryCount> chartData = [];
  List<_CategoryCount> chartData2 = [];

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    users = await DBHandler().getUsers();
    final Map<Category, List<AssignedTask>>
        allAssignedTasks; // not really all, depends on variable if completed or not
    final Map<Category, List<AssignedTask>>
        openAssignedTasks;

    allAssignedTasks =
        await AssignedTask.getAssignedAndCompletedTasksDictionary();
    final allCategoryAssignedTasks = allAssignedTasks[widget.category];
    if (allCategoryAssignedTasks != null)
      // ignore: curly_braces_in_flow_control_structures
      for (AssignedTask aTask in allCategoryAssignedTasks) {
        bool entryExists = false;
        for (_CategoryCount catCount in chartData) {
          if (catCount.userId == aTask.user.userId &&
              catCount.category == aTask.task.category.name) {
            catCount.count += 1;
            entryExists = true;
          }
        }
        if (entryExists == false) {
          chartData.add(
              _CategoryCount(aTask.task.category.name, 1, aTask.user.userId));
        }
      }
    chartData.sort((a, b) => a.category.compareTo(b.category));
    //if (!widget.completed) {
      openAssignedTasks =
          await AssignedTask.getAssignedButNotCompletedTasksDictionary();
      final openCategoryAssignedTasks = openAssignedTasks[widget.category];
      if (openCategoryAssignedTasks != null)
        // ignore: curly_braces_in_flow_control_structures
        for (AssignedTask aTask in openCategoryAssignedTasks) {
          bool entryExists = false;
          for (_CategoryCount catCount in chartData2) {
            if (catCount.userId == aTask.user.userId &&
                catCount.category == aTask.task.category.name) {
              catCount.count += 1;
              entryExists = true;
            }
          }
          if (entryExists == false) {
            chartData2.add(
                _CategoryCount(aTask.task.category.name, 1, aTask.user.userId));
          }
        }
      chartData2.sort((a, b) => a.category.compareTo(b.category));
    //}
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double maxOpen = 0;
    for(int i = 0; i < chartData2.length; i++) {
      maxOpen = (maxOpen < chartData2[i].count.toDouble() ? chartData2[i].count.toDouble() : maxOpen);
    }
    maxOpen = maxOpen < 5 ? 5 : maxOpen;
    double maxAll = 0;
    for(int i = 0; i < chartData.length; i++) {
      maxAll = (maxAll < chartData[i].count.toDouble() ? chartData[i].count.toDouble() : maxAll);
    }
    maxAll = maxAll < 10 ? 10 : maxAll;
    maxOpen = maxOpen < 5 ? 5 : maxOpen;
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        title: AxisTitle(text: "Category", textStyle: TextStyle(fontSize: 12)),
        labelStyle: TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: "Tasks Last 30 Days", textStyle: TextStyle(fontSize: 12)),
        minimum: 0,
        maximum: maxAll,
      ),
      legend: const Legend(isVisible: true),
      axes: [
        if(!widget.completed)
          NumericAxis(
          title: const AxisTitle(text: "Tasks Open", textStyle: TextStyle(fontSize: 12)),
          opposedPosition: true,
          minimum: 0,
          maximum: maxOpen,
          )
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        for (User tmpUser in users)
          ColumnSeries<_CategoryCount, String>(
            dataSource: chartData
                .where((data) => data.userId == tmpUser.userId)
                .toList(),
            xValueMapper: (_CategoryCount data, _) => data.category,
            yValueMapper: (_CategoryCount data, _) => data.count,
            name: tmpUser.name,
            color: tmpUser.flowerColor,
          ),
        if(!widget.completed)
          for (User tmpUser in users)
            ColumnSeries<_CategoryCount, String>(
              dataSource: chartData2
                  .where((data) => data.userId == tmpUser.userId)
                  .toList(),
              xValueMapper: (_CategoryCount data, _) => data.category,
              yValueMapper: (_CategoryCount data, _) => data.count*maxAll/maxOpen,
              name: tmpUser.name.substring(0,1),
              color: tmpUser.flowerColor,
              borderColor: Colors.black,
            ),
      ],
    );
  }
}

class _CategoryCount {
  final String category;
  int count;
  final int userId;

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
        Text("You can click on a name to deactivate its data!",
            style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class CategoryListWidget extends StatefulWidget {
  final Category category;

  const CategoryListWidget({super.key, required this.category});

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
    int? curUserId = prefs.getInt(constCurrentUserId);
    if (curUserId != null) {
      User? newCurrUser = await DBHandler().getUserByUserId(curUserId);
      if (newCurrUser != null) setState(() => currUser = newCurrUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<Category, List<AssignedTask>>>(
        future: AssignedTask.getAssignedButNotCompletedTasksDictionary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            final Map<Category, List<AssignedTask>> assignedTasks =
                snapshot.data ?? {};
            final List<AssignedTask> categoryAssignedTasks =
                assignedTasks[widget.category] ?? [];

            return ListView.separated(
                shrinkWrap: true,
                itemCount: categoryAssignedTasks.length,
                itemBuilder: (context, index) {
                  AssignedTask curTask = categoryAssignedTasks[index];

                  return ListTile(
                    title: Text(curTask.task.name),
                    tileColor: curTask.user.flowerColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: AppColors.primary.withOpacity(0.2), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    trailing: Icon(Icons.help),
                    onTap: () {
                      showOthersTaskAction(context, curTask, currUser, () {
                        setState(() {});
                      });
                    },
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                      height: 5,
                    ));
          }
        });
  }
}
