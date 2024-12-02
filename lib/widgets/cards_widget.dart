import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mental_load/classes/Subtask.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/classes/Task.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum SmallState { info, edit, todo, done }

enum BigState { info, edit, swipe }

enum Size { small, big }

enum Section { general, subtasks, notes }

class Cards extends StatefulWidget {
  final Future<Task> thisTask;
  var sState = SmallState.edit;
  var bState = BigState.info;
  var size = Size.small;
  DateTime finalDate = DateTime(2045);
  double heightBig = 550;
  
  Cards({super.key, required this.thisTask, required this.sState, this.size = Size.small, required this.bState, required this.heightBig});

  @override
  State<Cards> createState() => _Cards();

}

class _Cards extends State<Cards> {
  var oldState = SmallState.info;
  var subTaskIdx = 0;
  var assigned = DateTime.now();
  var section = Section.general;

  //Fields for Subtasks
  bool textBoxOpen = false;
  List<bool> toBeDeleted = [];

  //Buttons needed for SmallCards
  Widget buttons(AsyncSnapshot<Task> s) {
    if (widget.sState == SmallState.edit) {
      return editButtons(s);
    } else if (widget.sState == SmallState.todo) {
      return toDoButtons(s);
    } else if (widget.sState == SmallState.done) {
      return doneButton(s);
    } else {
      return infoButton(s);
    }
  }

  //Sections Needed for BigCards
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
    if (widget.size == Size.small) {
      //|| widget.bState != BigState.swipe) {
      return smallCard();
    } else {
      return bigCard();
    }
  }

  //Dividing The Screen into SmallCards and BigCards
  Widget smallCard() {
    final double cardHeight = widget.heightBig; // Use heightBig for consistency
    final double cardWidth = cardHeight /200 *140;

    return FutureBuilder<Task>(
      future: widget.thisTask,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Card(
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Stack(
                children: <Widget>[
                  names(snapshot.requireData.name, Size.small, snapshot),
                  Align(
                    alignment: Alignment(0.75, -0.88),
                    child: Text(
                      snapshot.requireData.category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2.2,
                            color: Color.fromARGB(188, 175, 175, 175),
                          ),
                          Shadow(
                            offset: Offset(0, 0),
                            blurRadius: 5,
                            color: Color.fromARGB(105, 175, 175, 175),
                          ),
                        ],
                      ),
                      textScaleFactor: 0.65,
                    ),
                  ),
                  Align(
                    alignment: Alignment(-0.34, -0.417),
                    child: ColoredBox(
                      color: Color.fromARGB(255, 254, 213, 182),
                      child: SizedBox(
                        width: cardWidth * 0.95,
                        height: cardHeight * 0.4,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(-0.34, -0.417),
                    child: ClipRect(
                      child: SizedBox(
                        width: cardWidth * 0.95, 
                        height: cardHeight * 0.4, 
                        child: Image.memory(
                          snapshot.requireData.img,
                          fit: BoxFit.cover, 
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(-0.88, 0.35),
                    child: Text(
                      "Priority",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 0.6,
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.75, 0.35),
                    child: Text(
                      "${snapshot.requireData.priority}/5",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 0.7,
                    ),
                  ),
                  Align(
                    alignment: Alignment(-0.88, 0.5),
                    child: Text(
                      "Difficulty",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 0.6,
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.75, 0.5),
                    child: Text(
                      "${snapshot.requireData.difficulty}/5",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 0.7,
                    ),
                  ),
                  buttons(snapshot),
                ],
              ),
            ),
          );
        } else {
          return Text("No Data Fetched");
        }
      },
    );
  }

  Widget bigCard() {
    final double cardHeight = widget.heightBig;
    final double cardWidth = cardHeight /200 *140;

    return FutureBuilder<Task>(
      future: widget.thisTask,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Card(
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment(0, -0.7),
                    child: ColoredBox(
                      color: Color.fromARGB(255, 254, 213, 182),
                      child: SizedBox(
                        width: cardWidth * 0.95,
                        height: cardHeight * 0.5,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, -0.7),
                    child: ClipRect(
                      // Ensures the image is cropped to fit within the orange box
                      child: SizedBox(
                        width: cardWidth * 0.95, // Same width as the orange box
                        height: cardHeight * 0.5, // Same height as the orange box
                        child: Image.memory(
                          snapshot.requireData.img,
                          fit: BoxFit.cover, // Ensures the image covers the box
                        ),
                      ),
                    ),
                  ),
                  sections(snapshot),
                ],
              ),
            ),
          );
        } else {
          return Text("No Data Fetched");
        }
      },
    );
  }

  //Buttons for SmallCards: infoButtons, doneButtons, editButtons, toDoButtons
  Widget infoButton(AsyncSnapshot<Task> s) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(-0.9, 0.65),
          child: Text(
            "Due",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaleFactor: 0.7,
          ),
        ),
        Align(
          alignment: Alignment(0, 0.8),
          child: Text(
            dueDate(s.requireData.frequency, s),
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(2.2 * widget.heightBig / 550),
          ),
        ),
      ],
    );
  }

  Widget doneButton(AsyncSnapshot<Task> s) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(0.0, 1),
          child: MaterialButton(
            color: AppColors.attention,
            textColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            height: 35,
            minWidth: 130,
            onPressed: () => setState(() {
              widget.sState = SmallState.todo;
              widget.finalDate = DateTime(2045);
            }),
            child: Text(
              "Undo",
              textScaler: TextScaler.linear(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget editButtons(AsyncSnapshot<Task> s) {
    return _twoButtons("Edit", AppColors.primary, false, AppColors.primaryText, s);
  }

  Widget toDoButtons(AsyncSnapshot<Task> s) {
    return _twoButtons("Check off", AppColors.success, true, Colors.black, s);
  }

  //BigCards Sections: General, SubTasks, Notes
  Widget general(AsyncSnapshot<Task> s) {
    if (widget.bState == BigState.info) {
      return Stack(children: <Widget>[
        names(s.requireData.name, Size.big, s),
        categoryMenu(s),
        Align(
          alignment: Alignment(-0.88, 0.07),
          child: Text(
            "General",
            textScaler: TextScaler.linear(1.1 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(-0.88, 0.15),
          child: Text(
            "Priority",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(-0.35, 0.18),
          child: Text(
            "${s.requireData.priority}/5",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.9 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(0.45, 0.15),
          child: Text(
            "Difficulty",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(0.88, 0.18),
          child: Text(
            "${s.requireData.difficulty}/5",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.9 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(-0.9, 0.27),
          child: Text(
            "Due",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(0.2, 0.4),
          child: Text(
            dueDate(s.requireData.frequency, s),
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(2.2 * widget.heightBig / 550),
          ),
        ),

        Align(
          alignment: Alignment(-0.88, 0.55),
          child: Text(
            "Next Subtask",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
          ),
        ),
        findSubtask(s.requireData.subtasks),
        Align(
            alignment: Alignment(-0.7, 1),
            child: TextButton.icon(
              onPressed: () => setState(() {
                section = Section.subtasks;
              }),
              icon: Icon(
                Icons.arrow_left,
                color: Color.fromARGB(255, 170, 170, 170),
              ),
              label: Text(
                "Subtask",
                textScaler: TextScaler.linear(widget.heightBig / 550),
              ),
            )),
        Align(
            alignment: Alignment(0.7, 1),
            child: TextButton.icon(
              onPressed: () => setState(() {
                section = Section.notes;
              }),
              icon: Icon(
                Icons.arrow_right,
                color: Color.fromARGB(255, 170, 170, 170),
              ),
              label: Text(
                "Notes",
                textScaler: TextScaler.linear(widget.heightBig / 550),
              ),
              iconAlignment: IconAlignment.end,
            )),
        //Edit Button
        Align(
          alignment: Alignment(1, -1),
          child: IconButton(
            onPressed: () => setState(() {
              widget.bState = BigState.edit;
              section = Section.general; }),
            icon: Icon(
              Icons.edit,
              color: AppColors.primary,
               size: 28, 
            )
            ,
            tooltip: "Edit Task",
          ),
        ),

      ]);
    } else if (widget.bState == BigState.edit) {
      return Stack(
        children: <Widget>[
          names(s.requireData.name, Size.big, s),
          categoryMenu(s),
          Align(
            alignment: Alignment(-0.88, 0.07),
            child: Text(
              "General",
              textScaler: TextScaler.linear(1.1 * widget.heightBig / 550),
            ),
          ),
          Align(
            alignment: Alignment(-0.88, 0.15),
            child: Text(
              "Priority",
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.25),
            child: SizedBox(
              width: 300 * widget.heightBig / 550,
              height: 10 * widget.heightBig / 550,
              child: Slider(
                value: s.requireData.priority.toDouble(),
                onChanged: (value) => setState(() {
                  s.requireData.priority = value.ceil();
                }),
                min: 1,
                max: 5,
                divisions: 4,
              ),
            ),
          ),
          Align(
            alignment: Alignment(-0.88, 0.35),
            child: Text(
              "Difficulty",
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.45),
            child: SizedBox(
              width: 300 * widget.heightBig / 550,
              height: 10 * widget.heightBig / 550,
              child: Slider(
                value: s.requireData.difficulty.toDouble(),
                onChanged: (value) => setState(() {
                  s.requireData.difficulty = value.ceil();
                }),
                min: 1,
                max: 5,
                divisions: 4,
              ),
            ),
          ),
          Align(
            alignment: Alignment(-0.88, 0.55),
            child: Text(
              "Frequency",
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
            ),
          ),
          Align(
            alignment: Alignment(0, 0.8),
            child: frequency(s),
          ),
          Align(
              alignment: Alignment(-0.7, 1),
              child: TextButton.icon(
                onPressed: () => setState(() {
                  section = Section.subtasks;
                }),
                icon: Icon(
                  Icons.arrow_left,
                  color: Color.fromARGB(255, 170, 170, 170),
                ),
                label: Text(
                  "Subtask",
                  textScaler: TextScaler.linear(widget.heightBig / 550),
                ),
              )),
          Align(
            alignment: Alignment(0.7, 1),
            child: TextButton.icon(
              onPressed: () => setState(() {
                section = Section.notes;
              }),
              icon: Icon(
                Icons.arrow_right,
                color: Color.fromARGB(255, 170, 170, 170),
              ),
              label: Text(
                "Notes",
                textScaler: TextScaler.linear(widget.heightBig / 550),
              ),
              iconAlignment: IconAlignment.end,
            ),
          ),
          Align(
            alignment: Alignment(1, -1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    widget.bState = BigState.info;
                    section = Section.general;
                  }),
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 24,
                  ),
                  tooltip: "Confirm Editing",
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment(0.8, -0.1),
              child: IconButton(
                  onPressed: () {
                    chooseImage(s);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2)],
                  ))),
        ],
      );
    } else {
      return Stack(children: <Widget>[
        names(s.requireData.name, Size.big, s),
        categoryMenu(s),
        Align(
          alignment: Alignment(-0.88, 0.07),
          child: Text(
            "General",
            textScaler: TextScaler.linear(1.1 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(-0.88, 0.25),
          child: Text(
            "Priority",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(-0.35, 0.28),
          child: Text(
            "${s.requireData.priority}/5",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.9 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(0.45, 0.25),
          child: Text(
            "Difficulty",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(0.88, 0.28),
          child: Text(
            "${s.requireData.difficulty}/5",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.9 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(-0.88, 0.45),
          child: Text(
            "Next Subtask",
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
          ),
        ),
        findSubtask(s.requireData.subtasks),
        Align(
          alignment: Alignment(-0.88, 0.07),
          child: Text(
            "Notes",
            textScaler: TextScaler.linear(1.1 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(0, 0.6),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 100 * widget.heightBig / 550, maxWidth: 270 * widget.heightBig / 550),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                primary: true,
                child: Text(
                  s.requireData.notes,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
                )),
          ),
        ),
      ]);
    }
  }

  Widget subtasks(AsyncSnapshot<Task> s) {
    if (widget.bState == BigState.swipe) {
      return general(s);
    }

    List<Subtask> list = s.requireData.subtasks;
    if (toBeDeleted.length != list.length) {
      toBeDeleted = [];
      for (int i = 0; i < list.length; i++) {
        toBeDeleted.add(false);
      }
    }
    List<Widget> output = [
      names(s.requireData.name, Size.big, s),
      categoryMenu(s),
      Align(
        alignment: Alignment(-0.88, 0.07),
        child: Text(
          "Subtasks",
          textScaler: TextScaler.linear(1.1 * widget.heightBig / 550),
        ),
      ),
      Align(
          alignment: Alignment(0.7, 1),
          child: TextButton.icon(
            onPressed: () => setState(() {
              section = Section.general;
            }),
            icon: Icon(
              Icons.arrow_right,
              color: Color.fromARGB(255, 170, 170, 170),
            ),
            label: Text(
              "General",
              textScaler: TextScaler.linear(widget.heightBig / 550),
            ),
            iconAlignment: IconAlignment.end,
          )),
    ];

    if (s.requireData.subtasks.isNotEmpty) {
      output.add(
        Align(
          alignment: Alignment(0, 0.65),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300 * widget.heightBig / 550, maxHeight: 180 * widget.heightBig / 550),
            child: ListView(scrollDirection: Axis.vertical, physics: ScrollPhysics(), children: nextSubtask(list, 0)),
          ),
        ),
      );
    } else {
      output.add(
        Align(
            alignment: Alignment(0, 0.2),
            child: Text(
              "No Subtasks",
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaler: TextScaler.linear(1.4 * widget.heightBig / 550),
            )),
      );
    }

    if (widget.bState == BigState.edit) {
      output.addAll([
        Align(
            alignment: Alignment(-0.2, 0.95),
            child: MaterialButton(
              color: AppColors.secondary,
              shape: CircleBorder(),
              onPressed: () => setState(() {
                textBoxOpen = true;
              }),
              child: Icon(
                Icons.add,
                color: AppColors.primary,
              ),
            )),
        Align(
            alignment: Alignment(-0.9, 0.95),
            child: MaterialButton(
              color: AppColors.secondary,
              textColor: AppColors.primary,
              disabledColor: Colors.grey,
              disabledTextColor: const Color.fromARGB(255, 59, 45, 85),
              shape: CircleBorder(),
              onPressed: () => setState(() {
                for (int i = 0; i < toBeDeleted.length; i++) {
                  if (toBeDeleted.elementAt(i)) {
                    s.requireData.subtasks.removeAt(i);
                    toBeDeleted.removeAt(i);
                    i = i - 1;
                  }
                }
              }),
              child: Icon(Icons.delete),
            )),
        Align(alignment: Alignment(0, 0.5), child: text4Subtask(s)),
        Align(
            alignment: Alignment(1, -1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    widget.bState = BigState.info;
                    section = Section.general;
                  }),
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 24,
                  ),
                  tooltip: "Confirm Editing",
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment(0.8, -0.1),
              child: IconButton(
                  onPressed: () {
                    chooseImage(s);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2)],
                  ))),
      ]);
    } else {
      output.add(
      //Edit Button
      Align(
        alignment: Alignment(1, -1),
        child: IconButton(
          onPressed: () => setState(() {
            widget.bState = BigState.edit;
            section = Section.general; }),
          icon: Icon(
            Icons.edit,
            color: AppColors.primary,
              size: 28, 
          )
          ,
          tooltip: "Edit Task",
        ),
      ),

      );
    }

    return Stack(
      children: output,
    );
  }

  Widget notes(AsyncSnapshot<Task> s) {
    if (widget.bState == BigState.info) {
      return Stack(children: <Widget>[
        names(s.requireData.name, Size.big, s),
        categoryMenu(s),
        Align(
          alignment: Alignment(-0.88, 0.07),
          child: Text(
            "Notes",
            textScaler: TextScaler.linear(1.1 * widget.heightBig / 550),
          ),
        ),
        Align(
          alignment: Alignment(0, 0.6),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 150 * widget.heightBig / 550, maxWidth: 270 * widget.heightBig / 550),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                primary: true,
                child: Text(
                  s.requireData.notes,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textScaler: TextScaler.linear(1.2 * widget.heightBig / 550),
                )),
          ),
        ),
        Align(
            alignment: Alignment(-0.7, 1),
            child: TextButton.icon(
              onPressed: () => setState(() {
                section = Section.general;
              }),
              icon: Icon(
                Icons.arrow_left,
                color: Color.fromARGB(255, 170, 170, 170),
              ),
              label: Text(
                "General",
                textScaler: TextScaler.linear(widget.heightBig / 550),
              ),
            )),
        //Edit Button
        Align(
          alignment: Alignment(1, -1),
          child: IconButton(
            onPressed: () => setState(() {
              widget.bState = BigState.edit;
              section = Section.general; }),
            icon: Icon(
              Icons.edit,
              color: AppColors.primary,
               size: 28, 
            )
            ,
            tooltip: "Edit Task",
          ),
        ),
      ]);
    } else if (widget.bState == BigState.edit) {
      return Stack(children: <Widget>[
        names(s.requireData.name, Size.big, s),
        categoryMenu(s),
        Align(
          alignment: Alignment(-0.88, 0.07),
          child: Text(
            "Notes",
            textScaler: TextScaler.linear(1.1 * widget.heightBig / 550),
          ),
        ),
        Align(
            alignment: Alignment(0, 0.55),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 280 * widget.heightBig / 550, maxHeight: 200 * widget.heightBig / 550),
              child: EditableText(
                controller: TextEditingController(text: s.requireData.notes),
                focusNode: FocusNode(),
                cursorColor: Colors.black,
                backgroundCursorColor: Colors.black,
                onSubmitted: (value) => setState(() {
                  Task change = s.requireData;
                  change.notes = value;
                }),
                maxLines: 9,
                minLines: 9,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                textScaler: TextScaler.linear(1.3 * widget.heightBig / 550),
                textHeightBehavior: TextHeightBehavior(),
              ),
            )),
        Align(
            alignment: Alignment(-0.7, 1),
            child: TextButton.icon(
              onPressed: () => setState(() {
                section = Section.general;
              }),
              icon: Icon(
                Icons.arrow_left,
                color: Color.fromARGB(255, 170, 170, 170),
              ),
              label: Text(
                "General",
                textScaler: TextScaler.linear(widget.heightBig / 550),
              ),
            )),
        Align(
            alignment: Alignment(1, -1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    widget.bState = BigState.info;
                    section = Section.general;
                  }),
                  icon: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 24,
                  ),
                  tooltip: "Confirm Editing",
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment(0.8, -0.1),
              child: IconButton(
                  onPressed: () {
                    chooseImage(s);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2)],
                  ))),
      ]);
    } else {
      return general(s);
    }
  }

  //Helper Functions: names, chooseImage, findSubtask, nextSubtask, text4Subtask, categoryMenu, frequency, dueDates, _twoButtons
  Widget names(String name, Size s, AsyncSnapshot<Task> t) {
    if(widget.bState == BigState.edit) {
      return Align(alignment: Alignment(-0.75, -0.94) , child:
          ConstrainedBox(constraints: BoxConstraints(maxHeight: 50*widget.heightBig/550, maxWidth: 190*widget.heightBig/550), child: /*Row(children: <Widget>[*/
            EditableText(scrollPhysics: NeverScrollableScrollPhysics(), scrollPadding: EdgeInsets.all(0),
              controller: TextEditingController(text: t.requireData.name), focusNode: FocusNode(), cursorColor: Colors.black, backgroundCursorColor: Colors.black,
              maxLines: 2, minLines: 2, textInputAction: TextInputAction.done,
              onSubmitted: (value) => setState(() {Task change = t.requireData; change.name = value;}),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), textScaler: TextScaler.linear(1.4*widget.heightBig/550),),
            //Icon(Icons.edit, color: Colors.grey, size: 15,),
          /*]),*/)
        );
    }
    if(s == Size.small) {
      if(name.length>10 && name.substring(10,11) != ' ') {
        return Stack(children: <Widget> [
            Align(alignment: Alignment(-0.90, -0.9) , child:
              Text("${name.substring(0,10)}-", style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8*widget.heightBig/550),),),
            Align(alignment: Alignment(-0.7, -0.75) , child:
              Text(name.substring(10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.5*widget.heightBig/550),),)
            ,]
        );
      }
      else if(name.length>10) {
        return Stack(children: <Widget> [
            Align(alignment: Alignment(-0.90, -0.9) , child:
              Text(name.substring(0,10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8*widget.heightBig/550),),),
            Align(alignment: Alignment(-0.7, -0.75) , child:
              Text(name.substring(10), style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.5*widget.heightBig/550),),)
            ,]
        );
      }
      else {
        return Align(alignment: Alignment(-0.90, -0.9) , child:
          Text(name, style: TextStyle(fontWeight: FontWeight.bold), textScaler: TextScaler.linear(0.8*widget.heightBig/550),),);
      }
    } else {
      return Align(alignment: Alignment(-0.8, -0.94) , child:
            ConstrainedBox(constraints: BoxConstraints(maxHeight: 50*widget.heightBig/550, maxWidth: 190*widget.heightBig/550), child:
              Text(name, maxLines: 2, textHeightBehavior: TextHeightBehavior(), style: TextStyle(fontWeight: FontWeight.bold, height: 1.2*widget.heightBig/550), textScaler: TextScaler.linear(1.4*widget.heightBig/550),),)
      );
    }
  }

  void chooseImage(AsyncSnapshot<Task> s) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery) as XFile;
    if(image == null) {
      return;
    }
    setState(() {
      s.requireData.img = File(image.path).readAsBytesSync();
    });
  }

  Widget findSubtask(List<Subtask> s) {
    double position = widget.bState == BigState.swipe ? 0.65 : 0.7;
    if (s.isNotEmpty) {
      Subtask f = s.firstWhere((Subtask f) => !f.isDone, orElse: () => s.last);
      subTaskIdx = s.indexOf(f);
      return Align(
        alignment: Alignment(0, position),
        child: CheckboxListTile(
          title: Text(
            f.name,
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.4 * widget.heightBig / 550),
            maxLines: 1,
          ),
          value: f.isDone,
          onChanged: (bool? value) => setState(() {
            s.elementAt(subTaskIdx).isDone = value;
          }),
          dense: true,
          visualDensity: VisualDensity(horizontal: -2, vertical: -2),
        ),
      );
    }
    return Align(
        alignment: Alignment(0, 0.7),
        child: Text(
          "No Subtasks",
          style: TextStyle(fontWeight: FontWeight.bold),
          textScaler: TextScaler.linear(1.4 * widget.heightBig / 550),
        ));
  }

  List<Widget> nextSubtask(List<Subtask> l, int i) {
    var check = false;
    if (toBeDeleted.isNotEmpty) {
      check = widget.bState == BigState.edit ? toBeDeleted.elementAt(i) : l.elementAt(i).isDone;
    } else {
      check = false;
    }
    List<Widget> list = [
      Align(
        alignment: Alignment(0, -1 + 0.15 * i),
        child: CheckboxListTile(
          title: Text(
            l.elementAt(i).name,
            style: TextStyle(fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.4 * widget.heightBig / 550),
          ),
          value: check,
          onChanged: (bool? value) => setState(() {
            widget.bState == BigState.edit ? toBeDeleted[i] = value! : l.elementAt(i).isDone = value;
          }),
          dense: true,
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        ),
      ),
    ];
    if (l.length > i + 1) {
      list.addAll(nextSubtask(l, i + 1));
    }
    return list;
  }

  Widget text4Subtask(AsyncSnapshot<Task> s) {
    if (textBoxOpen) {
      Future<Subtask> newSub = Subtask.create(name: "toBeWritten");
      return FutureBuilder<Subtask>(
          future: newSub,
          builder: (context, snapshot) {
            return Stack(children:[
            ColoredBox(
                color: Color.fromARGB(255, 242, 242, 242),
                child: SizedBox(
                  width: 400 * widget.heightBig/550,
                  height: 50* widget.heightBig/550,
                ),
            ),
            TextField(
              onSubmitted: (String value) => setState(() {
                textBoxOpen = false;
                snapshot.requireData.name = value;
                s.requireData.subtasks.add(snapshot.requireData);
              }),
              autofocus: true,
            )]);
          });
    } else {
      return SizedBox.shrink();
    }
  }

  Widget categoryMenu(AsyncSnapshot<Task> s) {
    if(widget.bState != BigState.edit) {
      return Align(alignment: Alignment(0.65, -0.92) , child:
          Text(s.requireData.category.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14*widget.heightBig/550, shadows: <Shadow>[
            Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
            Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ],
        ), textScaler: TextScaler.linear(1.4),),);
    } 
    var list = [
      DropdownMenuItem<Category>(value: Category.Admin, child:
        Text(Category.Admin.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14*widget.heightBig/550,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.7*widget.heightBig/550),),
      ),
      DropdownMenuItem<Category>(value: Category.Childcare, child:
        Text(Category.Childcare.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14*widget.heightBig/550, shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.7*widget.heightBig/550),),
      ),
      DropdownMenuItem<Category>(value: Category.Cleaning, child:
        Text(Category.Cleaning.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14*widget.heightBig/550,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.7*widget.heightBig/550),),
      ),
      DropdownMenuItem<Category>(value: Category.Cooking, child:
        Text(Category.Cooking.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14*widget.heightBig/550,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.7*widget.heightBig/550),),
      ),
      DropdownMenuItem<Category>(value: Category.Laundry, child:
        Text(Category.Laundry.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14*widget.heightBig/550,shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.7*widget.heightBig/550),),
      ),
      DropdownMenuItem<Category>(value: Category.Outdoor, child:
        Text(Category.Outdoor.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14*widget.heightBig/550, shadows: <Shadow>[
          Shadow( offset: Offset(1, 1), blurRadius: 2.2, color: Color.fromARGB(188, 175, 175, 175),),
          Shadow( offset: Offset(0, 0), blurRadius: 5, color: Color.fromARGB(105, 175, 175, 175),),
          ], ), textScaler: TextScaler.linear(1.7*widget.heightBig/550),),
      ),
    ];
    return Align(alignment: Alignment(0.7, -0.97) , child:
      DropdownButton<Category>(value: s.requireData.category, alignment: Alignment.centerRight, items: list, onChanged: (chosen) => setState(() {
        s.requireData.category = chosen;
      }),),
    );
  }

  Widget frequency(AsyncSnapshot<Task> s) {
    var currFreq = s.requireData.frequency;
    List<Widget> freqOptions = [Text("Daily"), Text("Weekly"), Text("Monthly"), Text("Yearly"), Text("One Time")];
    List<bool> selected = [
      currFreq == Frequency.daily,
      currFreq == Frequency.weekly,
      currFreq == Frequency.monthly,
      currFreq == Frequency.yearly,
      currFreq == Frequency.oneTime,
    ];

    return Align(
      alignment: Alignment(0, 0.72),
      child: ToggleButtons(
        isSelected: selected,
        children: freqOptions,
        onPressed: (value) => setState(() {
          s.requireData.frequency = Frequency.values.elementAt(value);
          if(value == Frequency.oneTime) { datePicker();}
        }),
        borderRadius: BorderRadius.all(Radius.circular(40)),
        constraints: BoxConstraints(minWidth: 75 * widget.heightBig / 550, minHeight: 35 * widget.heightBig / 550),
      ),
    );
  }

  void datePicker() async {
    //TODO
    DateTime picked;
    //final Future<DateTime?> pickedDate = showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2025), onDatePickerModeChange: (value) => {picked = value;},);

  }

  /*void chooseImage(AsyncSnapshot<Task> s) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery) as XFile;
    if(image == null) {
      return;
    }
    setState(() {
      s.requireData.img = File(image.path).readAsBytesSync();
    });
  }*/

  String dueDate(Frequency f, AsyncSnapshot<Task> t) {
    DateTime? start = t.requireData.startDate;
    if (start == null) {
      return "No Start Date";
    }

    DateTime? due = t.requireData.dueDate;
    if (due == null) {
      if (f == Frequency.daily) {
        due = start.add(Duration(days: 1));
      } else if (f == Frequency.weekly) {
        due = start.add(Duration(days: 7));
      } else if (f == Frequency.monthly) {
        due = start.add(Duration(days: 31));
      } else if (f == Frequency.yearly) {
        due = start.add(Duration(days: 365));
      } else {
        return "No Due Date";
      }
      t.requireData.dueDate = due; // Save the computed dueDate back to the task
    }

    Duration difference = due.difference(DateTime.now());
    if (difference.inDays >= 0) {
      if (difference.inDays == 0) {
        return "${due.day}/${due.month} (Today)";
      } else if (difference.inDays == 1) {
        return "${due.day}/${due.month} (Tomorrow)";
      } else {
        return "${due.day}/${due.month} (In ${difference.inDays} Days)";
      }
    } else {
      return "${due.day}/${due.month} (Overdue)";
    }
  }

  Widget _twoButtons(String s, Color b, bool sml, Color t, AsyncSnapshot<Task> task) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment(0.8, 1),
          child: MaterialButton(
            color: b,
            textColor: t,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            height: 35,
            minWidth: 80,
            onPressed: () => setState(() {
              if (sml) {
                widget.sState = SmallState.done;
                widget.finalDate = DateTime.now();
              } else {
                widget.bState = BigState.edit;
                widget.size = Size.big;
              }
            }),
            child: Text(
              s,
              textScaler: TextScaler.linear(0.7),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-1, 1),
          child: MaterialButton(
            color: AppColors.secondary,
            textColor: AppColors.secondaryText,
            shape: CircleBorder(),
            height: 35,
            minWidth: 0,
            onPressed: () => setState(() {
              widget.bState = BigState.info;
              widget.size = Size.big;
            }),
            child: Text(
              "Info",
              textScaler: TextScaler.linear(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
