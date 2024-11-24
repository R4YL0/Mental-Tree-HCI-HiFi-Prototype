import 'package:flutter/material.dart';
import 'package:mental_load/classes/Task.dart';

class CardBig extends StatefulWidget {
  final Future<Task> thisTask;
  const CardBig({ super.key, required this.thisTask});
  @override
  State<CardBig> createState() => _CardBig();  
}

class _CardBig extends State<CardBig> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task>(future: widget.thisTask, builder:(context, snapshot) {if(snapshot.hasData) {return
    Card(child: SizedBox(
        width: 350,
        height: 500,
        child: Stack(children: <Widget> [
          name(snapshot.requireData.name),
          Align(alignment: Alignment(0.8, -0.9) , child: Text(snapshot.requireData.category.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
            Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
            Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),),
          Align(alignment: Alignment(0, -0.51) , child: ColoredBox(color:Color.fromARGB(255, 254, 213, 182),child: SizedBox(width:326, height: 208,),),),
          Align(alignment: Alignment(0, -0.5) , child: Image.memory(snapshot.requireData.img, width: 320, height: 200, fit: BoxFit.cover),),
        ],)
      ),
    );}else{return Text("No Data Fetched");
    }});
  }

  Widget name(String name) {
    if(name.length>18 && name.substring(18,19) != ' ') {
      return Stack(children: <Widget> [
          Align(alignment: Alignment(-0.90, -0.9) , child: Text("${name.substring(0,18)}-", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),),),
          Align(alignment: Alignment(-0.86, -0.82) , child: Text(name.substring(18), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),)
          ,]
      );
    }
    else if(name.length>18) {
      return Stack(children: <Widget> [
          Align(alignment: Alignment(-0.90, -0.9) , child: Text(name.substring(0,18), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),),),
          Align(alignment: Alignment(-0.86, -0.82) , child: Text(name.substring(18), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),)
          ,]
      );
    }
    else {
      return Align(alignment: Alignment(-0.90, -0.9) , child: Text(name, style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),);
    }
  }
}
          /*Align(alignment: Alignment(-0.90, -0.9) , child: Text("Task Name", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),),),
          Align(alignment: Alignment(-0.86, -0.82) , child: Text("Example if Long", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),*/