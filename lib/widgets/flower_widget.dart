import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mental_load/classes/Mood.dart';

class FlowerWidget extends StatefulWidget {
  final Moods mood;
  final ValueChanged<Moods>? onChanged;

  const FlowerWidget({super.key, required this.mood, this.onChanged});

  @override
  State<FlowerWidget> createState() => _FlowerWidgetState();
}

class _FlowerWidgetState extends State<FlowerWidget> {
  Moods _mood = Moods.good;

  @override
  void initState() {
    super.initState();
    _mood = widget.mood;
  }

  @override
  Widget build(BuildContext context) {
    String moodName = _mood.name;
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return MoodDialog(
                  mood: _mood,
                  onChangedMood: (newMood) {
                    ValueChanged<Moods>? onChangedMood = widget.onChanged;
                    if (onChangedMood is ValueChanged<Moods>) {
                      onChangedMood(newMood);
                    }
                    setState(() => _mood = newMood);
                  });
            });
      },
      child: SvgPicture.asset('lib/assets/state_$moodName.svg',
          semanticsLabel: 'flower in state $moodName'),
    );
  }
}

class MoodDialog extends StatefulWidget {
  final Moods mood;
  final ValueChanged<Moods> onChangedMood;

  const MoodDialog(
      {super.key, required this.mood, required this.onChangedMood});

  @override
  State<MoodDialog> createState() => _MoodDialogState();
}

class _MoodDialogState extends State<MoodDialog> {
  late Moods mood;
  final double iconSize = 50;

  @override
  void initState() {
    super.initState();

    mood = widget.mood;
  }

  void onPressedIcon(Moods changedMood) {
    widget.onChangedMood(changedMood);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: const Text("Choose your mood"), children: [
      Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: iconSize,
              isSelected: widget.mood == Moods.good,
              onPressed: () {
                onPressedIcon(Moods.good);
              },
              icon: const Icon(Icons.sentiment_satisfied),
            ),
            IconButton(
                iconSize: iconSize,
                isSelected: widget.mood == Moods.mid,
                onPressed: () {
                  onPressedIcon(Moods.mid);
                },
                icon: const Icon(Icons.sentiment_neutral)),
            IconButton(
                iconSize: iconSize,
                isSelected: widget.mood == Moods.bad,
                onPressed: () {
                  onPressedIcon(Moods.bad);
                },
                icon: const Icon(Icons.sentiment_dissatisfied))
          ],
        ),
      ),
    ]);
  }
}
