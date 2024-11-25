import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DiagramsScreen extends StatelessWidget {
  const DiagramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, right: 10, left: 10),
        child: const Column(
          children: [
            Text("Completed Tasks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DiagramBox(title: "Distribution"),
                    SizedBox(height: 10,),
                    DiagramBox(title: "Last 20 days"),
                    SizedBox(height: 10,),
                    DiagramBox(title: "By Category"),
                    SizedBox(height: 10,),
                    DiagramBox(title: "History"),
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiagramBox extends StatelessWidget {
  final String title;
  const DiagramBox({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiagramTitle(text: title,),
            if(title == "Distribution")
              const PieChart()
            else if(title == "History")
              const TaskHistory()
            else if(title == "Last 20 days")
              const CompletedTasks()
            else if(title == "By Category")
              const CategoryBarChart()
          ],
        ),
      ),
    );
  }
}

class DiagramTitle extends StatelessWidget {
  final String text;
  const DiagramTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),);
  }
}

class PieChart extends StatelessWidget {
  const PieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PieChartDiagram(),
        Info(),
      ],
    );
  }
}

class PieChartDiagram extends StatefulWidget {
  const PieChartDiagram({super.key});

  @override
  State<PieChartDiagram> createState() => _PieChartDiagramState();
}

class _PieChartDiagramState extends State<PieChartDiagram> {
  List<_PieChartData> pieData = [];
  int totalTasks = 0;

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks();
    for(AssignedTask assTask in completedTasks){
      bool entryExists = false;
      for(_PieChartData pD in pieData){
        if(assTask.user.userId == pD.user.userId){
          pD.taskCount += 1;
          totalTasks += 1;
          entryExists = true;
        }
      }
      if(entryExists == false){
        pieData.add(_PieChartData(assTask.user, 1));
        totalTasks += 1;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: const Legend(
        isVisible: true, 
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<_PieChartData, String>(
          dataSource: pieData,
          xValueMapper: (_PieChartData data, _) => data.user.name,
          yValueMapper: (_PieChartData data, _) => data.taskCount,
          pointColorMapper: (_PieChartData data, _) => data.user.flowerColor,
          dataLabelMapper: (_PieChartData data, _) => "${data.taskCount.toString()} Tasks",
          dataLabelSettings: const DataLabelSettings(isVisible: true,),
          enableTooltip: true,
        ),
      ],
    );
  }
}

class _PieChartData {
  final User user;
  int taskCount;

  _PieChartData(this.user, this.taskCount);
}

class TaskHistory extends StatefulWidget {
  const TaskHistory({super.key});

  @override
  State<TaskHistory> createState() => _TaskHistoryState();
}

class _TaskHistoryState extends State<TaskHistory> {
  List<AssignedTask> completedTasks = [];
  bool showAllEntries = false;

@override
  void initState() {
    super.initState();
    myInit();
  }

  myInit() async {
    completedTasks = await AssignedTask.getCompletedTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<AssignedTask> completedTasksRev = completedTasks.reversed.toList();
    return Column(
      children: [
        for(int i = 0;i<completedTasksRev.length;i++)
          if(showAllEntries || i<10)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateBox(lasttask: i > 0 ? completedTasksRev[i-1] : null, task: completedTasksRev[i]),
                TaskBox(task: completedTasksRev[i].task.name, category: completedTasksRev[i].task.category.name, person: completedTasksRev[i].user.name,),
              ],
            ),
        ShowMoreLess(showAllEntries: showAllEntries, onTap: () {setState(() {showAllEntries = !showAllEntries;});},),
      ],
    );
  }
}

class DateBox extends StatelessWidget {
  final AssignedTask? lasttask;
  final AssignedTask task;
  const DateBox({super.key, required this.lasttask, required this.task});

  @override
  Widget build(BuildContext context) {
    if(lasttask != null && lasttask?.finishDate == task.finishDate){
      return const SizedBox();
    }else {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          task.finishDate != null
          ? "${task.finishDate!.year}-${task.finishDate!.month.toString().padLeft(2, '0')}-${task.finishDate!.day.toString().padLeft(2, '0')}"
          : "0000-00-00",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}

class TaskBox extends StatelessWidget {
  final String task;
  final String category;
  final String person;
  const TaskBox({super.key, required this.task, required this.category, required this.person});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(task, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 5,),
        Text(category, style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.6),),),
        const Spacer(),
        Text("done by ", style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.6),)),
        Text(person, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class ShowMoreLess extends StatefulWidget {
  final bool showAllEntries;
  final Function () onTap;
  const ShowMoreLess({super.key, required this.showAllEntries, required this.onTap});

  @override
  State<ShowMoreLess> createState() => _ShowMoreLessState();
}

class _ShowMoreLessState extends State<ShowMoreLess> {
  late bool showAllEntries;
  
@override
  void initState() {
    super.initState();
    showAllEntries = widget.showAllEntries;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){widget.onTap(); setState(() {showAllEntries = !showAllEntries;});},
        child: Center(child: Text(widget.showAllEntries? "show less" : "show more", style: const TextStyle(fontSize: 12)))
      ),
    );
  }
}

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  List<bool> activeCurves = [];
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    users = await DBHandler().getUsers();
    int length = users.length;
    setState(() {
      activeCurves = List.filled(length, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompletedTasksDiagram(activeCurves: activeCurves, users: users),
        const Info(),
        //CompletedTasksLegend(activeCurves: activeCurves, users: users, tapped: (bool newValue, int index){_setNewCurveBoolean(newValue, index);},),
      ],
    );
  }
}

class CompletedTasksDiagram extends StatefulWidget {
  final List<bool> activeCurves;
  final List<User> users;
  const CompletedTasksDiagram({super.key, required this.activeCurves, required this.users});

  @override
  State<CompletedTasksDiagram> createState() => _CompletedTasksDiagramState();
}

class _CompletedTasksDiagramState extends State<CompletedTasksDiagram> {
  //final List<_CompletedTask> completedTasks = [_CompletedTask(0,3), _CompletedTask(1, 5), _CompletedTask(2,1),_CompletedTask(3,7),_CompletedTask(4,4),_CompletedTask(5,2),_CompletedTask(6,3),];
  final Map<User, List<_CompletedTask>> data = {};

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  void _myInit() async {
    List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks();
    /*print("length ${completedTasks.length}");*/

    for(int i=0;i<completedTasks.length;i++){
      int differenceInDays = DateTime.now().difference(completedTasks[i].finishDate!).inDays;
      User user = completedTasks[i].user;
      _CompletedTask tmp = _CompletedTask(differenceInDays, 1);
      if(data.keys.any((tmpUser) => tmpUser.userId == user.userId)){
        bool entryExists = false;
        User? userWithId = data.keys.firstWhere((tmpUser) => tmpUser.userId == user.userId);
        for (var entry in data[userWithId]!) {
          if (entry.daysAgo == differenceInDays) {
            entry.number += 1;
            entryExists = true;
            break;
          }
        }
        if(!entryExists){
          data[userWithId]!.add(tmp);
        }
      }else{
       data[user] = [tmp];
      }

      setState(() {
        /*data.forEach((user, taskList) {
          print('User: $user');
          taskList.forEach((task) {
            print('  Days Ago: ${task.daysAgo}, Tasks: ${task.number}');
          });
        });*/
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: const NumericAxis(title: AxisTitle(text: "..days ago", textStyle: TextStyle(fontSize: 12)), minimum: 0, maximum: 20,),
      primaryYAxis: const NumericAxis(title: AxisTitle(text: "Tasks", textStyle: TextStyle(fontSize: 12)), minimum: 0, maximum: 10,),
      legend: const Legend(isVisible: true,),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<_CompletedTask, int>>[
        for(var person in data.entries)
          LineSeries<_CompletedTask, int>(
            dataSource: person.value,
            xValueMapper: (_CompletedTask data, _) => data.daysAgo,
            yValueMapper: (_CompletedTask data, _) => data.number,
            name: person.key.name,
            color: person.key.flowerColor,
          ),   
      ]
    );
  }
}

class _CompletedTask{
  _CompletedTask(this.daysAgo, this.number);

  final int daysAgo;
  int number;
}

class CompletedTasksLegend extends StatefulWidget {
  final List<bool> activeCurves;
  final List<User> users;
  final Function(bool newValue, int index) tapped;
  const CompletedTasksLegend({super.key, required this.activeCurves, required this.users, required this.tapped});

  @override
  State<CompletedTasksLegend> createState() => _CompletedTasksLegendState();
}

class _CompletedTasksLegendState extends State<CompletedTasksLegend> {

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for(int i=0; i<widget.activeCurves.length;i++)
          Person(isActive: widget.activeCurves[i], name: widget.users[i].name, tapped: (bool newValue){widget.tapped(newValue, i);},),
      ],
    );
  }
}

class Person extends StatelessWidget {
  final bool isActive;
  final String name;
  final Function(bool newValue) tapped;
  const Person({super.key, required this.isActive, required this.name, required this.tapped});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Row(
          children: [
            Transform.scale(scale: 0.8, child: Checkbox(value: isActive, onChanged: (bool? value){tapped(value?? false);})),
            Text(name, style: const TextStyle(fontSize: 12),),
            const Spacer(),
          ],
        ),
    );
  }
}

class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CategoryBarChartDiagram(),
        Info(),
      ],
    );
  }
}


class CategoryBarChartDiagram extends StatefulWidget {
  const CategoryBarChartDiagram({super.key});

  @override
  State<CategoryBarChartDiagram> createState() => _CategoryBarChartDiagramState();
}

class _CategoryBarChartDiagramState extends State<CategoryBarChartDiagram> {
  List<User> users = [];
  List<_CategoryCount> chartData = [];

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    users = await DBHandler().getUsers();
    List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks();
    for(AssignedTask aTask in completedTasks){
      bool entryExists = false;
      for(_CategoryCount catCount in chartData){
        if(catCount.userId == aTask.user.userId && catCount.category == aTask.task.category.name){
          catCount.count += 1;
          entryExists = true;
        }
      }
      if(entryExists == false){
        chartData.add(_CategoryCount(aTask.task.category.name, 1, aTask.user.userId));
      }
    }
    chartData.sort((a, b) => a.category.compareTo(b.category));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(title: AxisTitle(text: "Category", textStyle: TextStyle(fontSize: 12)),labelStyle: TextStyle(fontSize: 10),),
      primaryYAxis: const NumericAxis(title: AxisTitle(text: "Tasks", textStyle: TextStyle(fontSize: 12)), minimum: 0, maximum: 20,),
      legend: const Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        for(User tmpUser in users)
          ColumnSeries<_CategoryCount, String>(
            dataSource: chartData.where((data) => data.userId == tmpUser.userId).toList(),
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
        Icon(Icons.lightbulb_outline, size: 16,),
        Text("You can click on a name to deactivate its data!", style: TextStyle(fontSize: 12)),
      ],
    );
  }
}