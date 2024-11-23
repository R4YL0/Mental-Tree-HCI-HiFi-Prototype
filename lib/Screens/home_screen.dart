import 'package:flutter/material.dart';
import 'package:mental_load/Screens/settings_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/widgets/flower_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<Mood>> _getUserMoods() async {
    List<Mood> allUserMoods = [];
    List<User> allUsers = await DBHandler().getUsers();

    for (User currentUser in allUsers) {
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
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, right: 10, left: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                color: Colors.green,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                )),
            FutureBuilder<List<Mood>?>(
                future: _getUserMoods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    List<Mood> userMoods = snapshot.data ?? [];

                    return Wrap(
                      children: userMoods
                          .map((Mood currentUserMood) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: FlowerWidget(
                                mood: currentUserMood.mood,
                                onChanged: (Moods newMood) =>
                                    currentUserMood.mood = newMood,
                              ),
                            );
                          })
                          .toList()
                          .cast<Widget>(),
                    );
                  }
                })
          ]),
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
