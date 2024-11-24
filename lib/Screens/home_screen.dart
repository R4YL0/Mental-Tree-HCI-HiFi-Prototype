import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mental_load/Screens/settings_screen.dart';
import 'package:mental_load/classes/AssignedTask.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/widgets/flower_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Mood> userMoods = [];
  Map<String, Map<int, int>> blossomData = {};
  List<MapEntry<int, int>> cleaningEntries = [];
  List<MapEntry<int, int>> laundryEntries = [];
  List<MapEntry<int, int>> cookingEntries = [];
  List<MapEntry<int, int>> outdoorEntries = [];
  List<MapEntry<int, int>> childcareEntries = [];
  List<MapEntry<int, int>> adminEntries = [];

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  _myInit() async {
    _getUserMoods();
    _getTasks();
  }

  void _getUserMoods() async {
    List<Mood> allUserMoods = [];
    List<User> allUsers = await DBHandler().getUsers();

    for (User currentUser in allUsers) {
      Mood? latestMoodObjNull =
          await DBHandler().getLatestMoodByUserId(currentUser.userId);
      if (latestMoodObjNull is Mood) {
        allUserMoods.add(latestMoodObjNull);
      }
    }
    setState(() {
      userMoods = allUserMoods;
      cleaningEntries = blossomData["Cleaning"]!.entries.toList();
      laundryEntries = blossomData["Laundry"]!.entries.toList();
      cookingEntries = blossomData["Cooking"]!.entries.toList();
      outdoorEntries = blossomData["Outdoor"]!.entries.toList();
      childcareEntries = blossomData["Childcare"]!.entries.toList();
      adminEntries = blossomData["Admin"]!.entries.toList();
    });
  }

  void _getTasks() async {
    List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks();
    Map<String, Map<int, int>> data = {"Cleaning": {}, "Laundry": {}, "Cooking": {}, "Outdoor": {}, "Childcare": {}, "Admin": {}};
    for(AssignedTask tmp in completedTasks){
      if(data.containsKey(tmp.task.category.name)){
        if(data[tmp.task.category.name]!.containsKey(tmp.user.userId)){
          data[tmp.task.category.name]![tmp.user.userId] = (data[tmp.task.category.name]![tmp.user.userId])! + 1;
        }else{
          data[tmp.task.category.name]![tmp.user.userId] = 1;
        }
      }
    }
    setState(() {
      blossomData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFCFFAFF),
        body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    const TreeHomeScreen(),
                    FlowersHomeScreen(moods: userMoods),
                  ]
                ),
                for(int i=0;i<cleaningEntries.length; i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-Random().nextInt(181), top: Random().nextInt(101)+380, child: Transform.scale(scale: min(0.2 + cleaningEntries[i].value*0.05, 1.2), child: SvgPicture.asset('lib/assets/blossom.svg'))),
                for(int i=0;i<laundryEntries.length; i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-(Random().nextInt(151)+100), top: Random().nextInt(151)+200, child: Transform.scale(scale: min(0.2 + cleaningEntries[i].value*0.05, 1.2), child: SvgPicture.asset('lib/assets/blossom.svg'))),
                for(int i=0;i<cookingEntries.length; i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-(Random().nextInt(151)), top: Random().nextInt(151)+50, child: Transform.scale(scale: 0.2 + cookingEntries[i].value*0.1, child: SvgPicture.asset('lib/assets/blossom.svg'))),
                for(int i=0;i<childcareEntries.length; i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2+(Random().nextInt(121)), top: Random().nextInt(81)+100, child: Transform.scale(scale: 0.2 + childcareEntries[i].value*0.1, child: SvgPicture.asset('lib/assets/blossom.svg'))),
                for(int i=0;i<outdoorEntries.length; i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2+(Random().nextInt(171)+10), top: Random().nextInt(101)+200, child: Transform.scale(scale: 0.2 + outdoorEntries[i].value*0.1, child: SvgPicture.asset('lib/assets/blossom.svg'))),
                for(int i=0;i<adminEntries.length; i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2+(Random().nextInt(171)+10), top: Random().nextInt(101)+350, child: Transform.scale(scale: 0.2 + adminEntries[i].value*0.1, child: SvgPicture.asset('lib/assets/blossom.svg'))),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.settings),
          onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()))
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop);
  }
}

class TreeHomeScreen extends StatelessWidget {
  const TreeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: SvgPicture.asset('lib/assets/tree_3_branches_with_category_names.svg'),
    );
  }
}

class FlowersHomeScreen extends StatefulWidget {
  final List<Mood> moods;
  const FlowersHomeScreen({super.key, required this.moods});

  @override
  State<FlowersHomeScreen> createState() => _FlowersHomeScreenState();
}

class _FlowersHomeScreenState extends State<FlowersHomeScreen> {
  //List<User> users = [];
  //Map<int, Color> colors = {};

  @override
  void initState() {
    super.initState();
    //_myInit();
  }

  /*_myInit() async {
    List<User> allUsers = await DBHandler().getUsers();
    for(User u in allUsers){
      colors[u.userId] = u.flowerColor;
    }
    setState(() {users = allUsers;});
  }*/

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFAAD07C),
          height: 220,
          width: MediaQuery.sizeOf(context).width,
        ),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              for(Mood currentMood in widget.moods)
                FlowerWidget(
                  //flowerColor: colors[currentMood.userId] ?? Colors.red,
                  mood: currentMood, 
                  onMoodChanged: (Moods newMood) async {
                    Mood moodToSave = await Mood.create(userId: currentMood.userId, date: DateTime.now(), mood: newMood, color: currentMood.color);
                    DBHandler().saveMood(moodToSave);
                    /*List<Mood> tmpMoods = await DBHandler().getMoods();
                    print("------------------");
                    for(Mood tmpM in tmpMoods){
                      print("mood: ${tmpM.mood.toString()} user: ${tmpM.userId.toString()} date: ${tmpM.date.toString()}");
                    }*/
                  }, 
                ),
            ],
          ),
        ),
      ],
    );
  }
}