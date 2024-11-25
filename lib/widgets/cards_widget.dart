import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Subtask.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum SmallState{info, edit, todo, done}
enum BigState{info, edit}
enum Size{small, big}
enum Section{general, subtasks, notes}

class Cards extends StatefulWidget {
  final Future<Task> thisTask;
  var sState = SmallState.edit;
  var bState = BigState.info;
  var size = Size.small;
  Cards({ super.key, required this.thisTask, required this.sState, this.size = Size.small, required this.bState});

  @override
  State<Cards> createState() => _Cards();

}

class _Cards extends State<Cards> {
  var oldState = SmallState.info;
  var subTaskIdx = 0;
  var assigned = DateTime.now();
  var section = Section.general;

  Widget buttons() {
    if (widget.sState == SmallState.edit) {
      return editButtons();
    } else if (widget.sState == SmallState.todo) {
      return toDoButtons();
    } else if (widget.sState == SmallState.done) {
      return doneButton();
    } else  {
      return infoButton();
    }
  }

  Widget sections(AsyncSnapshot<Task> s) {
    if (section == Section.general) {
      return general(s);
    } else if (section == Section.subtasks) {
      return subtasks(s);
    } else {
      return notes(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.size == Size.small) {
      return smallCard();
    } else {
      return bigCard();
    }
  }

  Widget smallCard() {
    return FutureBuilder<Task>(future: widget.thisTask, builder:(context, snapshot) {
      if(snapshot.hasData) {
        return Card(
          child: SizedBox(
            width: 140,
            height: 200,
            child: Stack(children: <Widget>[
              names(snapshot.requireData.name, Size.small/*,imgDst: snapshot.requireData.imgDst*/),
              Align(alignment: Alignment(0.75, -0.88) , child:
                Text(snapshot.requireData.category.name, style: TextStyle(fontWeight: FontWeight.bold, shadows: <Shadow>[
                  Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
                  Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
                ],
              ), textScaler: TextScaler.linear(0.65),),),
              Align(alignment: Alignment(-0.34, -0.417) , child:
                ColoredBox(color:Color.fromARGB(255, 254, 213, 182), child:
                  SizedBox(width:130, height: 85,),),),
              Align(alignment: Alignment(-0.22, -0.4) , child:
                Image.memory(snapshot.requireData.img, width:122, fit: BoxFit.cover),),
              Align(alignment: Alignment(-0.88, 0.35) , child:
                Text("Priority", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.6),),),
              Align(alignment: Alignment(0.75, 0.35) , child:
                Text("${snapshot.requireData.priority}/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.7),),),
              Align(alignment: Alignment(-0.88, 0.5) , child:
                Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.6),),),
              Align(alignment: Alignment(0.75, 0.5) , child:
                Text("${snapshot.requireData.difficulty}/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.7),),),
              buttons(),
            ],)
          ),
        );
      } else {
        return Text("No Data Fetched");
      }
    });
  }

  Widget bigCard() {
    if(widget.bState == BigState.info) {
      return bigInfo();
    } else {
      return bigEdit();
    }
  }

  Widget bigInfo() {
    return FutureBuilder<Task>(future: widget.thisTask, builder:(context, snapshot) {if(snapshot.hasData) {return
    Card(child: SizedBox(
        width: 350,
        height: 550,
        child: Stack(children: <Widget> [
          names(snapshot.requireData.name, Size.big/*, snapshot.requireData.imgDst*/),
          //Category
          Align(alignment: Alignment(0.65, -0.88) , child:
            Text(snapshot.requireData.category.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
              Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
              Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
            ],
          ), textScaler: TextScaler.linear(1.4),),),
          //Image and Border
          Align(alignment: Alignment(0, -0.61) , child:
            ColoredBox(color:Color.fromARGB(255, 254, 213, 182),child:
              SizedBox(width:326, height: 208,),),),
          Align(alignment: Alignment(0, -0.6) , child:
            Image.memory(snapshot.requireData.img, width:320, height: 200, fit: BoxFit.cover),),
          //Exit Button
          Align(alignment: Alignment(1, -1), child:
            IconButton(onPressed: () => setState((){widget.size = Size.small; section = Section.general;}), icon: Icon(Icons.close, color: AppColors.attention,))),
          sections(snapshot),
          ])
      ),
    );
    }else{
      return Text("No Data Fetched");
    }});
  }

  Widget bigEdit() {
    return FutureBuilder<Task>(future: widget.thisTask, builder:(context, snapshot) {if(snapshot.hasData) {return
    Card(child: SizedBox(
        width: 350,
        height: 550,
        child: Stack(children: <Widget> [
          //Change TaskName
          Align(alignment: Alignment(-0.8, -0.9) , child:
            ConstrainedBox(constraints: BoxConstraints(maxHeight: 50, maxWidth: 190), child: /*Row(children: <Widget>[*/
              EditableText(scrollPhysics: NeverScrollableScrollPhysics(), scrollPadding: EdgeInsets.all(0),
                controller: TextEditingController(text: snapshot.requireData.name), focusNode: FocusNode(), cursorColor: Colors.black, backgroundCursorColor: Colors.black,
                maxLines: 2, minLines: 2, textInputAction: TextInputAction.done,
                onSubmitted: (value) => setState(() {Task change = snapshot.requireData; change.name = value;}),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), textScaler: TextScaler.linear(1.4),),
              //Icon(Icons.edit, color: Colors.grey, size: 15,),
            /*]),*/)
          ),
          categoryMenu(snapshot),
          //Image
          Align(alignment: Alignment(0, -0.61) , child:
            ColoredBox(color:Color.fromARGB(255, 254, 213, 182),child: SizedBox(width:326, height: 208,),),),
          Align(alignment: Alignment(0, -0.6) , child:
            Image.memory(snapshot.requireData.img, width:320, height: 200, fit: BoxFit.cover),),
          sections(snapshot),
          Align(alignment: Alignment(1, -1), child:
            IconButton(onPressed: () => setState((){widget.size = Size.small; section = Section.general;}), icon:
              Icon(Icons.close, color: AppColors.attention,))
          ),
          Align(alignment: Alignment(0.9, -0.1), child:
            IconButton(onPressed: (){chooseImage(snapshot);}, icon:
              Icon(Icons.edit, color: Colors.white, shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2)],))
          ),
        ],)
      ),
    );
    }else{
      return Text("No Data Fetched");
    }});
  }

  void chooseImage(AsyncSnapshot<Task> s) async {
    final ImagePicker picker = ImagePicker();
    XFile image = await picker.pickImage(source: ImageSource.gallery) as XFile;
    setState((){s.requireData.img = File(image.path).readAsBytesSync();});
  }

  Widget general(AsyncSnapshot<Task> s) {
    if(widget.bState == BigState.info) {
      return Stack(children: <Widget> [
        Align(alignment: Alignment(-0.88, 0.07) , child:
          Text("General", textScaler: TextScaler.linear(1.1),),),
        Align(alignment: Alignment(-0.88, 0.15) , child:
          Text("Priority", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
        Align(alignment: Alignment(-0.35, 0.18) , child:
          Text("${s.requireData.priority}/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.9),),),
        Align(alignment: Alignment(0.45, 0.15) , child:
          Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
        Align(alignment: Alignment(0.88, 0.18) , child:
          Text("${s.requireData.difficulty}/5", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.9),),),
        Align(alignment: Alignment(-0.9, 0.27) , child:
          Text("Due", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
        Align(alignment: Alignment(0.2, 0.4) , child:
          Text(dueDate(s.requireData.frequency), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(2.2),),),
        Align(alignment: Alignment(-0.88, 0.55) , child:
          Text("Next Subtask", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
        findSubtask(s.requireData.subtasks),
        Align(alignment: Alignment(-0.7, 1), child:
          TextButton.icon(onPressed: () => setState((){section = Section.subtasks;}), icon:
            Icon(Icons.arrow_left, color: Color.fromARGB(255, 170, 170, 170),), label: Text("Subtask"),)
        ),
        Align(alignment: Alignment(0.7, 1), child:
          TextButton.icon(onPressed: () => setState((){section = Section.notes;}), icon:
            Icon(Icons.arrow_right, color: Color.fromARGB(255, 170, 170, 170),), label: Text("Notes"), iconAlignment: IconAlignment.end,)
        ),
      ]);
    } else {
      return Stack(children: <Widget> [
        Align(alignment: Alignment(-0.88, 0.07) , child:
            Text("General", textScaler: TextScaler.linear(1.1),),),
          Align(alignment: Alignment(-0.88, 0.15) , child:
            Text("Priority", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
          Align(alignment: Alignment(0, 0.25), child: SizedBox(width: 300, height: 10, child: 
            Slider(value: s.requireData.priority.toDouble(), onChanged: (value) => setState(() {s.requireData.priority = value.ceil();}), min: 1, max: 5, divisions: 4,),
          ),),
          Align(alignment: Alignment(-0.88, 0.35) , child:
            Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
          Align(alignment: Alignment(0, 0.45), child: SizedBox(width: 300, height: 10, child: 
            Slider(value: s.requireData.difficulty.toDouble(), onChanged: (value) => setState(() {
              s.requireData.difficulty = value.ceil();
            }), min: 1, max: 5, divisions: 4,),)
          ,),
          Align(alignment: Alignment(-0.88, 0.55) , child:
            Text("Frequency", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),),),
          Align(alignment: Alignment(0, 0.8), child: 
            frequency(s),
          ),
          Align(alignment: Alignment(0.35, 0.12) , child:
            Text("Set Private", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.15),),),
          Align(alignment: Alignment(0.8, 0.12) , child: SizedBox(width:45, height: 35, child: FittedBox(fit: BoxFit.fill, child: 
            Switch(value: s.requireData.isPrivate, onChanged: (value) => setState(() {
              s.requireData.isPrivate = value;
            }), ),),)
          ),
          Align(alignment: Alignment(-0.7, 1), child:
            TextButton.icon(onPressed: () => setState((){section = Section.subtasks;}), icon:
              Icon(Icons.arrow_left, color: Color.fromARGB(255, 170, 170, 170),), label: Text("Subtask"),)
          ),
          Align(alignment: Alignment(0.7, 1), child:
            TextButton.icon(onPressed: () => setState((){section = Section.notes;}), icon:
              Icon(Icons.arrow_right, color: Color.fromARGB(255, 170, 170, 170),), label: Text("Notes"), iconAlignment: IconAlignment.end,),)
        ],);
    }
  }

  bool textBoxOpen = false;
  List<bool> toBeDeleted = [];
  Widget subtasks(AsyncSnapshot<Task> s) {
    List<Subtask> list = s.requireData.subtasks;
    if(toBeDeleted.length != list.length) {
      toBeDeleted = [];
      for(int i = 0; i < list.length; i++) {
        toBeDeleted.add(false);
      }
    }
    List<Widget> output = [
      Align(alignment: Alignment(-0.88, 0.07) , child:
            Text("Subtasks", textScaler: TextScaler.linear(1.1),),),
          Align(alignment: Alignment(0.7, 1), child:
            TextButton.icon(onPressed: () => setState((){section = Section.general;}), icon:
              Icon(Icons.arrow_right, color: Color.fromARGB(255, 170, 170, 170),), label: Text("General"), iconAlignment: IconAlignment.end,)
            ),
    ];

    if(s.requireData.subtasks.isNotEmpty) {
      output.add(Align(alignment: Alignment(0, 0.65), child:
        ConstrainedBox(constraints: BoxConstraints(maxWidth: 300, maxHeight: 180), child:
          ListView(scrollDirection: Axis.vertical, physics: ScrollPhysics(), children: nextSubtask(list, 0)),),),);
    } else {
      output.add(Align(alignment: Alignment(0, 0.2) , child:
            Text("No Subtasks", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),)
      ),);
    }

    if(widget.bState == BigState.edit) {
      output.addAll([Align(alignment: Alignment(-0.2, 0.95), child:
          MaterialButton(color: AppColors.secondary, shape: CircleBorder(), onPressed:  () =>  setState((){textBoxOpen = true;}), child: 
            Icon(Icons.add, color: AppColors.primary,),)),
        Align(alignment: Alignment(-0.9, 0.95), child:
          MaterialButton(color: AppColors.secondary, textColor: AppColors.primary, disabledColor: Colors.grey, disabledTextColor: const Color.fromARGB(255, 59, 45, 85), shape: CircleBorder(),
            onPressed: () => setState((){
              for(int i = 0; i < toBeDeleted.length; i++) {
                if(toBeDeleted.elementAt(i)) {
                  s.requireData.subtasks.removeAt(i);
                  toBeDeleted.removeAt(i);
                  i = i-1;
                }
              }
              }), child: 
            Icon(Icons.delete),)),
        Align(alignment: Alignment(0, 0.5), child: text4Subtask(s)),]);
    }

    return Stack(children: output,);
  }

  Widget text4Subtask(AsyncSnapshot<Task> s) {
    if(textBoxOpen) {
      Future<Subtask> newSub = Subtask.create(name: "toBeWritten");
      return FutureBuilder<Subtask>(future: newSub, builder: (context, snapshot) {return
        TextField(onSubmitted: (String value)  =>  setState(() {textBoxOpen = false; snapshot.requireData.name = value; s.requireData.subtasks.add(snapshot.requireData);}) , autofocus: true,);
      });
    } else {
      return SizedBox.shrink();
    }
  }

  Widget notes(AsyncSnapshot<Task> s) {
    if(widget.bState == BigState.info) {
    return Stack(children: <Widget> [
        Align(alignment: Alignment(-0.88, 0.07) , child:
          Text("Notes", textScaler: TextScaler.linear(1.1),),),
        Align(alignment: Alignment(0, 0.6) ,  child:
          ConstrainedBox(constraints: BoxConstraints(maxHeight: 150, maxWidth: 270), child:
            SingleChildScrollView(scrollDirection: Axis.vertical, primary: true,  child:
              Text(s.requireData.notes, style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.2),)),),),
        Align(alignment: Alignment(-0.7, 1), child:
          TextButton.icon(onPressed: () => setState((){section = Section.general;}), icon:
            Icon(Icons.arrow_left, color: Color.fromARGB(255, 170, 170, 170),), label: Text("General"),)
          ),
      ]); 
    } else {
      return Stack(children: <Widget> [
        Align(alignment: Alignment(-0.88, 0.07) , child:
          Text("Notes", textScaler: TextScaler.linear(1.1),),),
        Align(alignment: Alignment(0, 0.55), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 280, maxHeight: 200), child: 
          EditableText(controller: TextEditingController(text: s.requireData.notes), focusNode: FocusNode(), cursorColor: Colors.black, backgroundCursorColor: Colors.black,
            onSubmitted: (value) => setState(() {Task change = s.requireData; change.notes = value;}),
            maxLines: 9, minLines: 9, textInputAction: TextInputAction.done,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), textScaler: TextScaler.linear(1.3), textHeightBehavior: TextHeightBehavior(),),)
        ),
        Align(alignment: Alignment(-0.7, 1), child:
          TextButton.icon(onPressed: () => setState((){section = Section.general;}), icon:
            Icon(Icons.arrow_left, color: Color.fromARGB(255, 170, 170, 170),), label: Text("General"),)
          ),
      ]);
    }
  }

  Widget categoryMenu(AsyncSnapshot<Task> s) {
    var list = [
      DropdownMenuItem<Category>(value: Category.Admin, child:
        Text(Category.Admin.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),
      ),
      DropdownMenuItem<Category>(value: Category.Childcare, child:
        Text(Category.Childcare.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),
      ),
      DropdownMenuItem<Category>(value: Category.Cleaning, child:
        Text(Category.Cleaning.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),
      ),
      DropdownMenuItem<Category>(value: Category.Cooking, child:
        Text(Category.Cooking.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),
      ),
      DropdownMenuItem<Category>(value: Category.Laundry, child:
        Text(Category.Laundry.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),
      ),
      DropdownMenuItem<Category>(value: Category.Outdoor, child:
        Text(Category.Outdoor.name, style: TextStyle(fontWeight: FontWeight.bold,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.4),),
      ),
    ];
    return Align(alignment: Alignment(0.95, -0.9) , child:
      DropdownButton<Category>(value: s.requireData.category, alignment: Alignment.centerRight, items: list, onChanged: (chosen) => setState(() {
        s.requireData.category = chosen;
      }),),
    );
  }

  Widget frequency(AsyncSnapshot<Task> s) {
    var currFreq = s.requireData.frequency;
    List<Widget> freqOptions = [
      Text("Daily"), Text("Weekly"), Text("Monthly"), Text("Yearly"),
    ];
    List<bool> selected = [
      currFreq == Frequency.daily,
      currFreq == Frequency.weekly,
      currFreq == Frequency.monthly,
      currFreq == Frequency.yearly,
    ];

    return Align(alignment: Alignment(0, 0.72), child: 
            ToggleButtons(isSelected: selected, children: freqOptions, onPressed: (value) => setState(() {
              s.requireData.frequency = Frequency.values.elementAt(value);
              }),
              borderRadius: BorderRadius.all(Radius.circular(40)),
              constraints: BoxConstraints(minWidth: 75, minHeight: 35),)
          ,);
  }

  List<Widget> nextSubtask(List<Subtask> l, int i) {
    var check = false;
    if(toBeDeleted.isNotEmpty) {
      check = widget.bState == BigState.edit ? toBeDeleted.elementAt(i) : l.elementAt(i).isDone;
    } else {
      check = false;
    }
    List<Widget> list = [
      Align(alignment: Alignment(0, -1+0.15*i), child: CheckboxListTile(title: Text(l.elementAt(i).name, style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),),
          value: check, onChanged:(bool? value) => setState((){widget.bState == BigState.edit ? toBeDeleted[i] = value! : l.elementAt(i).isDone = value;}), dense: true, visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        ),),
    ];
    if(l.length>i+1) {
        list.addAll(nextSubtask(l, i+1)); 
    } 
    return list;
  }

  Widget infoButton() {
    return Stack(children: <Widget> [
      Align(alignment: Alignment(0.0, 1), child:
        MaterialButton(color: AppColors.secondary,textColor: AppColors.secondaryText, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        height: 35, minWidth: 130, onPressed: () => setState(() { widget.bState = BigState.info; widget.size = Size.big; }), child:
          Text("Info", textScaler: TextScaler.linear(0.7),),),
      ),
    ],);
  }

  Widget doneButton() {
    return Stack(children: <Widget> [
      Align(alignment: Alignment(0.0, 1), child:
        MaterialButton(color: AppColors.success,textColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          height: 35, minWidth: 130, onPressed: () => setState(() { widget.sState = SmallState.todo; }), child:
            Text("Completed", textScaler: TextScaler.linear(0.7),),),
      ),
    ],);
  }

  Widget editButtons() {
    return _twoButtons("Edit", AppColors.primary, false, AppColors.primaryText);
  }

  Widget toDoButtons() {
    return _twoButtons("Check off", AppColors.success, true, Colors.black);
  }

  Widget _twoButtons(String s, Color b, bool sml, Color t) {
    return Stack(children: <Widget> [
      Align(alignment: Alignment(0.8, 1), child:
        MaterialButton(color: b, textColor: t, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        height: 35, minWidth: 80,
        onPressed: () => setState(() { 
          if(sml) {
            widget.sState = SmallState.done;
          } else {
            widget.bState = BigState.edit; widget.size = Size.big;
          }}),
        child:
          Text(s, textScaler: TextScaler.linear(0.7),),),
        ),
      Align(alignment: Alignment(-1, 1), child:
        MaterialButton(color: AppColors.secondary, textColor: AppColors.secondaryText, shape: CircleBorder(),
        height: 35, minWidth: 0,
        onPressed: () =>  setState(() {
          widget.bState = BigState.info; widget.size = Size.big;
        }),
        child:
          Text("Info", textScaler: TextScaler.linear(0.6),),),),
    ],);
  }

  Widget names(String name, Size s) {
    if(s == Size.small) {
      if(name.length>10 && name.substring(10,11) != ' ') {
        return Stack(children: <Widget> [
            Align(alignment: Alignment(-0.90, -0.9) , child:
              Text("${name.substring(0,10)}-", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),),
            Align(alignment: Alignment(-0.7, -0.75) , child:
              Text(name.substring(10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.5),),)
            ,]
        );
      }
      else if(name.length>10) {
        return Stack(children: <Widget> [
            Align(alignment: Alignment(-0.90, -0.9) , child:
              Text(name.substring(0,10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),),
            Align(alignment: Alignment(-0.7, -0.75) , child:
              Text(name.substring(10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.5),),)
            ,]
        );
      }
      else {
        return Align(alignment: Alignment(-0.90, -0.9) , child:
          Text(name, style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8),),);
      }
    } else {
      return Align(alignment: Alignment(-0.8, -0.94) , child:
            ConstrainedBox(constraints: BoxConstraints(maxHeight: 50, maxWidth: 190), child:
              Text(name, maxLines: 2, textHeightBehavior: TextHeightBehavior(), style: TextStyle(fontWeight: FontWeight.bold, height: 1.2), textScaler: TextScaler.linear(1.4),),)
      );
    }
  }

  String dueDate(Frequency f) {
    DateTime due = assigned;
    DateTime check = DateTime.now();
    if(f == Frequency.daily) {
      due = due.add(Duration(days: 1));
    } else if(f == Frequency.weekly) {
      due = due.add(Duration(days: 7));
    } else if(f == Frequency.monthly) {
      due = due.add(Duration(days: 31));
    } else {
      due = due.add(Duration(days: 365));
    }
    Duration difference = due.difference(check);
    if(difference.inDays >= 0 && check.day != due.day) {
      if(difference.inDays == 0) {
        return "${due.day}/${due.month} (Tomorrow)";
      }
      return "${due.day}/${due.month} (In ${difference.inDays+1} Days)";
    }
    return "${due.day}/${due.month} (In ${difference.inDays} Days)";
  }

  
  Widget findSubtask(List<Subtask> s) {
    if(s.isNotEmpty) {
      Subtask f = s.firstWhere((Subtask f) => !f.isDone, orElse: () => s.last);
      subTaskIdx = s.indexOf(f);
      return Align(alignment: Alignment(0, 0.7) , child:
        CheckboxListTile(title: Text(f.name, style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),),
        value: f.isDone, onChanged:(bool? value) => setState((){s.elementAt(subTaskIdx).isDone = value;}),dense: true, visualDensity: VisualDensity(horizontal: -2, vertical: -2),),
      );
    }
    return Align(alignment: Alignment(0, 0.7) , child:
      Text("No Subtasks", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(1.4),));
  }
}