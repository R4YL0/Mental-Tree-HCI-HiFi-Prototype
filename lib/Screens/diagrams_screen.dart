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
        padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              const DiagramBox(title: "Task History"),
              const SizedBox(height: 10,),
              const DiagramBox(title: "Completed Tasks"),
              const SizedBox(height: 10,),
            ],
          ),
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
            const SizedBox(height: 10,),
            if(title == "Task History")
              const TaskHistory()
            else if(title == "Completed Tasks")
              const CompletedTasks()
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

class TaskHistory extends StatefulWidget {
  const TaskHistory({super.key});

  @override
  State<TaskHistory> createState() => _TaskHistoryState();
}

class _TaskHistoryState extends State<TaskHistory> {
  List<AssignedTask> completedTasks = [];

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
    return Column(
      children: [
        for(int i = 0;i<completedTasks.length;i++)
          TaskBox(task: completedTasks[i].task.name, category: "category", person: completedTasks[i].user.userName,),
      ],
    );
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
      activeCurves = List.filled(length, false);
    });
  }

  _setNewCurveBoolean(bool newValue, int index){
    setState(() {
      activeCurves[index] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompletedTasksDiagram(activeCurves: activeCurves, users: users),
        CompletedTasksLegend(activeCurves: activeCurves, users: users, tapped: (bool newValue, int index){_setNewCurveBoolean(newValue, index);},),
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
  final Map<String, List<_CompletedTask>> data = {"abc": [_CompletedTask(0,3), _CompletedTask(1, 5)]};

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks();
    print(completedTasks.length);

    for(int i=0;i<completedTasks.length;i++){
      int differenceInDays = DateTime.now().difference(completedTasks[i].finishDate!).inDays;
      String user = completedTasks[i].user.userName;
      _CompletedTask tmp = _CompletedTask(differenceInDays, 1);
      if(data.keys.contains(user)){
        bool entryExists = false;
        for (var entry in data[user]!) {
          if (entry.daysAgo == differenceInDays) {
            entry.number += 1;
            entryExists = true;
            break;
          }
        }
        if(!entryExists){
          data[user]!.add(tmp);
        }
      }else{
       data[user] = [tmp];
      }

      setState(() {
        data.forEach((user, taskList) {
          print('User: $user');
          taskList.forEach((task) {
            print('  Days Ago: ${task.daysAgo}, Tasks: ${task.number}');
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: const NumericAxis(title: AxisTitle(text: "..days ago", textStyle: TextStyle(fontSize: 12)), minimum: 0, maximum: 20,),
      primaryYAxis: const NumericAxis(title: AxisTitle(text: "Tasks", textStyle: TextStyle(fontSize: 12)), minimum: 0, maximum: 10,),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<_CompletedTask, int>>[
        for(var person in data.entries)
          for(int i=0;i<widget.users.length;i++)
            if(widget.users[i].userName == person.key && widget.activeCurves[i])
              LineSeries<_CompletedTask, int>(
                dataSource: person.value,
                xValueMapper: (_CompletedTask data, _) => data.daysAgo,
                yValueMapper: (_CompletedTask data, _) => data.number,
                name: person.key,
                color: Colors.blue,
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
          Person(isActive: widget.activeCurves[i], name: widget.users[i].userName, tapped: (bool newValue){widget.tapped(newValue, i);},),
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
            Text(name, style: TextStyle(fontSize: 12),),
            const Spacer(),
          ],
        ),
    );
  }
}