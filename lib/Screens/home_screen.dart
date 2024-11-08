import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MainPartHomeScreen(),
          NavBarHomeScreen(),
        ],
      ),
    );
  }
}

class MainPartHomeScreen extends StatelessWidget {
  const MainPartHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(),
    );
  }
}

class NavBarHomeScreen extends StatelessWidget {
  const NavBarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      height: 50,
      child: const Row(
        children: [
          NavBarItemHomeScreen(icon: Icons.style),
          NavBarItemHomeScreen(icon: Icons.home),
          NavBarItemHomeScreen(icon: Icons.bar_chart),
        ],
      ),
    );
  }
}

class NavBarItemHomeScreen extends StatelessWidget {
  final IconData icon;
  const NavBarItemHomeScreen({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Icon(icon),
      )
    );
  }
}