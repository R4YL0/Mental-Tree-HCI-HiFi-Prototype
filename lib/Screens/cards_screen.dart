import 'package:flutter/material.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/classes/cards.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child:Cards(),),
    );
  }
}

