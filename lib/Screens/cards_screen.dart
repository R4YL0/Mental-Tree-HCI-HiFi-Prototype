import 'package:flutter/material.dart';
import 'package:mental_load/constants/colors.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child:Cards(),),
    );
  }
}

class Cards extends StatefulWidget {
  const Cards({ super.key });

  @override
  State<Cards> createState() => _CardsMini();
}

class _CardsMini extends State<Cards> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 140,
        height: 200,
        child: Stack(children: <Widget> [
          Align(alignment: Alignment(-0.90, -0.9) , child: Text("Task Name", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),),
          Align(alignment: Alignment(-0.86, -0.77) , child: Text("Example if Long", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.55),),),
          Align(alignment: Alignment(0.75, -0.85) , child: Text("Category", style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
            Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
            Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(0.65),),),
          Align(alignment: Alignment(-0.34, -0.417) , child: ColoredBox(color:Color.fromARGB(255, 254, 213, 182),child: SizedBox(width:130, height: 85,),),),
          Align(alignment: Alignment(-0.22, -0.4) , child: Image(image: AssetImage('images/image1.png'), width:122),),
          Align(alignment: Alignment(-0.88, 0.35) , child: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.6),),),
          Align(alignment: Alignment(0.75, 0.35) , child: Text("3/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.7),),),
          Align(alignment: Alignment(-0.88, 0.5) , child: Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.6),),),
          Align(alignment: Alignment(0.75, 0.5) , child: Text("2/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.7),),),
          Align(alignment: Alignment(-0.9, 0.9), child: TextButton.styleFrom(backgroundColor: Colors.green), onPressed: null, child: Text("Info", textScaler: TextScaler.linear(0.6),),),),
          Align(alignment: Alignment(0.9, 0.9), child: SizedBox(height:35, width: 70, child:TextButton(style: TextButton.styleFrom(backgroundColor: Colors.yellow), onPressed: null, child: Text("Edit", textScaler: TextScaler.linear(0.7),),),),),
        ],)
      ),
    );
  }
}

class MyColor extends WidgetStateColor {
  const MyColor() : super(_defaultColor);

  static const int _defaultColor = 0xcafefeed;
  static const int _pressedColor = 0xdeadbeef;

  @override
  Color resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return const Color.fromARGB(222, 9, 56, 197);
    }
    return const Color.fromARGB(201, 196, 196, 41);
  }
}

class _CardsShow extends State<Cards> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: const SizedBox(
        width: 350,
        height: 500,
        child: Stack(children: <Widget> [
          Align(alignment: Alignment(-0.90, -0.9) , child: Text("Task Name", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),),),
          Align(alignment: Alignment(-0.86, -0.82) , child: Text("Example if Long", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
          Align(alignment: Alignment(0.8, -0.9) , child: Text("Categorys", style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
            Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
            Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),),
          Align(alignment: Alignment(0, -0.51) , child: ColoredBox(color:Color.fromARGB(255, 254, 213, 182),child: SizedBox(width:326, height: 208,),),),
          Align(alignment: Alignment(0, -0.5) , child: Image(image: AssetImage('images/image1.png'), width:320, height: 200),),
        ],)
      ),
    );
  }
}