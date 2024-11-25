import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/classes/DBHandler.dart';

class FlowerWidget extends StatefulWidget {
  final Mood mood;
  final Function(Moods newMood) onMoodChanged;

  const FlowerWidget({super.key, required this.mood, required this.onMoodChanged});

  @override
  State<FlowerWidget> createState() => _FlowerWidgetState();
}

class _FlowerWidgetState extends State<FlowerWidget> {
  Moods _mood = Moods.good;
  String svgContent = '';

  @override
  void initState() {
    super.initState();
    _mood = widget.mood.mood;
    _loadSvgFromAsset();
  }

  Future<void> _loadSvgFromAsset() async {
    String svgAssetPath = 'lib/assets/flower_${_mood.name}.svg';

    //read SVG content from asset file
    String rawSvgContent = await rootBundle.loadString(svgAssetPath);

    String modifiedSvgContent = await _modifySvgContent(rawSvgContent);

    setState(() {
      svgContent = modifiedSvgContent;
    });
  }

  Future<String> _modifySvgContent(String rawSvgContent) async {
    User? tmpUser = await DBHandler().getUserByUserId(widget.mood.userId);
    Color color = tmpUser?.flowerColor ?? Colors.red;
    Color color2 = Color.fromRGBO((color.red * 0.8).toInt(),(color.green * 0.8).toInt(),(color.blue * 0.8).toInt(),1.0,);
    rawSvgContent = rawSvgContent.replaceAll('fill="flowerColor"',
        'fill="#${color.value.toRadixString(16).substring(2)}"');
    rawSvgContent = rawSvgContent.replaceAll('fill="flowerColor2"',
        'fill="#${color2.value.toRadixString(16).substring(2)}"');
    return rawSvgContent;
  }

  void _flowerMoodChanged(Moods mood){
    _mood = mood;
    _loadSvgFromAsset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return MoodDialog(
              mood: _mood,
              onChangedMood: (newMood) {
                widget.onMoodChanged(newMood);
                _flowerMoodChanged(newMood);
              });
          });
      },
      child: Container(
        color: const Color(0xFFAAD07C),
        width: 120,
        height: 100,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: svgContent.isEmpty ? const SizedBox() : SvgPicture.string(svgContent),
        ),
      ),
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
