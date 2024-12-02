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
            CategoryChartWidget(category: widget.category, completed: true),
            if (testVersion == "A")
              CategoryChartWidget(category: widget.category, completed: false)
            else
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

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    users = await DBHandler().getUsers();
    final Map<Category, List<AssignedTask>>
        allAssignedTasks; // not really all, depends on variable if completed or not

    if (widget.completed) {
      allAssignedTasks =
          await AssignedTask.getAssignedAndCompletedTasksDictionary();
    } else {
      allAssignedTasks =
          await AssignedTask.getAssignedButNotCompletedTasksDictionary();
    }
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        title: AxisTitle(text: "Category", textStyle: TextStyle(fontSize: 12)),
        labelStyle: TextStyle(fontSize: 10),
      ),
      primaryYAxis: const NumericAxis(
        title: AxisTitle(text: "Tasks", textStyle: TextStyle(fontSize: 12)),
        minimum: 0,
        maximum: 20,
      ),
      legend: const Legend(isVisible: true),
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
