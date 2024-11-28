import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mental_load/Screens/cards_screen.dart';
import 'package:mental_load/Screens/home_screen.dart';
import 'package:mental_load/Screens/diagrams_screen.dart';
import 'package:mental_load/Screens/swipable_card_screen.dart';
import '../constants/colors.dart';

class NavigatorScreen extends StatelessWidget {
  const NavigatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 50,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: AppColors.primary,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.white.withOpacity(0.1),
          animationDuration: const Duration(milliseconds: 100),
          destinations: const [
            NavigationDestination(
                icon: Icon(
                  Icons.style,
                  color: Colors.white,
                  size: 30,
                ),
                label: "Cards"),
            NavigationDestination(
                icon: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30,
                ),
                label: "Home"),
            NavigationDestination(
                icon: Icon(
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 30,
                ),
                label: "Diagrams"),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}


class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const CardsScreen(),
    const HomeScreen(),
    const DiagramsScreen(),
  ];
}
