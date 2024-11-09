import 'package:flutter/material.dart';
import 'package:mental_load/constants/colors.dart';

class DiagramsScreen extends StatelessWidget {
  const DiagramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: AppColors.primary,
          child: const Text("DIAGRAMS - Todo", style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}