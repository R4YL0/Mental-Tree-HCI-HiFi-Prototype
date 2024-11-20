import 'package:flutter/material.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/classes/Task.dart';


class CardsMini extends StatefulWidget {
  final Future<Task> thisTask;
  const CardsMini({ super.key, required this.thisTask});
  @override
  State<CardsMini> createState() => _CardsMini();
}

class CardsBig extends StatefulWidget {
  final Future<Task> thisTask;
  const CardsBig({ super.key, required this.thisTask});
  @override
  State<CardsBig> createState() => _CardsBig();  
}

class _CardsMini extends State<CardsMini> {
  int state = 0;
  
  Widget changeButtons() {
    if (state == 0) {
      return editButtons();
    } else if (state == 1) {
      return toDoButtons();
    } else {
      return doneButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Task>(future: widget.thisTask, builder:(context, snapshot) {if(snapshot.hasData) {return
    Card(
      child: SizedBox(
        width: 140,
        height: 200,
        child: Stack(children: <Widget>[
          name(snapshot.requireData.name),
          Align(alignment: Alignment(0.75, -0.88) , child: Text(snapshot.requireData.category.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
            Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
            Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(0.65),),),
          Align(alignment: Alignment(-0.34, -0.417) , child: ColoredBox(color:Color.fromARGB(255, 254, 213, 182),child: SizedBox(width:130, height: 85,),),),
          Align(alignment: Alignment(-0.22, -0.4) , child: Image(image: AssetImage(snapshot.requireData.imgDst), width:122),),
          Align(alignment: Alignment(-0.88, 0.35) , child: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.6),),),
          Align(alignment: Alignment(0.75, 0.35) , child: Text("${snapshot.requireData.priority}/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.7),),),
          Align(alignment: Alignment(-0.88, 0.5) , child: Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.6),),),
          Align(alignment: Alignment(0.75, 0.5) , child: Text("${snapshot.requireData.difficulty}/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.7),),),
          changeButtons(),
        ],)
      ),
    );}else{return Text("No Data Fetched");}});
  }

  Widget editButtons() {
    return Stack(children: <Widget> [
      Align(alignment: Alignment(-1, 1), child: MaterialButton(disabledColor: AppColors.secondary, focusColor: Colors.red, textColor: Colors.black, shape: CircleBorder(),height: 35, minWidth: 0, onPressed: null, child: Text("Info", textScaler: TextScaler.linear(0.6),),),),
      Align(alignment: Alignment(0.85, 0.92), child: SizedBox(height:35, width: 80, child:TextButton(style: TextButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => setState(() { state = 1; }), child: Text("Edit", textScaler: TextScaler.linear(0.7), style: TextStyle(color: Colors.black)),),),),
    ],);
  }

  Widget toDoButtons() {
    return Stack(children: <Widget> [
      Align(alignment: Alignment(-1, 1), child: MaterialButton(disabledColor: AppColors.secondary, focusColor: Colors.red, textColor: Colors.black, shape: CircleBorder(),height: 35, minWidth: 0, onPressed: null, child: Text("Info", textScaler: TextScaler.linear(0.6),),),),
      Align(alignment: Alignment(0.85, 0.92), child: SizedBox(height:35, width: 80, child:TextButton(style: TextButton.styleFrom(backgroundColor: AppColors.attention), onPressed: () => setState(() { state = 2; }), child: Text("To Do", textScaler: TextScaler.linear(0.7), style: TextStyle(color: Colors.black)),),),),
    ],);
  }

  Widget doneButton() {
    return Stack(children: <Widget> [
      Align(alignment: Alignment(0.0, 0.92), child: SizedBox(height:35, width: 130, child:TextButton(style: TextButton.styleFrom(backgroundColor: AppColors.success), onPressed: () => setState(() { state = 0; }), child: Text("Done", textScaler: TextScaler.linear(0.7), style: TextStyle(color: Colors.black)),),),),
    ],);
  }

  Widget name(String name) {
    if(name.length>10 && name.substring(10,11) != ' ') {
      return Stack(children: <Widget> [
          Align(alignment: Alignment(-0.90, -0.9) , child: Text("${name.substring(0,10)}-", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),),
          Align(alignment: Alignment(-0.7, -0.75) , child: Text(name.substring(10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.5),),)
          ,]
      );
    }
    else if(name.length>10) {
      return Stack(children: <Widget> [
          Align(alignment: Alignment(-0.90, -0.9) , child: Text(name.substring(0,10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),),
          Align(alignment: Alignment(-0.7, -0.75) , child: Text(name.substring(10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.5),),)
          ,]
      );
    }
    else {
      return Align(alignment: Alignment(-0.90, -0.9) , child: Text(name, style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),);
    }
  }

  
}

class _CardsBig extends State<CardsBig> {

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
          Align(alignment: Alignment(0, -0.5) , child: Image(image: AssetImage(snapshot.requireData.imgDst), width:320, height: 200),),
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