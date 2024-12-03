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
import 'package:mental_load/classes/Task.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/strings.dart';
import 'package:mental_load/widgets/blossom_dialog_widget.dart';
import 'package:mental_load/widgets/flower_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> _users = [];
  Map<Category, Map<int, _Blossom>> blossomData = {
    //category -> userId -> blossom infos
    Category.Cleaning: {},
    Category.Laundry: {},
    Category.Cooking: {},
    Category.Childcare: {},
    Category.Outdoor: {},
    Category.Admin: {},
  };
  /* List<MapEntry<int, _Blossom>> cleaningEntries = [];
  List<MapEntry<int, _Blossom>> laundryEntries = [];
  List<MapEntry<int, _Blossom>> cookingEntries = [];
  List<MapEntry<int, _Blossom>> outdoorEntries = [];
  List<MapEntry<int, _Blossom>> childcareEntries = [];
  List<MapEntry<int, _Blossom>> adminEntries = [];*/
  /*Map<String, List<_Position>> positions = {
    Category.Cleaning: [_Position(60, 400), _Position(80, 450), _Position(130, 460), _Position(160, 420), _Position(200, 370), _Position(120, 370)],
    Category.Laundry: [_Position(120, 320), _Position(190, 320), _Position(220, 280), _Position(160, 240), _Position(50, 280), _Position(60, 330)],
    Category.Cooking: [_Position(40, 120), _Position(70, 180), _Position(90, 140), _Position(140, 190), _Position(160, 140), _Position(90, 80)],
    Category.Childcare: [_Position(-35, 205), _Position(-30, 130), _Position(-60, 90), _Position(-160, 100), _Position(-130, 170), _Position(-100, 130)],
    Category.Outdoor: [_Position(-120, 200), _Position(-120, 270), _Position(-40, 280), _Position(-60, 230), _Position(-200, 240), _Position(-50, 330)],
    Category.Admin: [_Position(-130, 340), _Position(-50, 460), _Position(-60, 400), _Position(-180, 360), _Position(-170, 420), _Position(-120, 430)]
  };*/
  Map<int, String> blossomStrings = {}; //userId -> blossom string
  Map<Category, int> angles = {
    Category.Cleaning: 210,
    Category.Laundry: 150,
    Category.Cooking: 90,
    Category.Childcare: 30,
    Category.Outdoor: 330,
    Category.Admin: 270,
  };
  double screenWidth = 0;
  double screenPaddingTop = 0;
  int curUserId = 0;

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
    final prefs = await SharedPreferences.getInstance();

    List<User> allUsers = await DBHandler().getUsers();

    List<AssignedTask> completedTasks = await AssignedTask.getCompletedTasks();
    Map<Category, Map<int, _Blossom>> data = {
      Category.Cleaning: {},
      Category.Laundry: {},
      Category.Cooking: {},
      Category.Outdoor: {},
      Category.Childcare: {},
      Category.Admin: {}
    };

    Map<int, String> newBlossomStrings = blossomStrings;
    for (AssignedTask tmp in completedTasks) {
      if (tmp.finishDate != null &&
          tmp.finishDate!.difference(DateTime.now()).inDays < 30) {
        if (data.containsKey(tmp.task.category)) {
          if (data[tmp.task.category]!.containsKey(tmp.user.userId)) {
            data[tmp.task.category]![tmp.user.userId]!.count =
                data[tmp.task.category]![tmp.user.userId]!.count + 1;

            //print("${tmp.task.category.name} - ${tmp.user.userId}: x-${data[tmp.task.category.name]![tmp.user.userId]!.pos.x}, y-${data[tmp.task.category.name]![tmp.user.userId]!.pos.y}, count: ${data[tmp.task.category.name]![tmp.user.userId]!.count}");
          } else {
            /* load blossom svg */
            Color tmpColor = tmp.user.flowerColor;
            String svgContent =
                await rootBundle.loadString('lib/assets/blossom.svg');
            svgContent = svgContent.replaceAll('stroke="blossomColor"',
                'fill="#${tmpColor.value.toRadixString(16).substring(2)}"');
            newBlossomStrings[tmp.user.userId] = svgContent;
            /* load position */
            int maxRadius = ((screenWidth - 180) / 2).toInt();
            int r = Random().nextInt(maxRadius) +
                80; //random number between 0 and maxRadius
            double angle = (Random().nextInt(41) + 10) +
                (angles[tmp.task.category] ?? 0)
                    .toDouble(); //40 degree random angle
            angle = (math.pi / 180) * angle; //convert degrees to radians
            //double angle = Random().nextDouble()*math.pi/3+((math.pi/180)*(angles[tmp.task.category.name]?? 0)); //360 = 2pi, 180 = pi, 1 = pi/180
            double x = r * cos(angle);
            double y = r * sin(angle);
            /* */
            data[tmp.task.category]![tmp.user.userId] = _Blossom(
                _Position((screenWidth / 2 + x).toInt(),
                    (screenWidth / 2 + screenPaddingTop + 20 - y).toInt()),
                1,
                svgContent);
            //print("${tmp.task.category.name} - ${tmp.user.userId}: x-${(screenWidth/2+x).toInt()}, y-${(screenWidth/2+screenPaddingTop+50-y).toInt()}, count: ${1}");
          }
        }
      }
    }
    setState(() {
      curUserId = prefs.getInt(constCurrentUserId) ?? 0;
      blossomData = data;
      _users = allUsers;
      blossomStrings = newBlossomStrings;
      /*cleaningEntries = blossomData[Category.Cleaning]!.entries.toList();
      laundryEntries = blossomData[Category.Laundry]!.entries.toList();
      cookingEntries = blossomData[Category.Cooking]!.entries.toList();
      outdoorEntries = blossomData[Category.Outdoor]!.entries.toList();
      childcareEntries = blossomData[Category.Childcare]!.entries.toList();
      adminEntries = blossomData[Category.Admin]!.entries.toList();*/
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

  void _onTapBlossom(Category category) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return BlossomDialogWidget(category: category);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFAAD07C),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.8, 0.8],
              colors: [
                const Color(0xFFCFFAFF),
                const Color(0xFFAAD07C),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(children: [
                    Names(users: _users, blossomStrings: blossomStrings),
                    const TreeHomeScreen(),
                    FlowersHomeScreen(users: _users, curUserId: curUserId),
                  ]),
                  for (Category tmpCategory in Category.values)
                    for (int i = 0;
                        i < blossomData[tmpCategory]!.entries.toList().length;
                        i++)
                      Positioned(
                          left: blossomData[tmpCategory]!
                                  .entries
                                  .toList()[i]
                                  .value
                                  .pos
                                  .x
                                  .toDouble() -
                              20,
                          top: blossomData[tmpCategory]!
                                  .entries
                                  .toList()[i]
                                  .value
                                  .pos
                                  .y
                                  .toDouble() -
                              20,
                          child: Transform.scale(
                            scale: min(
                                0.2 +
                                    blossomData[tmpCategory]!
                                            .entries
                                            .toList()[i]
                                            .value
                                            .count *
                                        0.05,
                                1.2),
                            child: GestureDetector(
                              onTap: () => _onTapBlossom(tmpCategory),
                              child: SvgPicture.string(blossomData[tmpCategory]!
                                  .entries
                                  .toList()[i]
                                  .value
                                  .svg),
                            ),
                          )),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.settings),
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
            _myInit();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop);
  }
}

class Points extends StatelessWidget {
  const Points({super.key});

  @override
  Widget build(BuildContext context) {
    /**/
    final width = MediaQuery.sizeOf(context).width;
    final centerX = width / 2;
    final centerY = width / 2 + MediaQuery.of(context).padding.top + 20;

    // Generate 6 points (60° apart)
    final List<Widget> points = [];
    for (int r = 0; r < 200; r++) {
      for (int i = 0; i < 6; i++) {
        final angle = (2 * pi / 6) * i + (pi / 6); // Calculate angle in radians
        final dx = centerX + r * cos(angle); // X position
        final dy = centerY + r * sin(angle); // Y position

        points.add(
          Positioned(
            left: dx,
            top: dy,
            child: Container(
              color: Colors.black,
              height: 2,
              width: 2,
            ),
          ),
        );
      }
    }
    return Stack(children: points);
  }
}

class _Blossom {
  final _Position pos;
  int count;
  final String svg;

  _Blossom(this.pos, this.count, this.svg);
}

class _Position {
  final int x;
  final int y;

  _Position(this.x, this.y);
}

class TreeHomeScreen extends StatelessWidget {
  const TreeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SvgPicture.asset(
              'lib/assets/tree_3_branches_with_category_names_5.svg',
              width: constraints.maxWidth,
              fit: BoxFit.contain,
            );
          },
        ),
      ],
    );
  }
}

class FlowersHomeScreen extends StatefulWidget {
  final List<User> users;
  final int curUserId;

  const FlowersHomeScreen(
      {super.key, required this.users, required this.curUserId});

  @override
  State<FlowersHomeScreen> createState() => _FlowersHomeScreenState();
}

class _FlowersHomeScreenState extends State<FlowersHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<Mood>> _getUserMoods() async {
    List<Mood> allUserMoods = [];

    for (User currentUser in widget.users) {
      Mood? latestMoodObjNull =
          await DBHandler().getLatestMoodByUserId(currentUser.userId);
      if (latestMoodObjNull is Mood) {
        allUserMoods.add(latestMoodObjNull);
      }
    }
    return allUserMoods;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Mood>>(
        future: _getUserMoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            List<Mood> moods = snapshot.data ?? [];

            return Stack(
              children: [
                Container(
                  color: const Color(0xFFAAD07C),
                  height: max(
                      MediaQuery.sizeOf(context).height -
                          560 -
                          MediaQuery.of(context).padding.top,
                      ((moods.length) /
                                  ((MediaQuery.sizeOf(context).width / 120)
                                      .toInt()))
                              .toInt() *
                          120.0),
                  width: MediaQuery.sizeOf(context).width,
                ),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      for (Mood currentMood in moods)
                        FlowerWidget(
                          mood: currentMood,
                          onMoodChanged: (Moods newMood) async {
                            Mood moodToSave = await Mood.create(
                                userId: currentMood.userId,
                                date: DateTime.now(),
                                mood: newMood);
                            DBHandler().saveMood(moodToSave);
                          },
                          disabled: widget.curUserId != currentMood.userId,
                        ),
                    ],
                  ),
                ),
              ],
            );
          }
        });
  }
}

class Names extends StatelessWidget {
  final List<User> users;
  final Map<int, String> blossomStrings;
  const Names({super.key, required this.users, required this.blossomStrings});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (User tmpUser in users)
          if (blossomStrings[tmpUser.userId] == null)
            SizedBox()
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  alignment: Alignment.centerRight,
                  scale: 0.5,
                  child: SvgPicture.string(blossomStrings[tmpUser.userId]!),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  tmpUser.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
      ],
    );
  }
}
