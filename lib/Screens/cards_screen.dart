import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/classes/cards.dart';
import 'package:mental_load/classes/Task.dart';

Future<Task> test = Task.create(name: "Antidisestablishment(very long example)", category: Category.Cleaning, frequency: Frequency.daily, notes: "none", imgDst: "lib/assets/image1.png", isPrivate: false, difficulty: 3, priority: 3);

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[Center(child:CardsMini(thisTask: test,),),
        Center(child:CardsBig(thisTask:test))
      ]
    );
  }
}

