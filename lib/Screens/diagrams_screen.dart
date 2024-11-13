import 'package:flutter/material.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DiagramsScreen extends StatelessWidget {
  const DiagramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 10, right: 10, left: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DiagramBox(title: "Task History"),
              SizedBox(height: 10,),
              DiagramBox(title: "Completed Tasks"),
              SizedBox(height: 10,),
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

class TaskHistory extends StatelessWidget {
  const TaskHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TaskBox(task: "task", category: "category", person: "person",),
        TaskBox(task: "task", category: "category", person: "person",),
        TaskBox(task: "task", category: "category", person: "person",),
        TaskBox(task: "task", category: "category", person: "person",),
        TaskBox(task: "task", category: "category", person: "person",),
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
        Text(task, style: TextStyle(fontSize: 14)),
        const SizedBox(width: 5,),
        Text(category, style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.6),),),
        const Spacer(),
        Text("done by ", style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.6),)),
        Text(person, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class CompletedTasks extends StatelessWidget {

  const CompletedTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompletedTasksDiagram(),
        CompletedTasksLegend(),
      ],
    );
  }
}

class CompletedTasksDiagram extends StatefulWidget {
  const CompletedTasksDiagram({super.key});

  @override
  State<CompletedTasksDiagram> createState() => _CompletedTasksDiagramState();
}

class _CompletedTasksDiagramState extends State<CompletedTasksDiagram> {
  final List<_CompletedTask> completedTasks = [_CompletedTask(0,3), _CompletedTask(1, 5), _CompletedTask(2,1),_CompletedTask(3,7),_CompletedTask(4,4),_CompletedTask(5,2),_CompletedTask(6,3),];
  final List<_CompletedTask> completedTasks2 = [_CompletedTask(0,2), _CompletedTask(1, 1), _CompletedTask(2,5),_CompletedTask(3,0),_CompletedTask(4,3),_CompletedTask(5,1),_CompletedTask(6,6),];
  final List<_CompletedTask> completedTasks3 = [_CompletedTask(0,1), _CompletedTask(1, 4), _CompletedTask(2,2),_CompletedTask(3,3),_CompletedTask(4,1),_CompletedTask(5,3),_CompletedTask(6,3),];
  final List<_CompletedTask> completedTasks4 = [_CompletedTask(0,0), _CompletedTask(1, 8), _CompletedTask(2,1),_CompletedTask(3,2),_CompletedTask(4,5),_CompletedTask(5,2),_CompletedTask(6,1),];
  final List<_CompletedTask> completedTasks5 = [_CompletedTask(0,6), _CompletedTask(1, 2), _CompletedTask(2,0),_CompletedTask(3,0),_CompletedTask(4,2),_CompletedTask(5,1),_CompletedTask(6,2),];
  
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
          primaryXAxis: const CategoryAxis(title: AxisTitle(text: "..days ago", textStyle: TextStyle(fontSize: 12)), minimum: 0, maximum: 6,),
          primaryYAxis: const CategoryAxis(title: AxisTitle(text: "Tasks", textStyle: TextStyle(fontSize: 12)), minimum: 0, maximum: 8,),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <CartesianSeries<_CompletedTask, int>>[
            LineSeries<_CompletedTask, int>(
              dataSource: completedTasks,
              xValueMapper: (_CompletedTask data, _) => data.daysAgo,
              yValueMapper: (_CompletedTask data, _) => data.number,
              name: 'CompletedTasks1',
              color: Colors.blue,
            ),
            LineSeries<_CompletedTask, int>(
              dataSource: completedTasks2,
              xValueMapper: (_CompletedTask data, _) => data.daysAgo,
              yValueMapper: (_CompletedTask data, _) => data.number,
              name: 'CompletedTasks2',
              color: Colors.red,
            ),
            LineSeries<_CompletedTask, int>(
              dataSource: completedTasks3,
              xValueMapper: (_CompletedTask data, _) => data.daysAgo,
              yValueMapper: (_CompletedTask data, _) => data.number,
              name: 'CompletedTasks3',
              color: Colors.green,
            ),
            LineSeries<_CompletedTask, int>(
              dataSource: completedTasks4,
              xValueMapper: (_CompletedTask data, _) => data.daysAgo,
              yValueMapper: (_CompletedTask data, _) => data.number,
              name: 'CompletedTasks4',
              color: Colors.purple,
            ),
            LineSeries<_CompletedTask, int>(
              dataSource: completedTasks5,
              xValueMapper: (_CompletedTask data, _) => data.daysAgo,
              yValueMapper: (_CompletedTask data, _) => data.number,
              name: 'CompletedTasks5',
              color: Colors.orange,
            ),
          ]
        );
  }
}

class _CompletedTask{
  _CompletedTask(this.daysAgo, this.number);

  final int daysAgo;
  final int number;
}

class CompletedTasksLegend extends StatelessWidget {
  const CompletedTasksLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      children: [
        Person(),
        Person(),
        Person(),
        Person(),
        Person(),
      ],
    );
  }
}

class Person extends StatelessWidget {
  const Person({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        child: Row(
          children: [
            Transform.scale(scale: 0.8, child: Checkbox(value: false, onChanged: (bool? value){})),
            const Text("Person", style: TextStyle(fontSize: 12),),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}