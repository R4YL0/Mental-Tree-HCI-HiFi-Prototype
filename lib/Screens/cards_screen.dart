import 'package:flutter/material.dart';
import 'package:mental_load/constants/colors.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, right: 10, left: 10),
        child: Center(
          child: Container(
            color: AppColors.primary,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("CARDS - Todo", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ),
        ),
      ),
    );
  }
}