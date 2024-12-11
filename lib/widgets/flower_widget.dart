import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/classes/DBHandler.dart';

class FlowerWidget extends StatefulWidget {
  final Mood mood;
  final Function(Moods newMood) onMoodChanged;
  final bool disabled;

  const FlowerWidget(
      {super.key,
      required this.mood,
      required this.onMoodChanged,
      this.disabled = false});

  @override
  State<FlowerWidget> createState() => _FlowerWidgetState();
}

class _FlowerWidgetState extends State<FlowerWidget> {
  Moods _mood = Moods.good;
  Color color = Colors.red;
  String svgContent = '';
  String name = "";

  @override
  void initState() {
    super.initState();
    _mood = widget.mood.mood;
    _loadSvgFromAsset();
    _loadName();
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
    User? tmpUser = await DBHandler().getUserById(widget.mood.userId);
    setState(() {
      color = tmpUser?.flowerColor ?? Colors.red;
    });
    Color color2 = Color.fromRGBO(
      (color.red * 0.8).toInt(),
      (color.green * 0.8).toInt(),
      (color.blue * 0.8).toInt(),
      1.0,
    );
    rawSvgContent = rawSvgContent.replaceAll('fill="flowerColor"',
        'fill="#${color.value.toRadixString(16).substring(2)}"');
    rawSvgContent = rawSvgContent.replaceAll('fill="flowerColor2"',
        'fill="#${color2.value.toRadixString(16).substring(2)}"');
    return rawSvgContent;
  }

  void _flowerMoodChanged(Moods mood) {
    _mood = mood;
    _loadSvgFromAsset();
  }

  void _loadName() async {
    User? user = await DBHandler().getUserById(widget.mood.userId);
    setState(() {
      name = user?.name ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.disabled,
      child: GestureDetector(
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
        child: Column(
          children: [
            Container(
              color: const Color(0xFFAAD07C),
              width: 120,
              height: 100,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: svgContent.isEmpty
                    ? const SizedBox()
                    : SvgPicture.string(svgContent),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(name,
                style: TextStyle(
                  fontSize: widget.disabled ? 12 : 15,
                  fontWeight:
                      widget.disabled ? FontWeight.normal : FontWeight.bold,
                  color: color,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 8.0,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ],
                )),
          ],
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
