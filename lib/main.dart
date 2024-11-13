import 'package:flutter/material.dart';
import 'package:mental_load/Screens/navigator_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mental Tree',
      debugShowCheckedModeBanner: false,
      home: NavigatorScreen(),
    );
  }
}
