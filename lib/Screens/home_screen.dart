import 'package:flutter/material.dart';
import 'package:mental_load/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: AppColors.primary,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("HOME - Todo", style: TextStyle(fontWeight: FontWeight.bold),),
          ),
        ),
      ),
    );
  }
}