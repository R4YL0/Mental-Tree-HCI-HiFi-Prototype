import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/classes/cards.dart';
import 'package:mental_load/classes/Task.dart';

Future<Task> test = Task.create(name: "Task Namw", category: Category.Cleaning, frequency: Frequency.daily, notes: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.", /*imgDst: "lib/assets/image1.png",*/ isPrivate: false, difficulty: 3, priority: 3, subtasks: []);

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[Center(child:Cards(thisTask: test, sState: SmallState.info, size: Size.small,),),
        Center(child:Cards(thisTask:test, sState: SmallState.edit, size: Size.big,)),
      ]
    );
  }
}

