import 'dart:io';
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<User> users = [];
  Map<String, Map<int, _Blossom>> blossomData = {}; //category -> userId -> blossom infos
 /* List<MapEntry<int, _Blossom>> cleaningEntries = [];
  List<MapEntry<int, _Blossom>> laundryEntries = [];
  List<MapEntry<int, _Blossom>> cookingEntries = [];
  List<MapEntry<int, _Blossom>> outdoorEntries = [];
  List<MapEntry<int, _Blossom>> childcareEntries = [];
  List<MapEntry<int, _Blossom>> adminEntries = [];*/
  Map<String, List<_Position>> positions = {
    "Cleaning": [_Position(60, 400), _Position(80, 450), _Position(130, 460), _Position(160, 420), _Position(200, 370), _Position(120, 370)],
    "Laundry": [_Position(120, 320), _Position(190, 320), _Position(220, 280), _Position(160, 240), _Position(50, 280), _Position(60, 330)],
    "Cooking": [_Position(40, 120), _Position(70, 180), _Position(90, 140), _Position(140, 190), _Position(160, 140), _Position(90, 80)],
    "Childcare": [_Position(-35, 205), _Position(-30, 130), _Position(-60, 90), _Position(-160, 100), _Position(-130, 170), _Position(-100, 130)],
    "Outdoor": [_Position(-120, 200), _Position(-120, 270), _Position(-40, 280), _Position(-60, 230), _Position(-200, 240), _Position(-50, 330)],
    "Admin": [_Position(-130, 340), _Position(-50, 460), _Position(-60, 400), _Position(-180, 360), _Position(-170, 420), _Position(-120, 430)]
  };
  Map<int, String> blossomStrings = {}; //userId -> blossom string
  Map<String, int> angles = {
    "Cleaning": 210,
    "Laundry": 150,
    "Cooking": 90,
    "Childcare": 30,
    "Outdoor": -30,
    "Admin": -90,
  };
  double screenWidth = 0;
  double screenPaddingTop = 0;

  @override
  void initState() {
    super.initState();
    _myInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.sizeOf(context).width;
    screenPaddingTop = MediaQuery.of(context).padding.top;
  }

  _myInit() async {
    _getUserMoods();
    _initializeData();
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
      users = allUsers;
    });
  }

  void _initializeData() async {
    List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks();
    Map<String, Map<int, _Blossom>> data = {"Cleaning": {}, "Laundry": {}, "Cooking": {}, "Outdoor": {}, "Childcare": {}, "Admin": {}};
    for(AssignedTask tmp in completedTasks){
      if(data.containsKey(tmp.task.category.name)){
        if(data[tmp.task.category.name]!.containsKey(tmp.user.userId)){
          data[tmp.task.category.name]![tmp.user.userId]!.count = data[tmp.task.category.name]![tmp.user.userId]!.count + 1;
        }else{
          /* load blossom svg */
          Color tmpColor = await DBHandler().getUserByUserId(tmp.user.userId).then((user) {return user?.flowerColor ?? Colors.red;});
          String svgContent = await rootBundle.loadString('lib/assets/blossom.svg');
          svgContent = svgContent.replaceAll('stroke="blossomColor"','fill="#${tmpColor.value.toRadixString(16).substring(2)}"');
          blossomStrings[tmp.user.userId] = svgContent;
          /* load position */
          int maxRadius = ((screenWidth-10)/2).toInt();
          int r = Random().nextInt(maxRadius); //random number between 0 and maxRadius
          double angle = Random().nextDouble()*math.pi/3+((math.pi/180)*(angles[tmp.task.category.name]?? 0)); //360 = 2pi, 180 = pi, 1 = pi/180
          double x = r * cos(angle);
          double y = r * sin(angle);
          /* */
          data[tmp.task.category.name]![tmp.user.userId] = _Blossom(_Position((screenWidth/2+x).toInt(), (screenWidth/2+screenPaddingTop+50-y).toInt()), 1, svgContent);
        }
      }
    }
    setState(() {
      blossomData = data;
      /*cleaningEntries = blossomData["Cleaning"]!.entries.toList();
      laundryEntries = blossomData["Laundry"]!.entries.toList();
      cookingEntries = blossomData["Cooking"]!.entries.toList();
      outdoorEntries = blossomData["Outdoor"]!.entries.toList();
      childcareEntries = blossomData["Childcare"]!.entries.toList();
      adminEntries = blossomData["Admin"]!.entries.toList();*/
    });
  }

  /*void _initializeUserBlossoms() async {
    List<User> allUsers = await DBHandler().getUsers();
    blossomStrings.clear();
    for(User tmpU in allUsers){
      Color tmpColor = await DBHandler().getUserByUserId(tmpU.userId).then((user) {return user?.flowerColor ?? Colors.red;});
      String svgContent = await rootBundle.loadString('lib/assets/blossom.svg');
      svgContent = svgContent.replaceAll('stroke="blossomColor"','fill="#${tmpColor.value.toRadixString(16).substring(2)}"');
      blossomStrings[tmpU.userId] = svgContent;
    }
    setState(() {});
  }*/

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
                    Names(users: users, blossomStrings: blossomStrings),
                    const TreeHomeScreen(),
                    FlowersHomeScreen(moods: userMoods),
                  ]
                ),
                //Positioned(left: MediaQuery.sizeOf(context).width/2, top: MediaQuery.sizeOf(context).width/2+MediaQuery.of(context).padding.top+50, child: Container(color:Colors.black, height: 5, width: 5,)),
                //Positioned(left: MediaQuery.sizeOf(context).width/2+x, top: MediaQuery.sizeOf(context).width/2+MediaQuery.of(context).padding.top+50-y, child: Container(color:Colors.black, height: 5, width: 5,)),
                for(int i=0;i<blossomData["Cleaning"]!.entries.toList().length;i++)
                  Positioned(left: blossomData["Cleaning"]!.entries.toList()[i].value.pos.x.toDouble(), top: blossomData["Cleaning"]!.entries.toList()[i].value.pos.y.toDouble(), child: Transform.scale(scale: min(0.2 + blossomData["Cleaning"]!.entries.toList()[i].value.count*0.05, 1.2), child: SvgPicture.string(blossomData["Cleaning"]!.entries.toList()[i].value.svg))),
                /*for(int i=0;i<laundryEntries.length;i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-positions["Laundry"]![i].x, top: positions["Laundry"]![i].y.toDouble(), child: Transform.scale(scale: min(0.2 + laundryEntries[i].value*0.05, 1.2), child: blossomStrings[laundryEntries[i].key]?.isEmpty ?? true ? const SizedBox() : SvgPicture.string(blossomStrings[laundryEntries[i].key]!))),
                for(int i=0;i<cookingEntries.length;i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-positions["Cooking"]![i].x, top: positions["Cooking"]![i].y.toDouble(), child: Transform.scale(scale: min(0.2 + cookingEntries[i].value*0.05, 1.2), child: blossomStrings[cookingEntries[i].key]?.isEmpty ?? true ? const SizedBox() : SvgPicture.string(blossomStrings[cookingEntries[i].key]!))),
                for(int i=0;i<childcareEntries.length;i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-positions["Childcare"]![i].x, top: positions["Childcare"]![i].y.toDouble(), child: Transform.scale(scale: min(0.2 + childcareEntries[i].value*0.05, 1.2), child: blossomStrings[childcareEntries[i].key]?.isEmpty ?? true ? const SizedBox() : SvgPicture.string(blossomStrings[childcareEntries[i].key]!))),
                for(int i=0;i<outdoorEntries.length;i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-positions["Outdoor"]![i].x, top: positions["Outdoor"]![i].y.toDouble(), child: Transform.scale(scale: min(0.2 + outdoorEntries[i].value*0.05, 1.2), child: blossomStrings[outdoorEntries[i].key]?.isEmpty ?? true ? const SizedBox() : SvgPicture.string(blossomStrings[outdoorEntries[i].key]!))),
                for(int i=0;i<adminEntries.length;i++)
                  Positioned(left: MediaQuery.sizeOf(context).width/2-positions["Admin"]![i].x, top: positions["Admin"]![i].y.toDouble(), child: Transform.scale(scale: min(0.2 + adminEntries[i].value*0.05, 1.2), child: blossomStrings[adminEntries[i].key]?.isEmpty ?? true ? const SizedBox() : SvgPicture.string(blossomStrings[adminEntries[i].key]!))),*/
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.settings),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            setState(() {});
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop);
  }
}

class _Blossom{
  final _Position pos;
  int count;
  final String svg;

  _Blossom(this.pos, this.count, this.svg);
}

class _Position{
  final int x;
  final int y;

  _Position(this.x, this.y);
}

class TreeHomeScreen extends StatelessWidget {
  const TreeHomeScreen({super.key});

  @override
Widget build(BuildContext context) {
  return Container(
    color: Colors.red,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SvgPicture.asset(
              'lib/assets/tree_3_branches_with_category_names.svg',
              width: constraints.maxWidth,
              fit: BoxFit.contain,
            );
          },
        ),
      ],
    ),
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFAAD07C),
          height: max(MediaQuery.sizeOf(context).height-560-MediaQuery.of(context).padding.top, ((widget.moods.length)/((MediaQuery.sizeOf(context).width/120).toInt())).toInt()*120.0),
          width: MediaQuery.sizeOf(context).width,
        ),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              for(Mood currentMood in widget.moods)
                FlowerWidget(
                  mood: currentMood, 
                  onMoodChanged: (Moods newMood) async {
                    Mood moodToSave = await Mood.create(userId: currentMood.userId, date: DateTime.now(), mood: newMood);
                    DBHandler().saveMood(moodToSave);
                  }, 
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class Names extends StatelessWidget {
  final List<User> users;
  final Map<int, String> blossomStrings;
  const Names({super.key, required this.users, required this.blossomStrings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: double.infinity,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for(User tmpUser in users)
              Row(
                children: [
                  Transform.scale(
                    alignment: Alignment.centerRight,
                    scale: 0.5,
                    child: blossomStrings[tmpUser.userId] == null ? const SizedBox() : SvgPicture.string(blossomStrings[tmpUser.userId]!),
                  ),
                  const SizedBox(width: 5,),
                  Text(tmpUser.name, style: const TextStyle(fontSize: 12),),
                ],
              ),
          ],
        ),
      ),
    );
  }
}