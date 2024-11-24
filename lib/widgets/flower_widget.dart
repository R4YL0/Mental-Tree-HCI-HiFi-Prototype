import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String svgContent = '';

  @override
  void initState() {
    super.initState();
    _mood = widget.mood;
    _loadSvgFromAsset();
  }

  Future<void> _loadSvgFromAsset() async {
    String svgAssetPath = 'lib/assets/flower_${_mood.name}.svg';

    //read SVG content from asset file
    String rawSvgContent = await rootBundle.loadString(svgAssetPath);

    String modifiedSvgContent = _modifySvgContent(rawSvgContent);

    setState(() {
      svgContent = modifiedSvgContent;
    });
  }

  String _modifySvgContent(String rawSvgContent) {
    Color color = Colors.orange;
    Color color2 = const Color.fromARGB(255, 235, 141, 0);
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
                  onChangedMood: (mood) {_flowerMoodChanged(mood);});
            });
      },
      child: Container(
        color: Color(0xFFAAD07C),
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
