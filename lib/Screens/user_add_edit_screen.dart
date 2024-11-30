import 'package:flutter/material.dart';
import 'package:color_picker_field/color_picker_field.dart';
import 'package:mental_load/Screens/home_screen.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/Mood.dart';
import 'package:mental_load/classes/User.dart';
import 'package:mental_load/constants/colors.dart';
import 'package:mental_load/widgets/flower_widget.dart';
import 'package:mental_load/widgets/tutorial_widget.dart';

class UserAddEditScreen extends StatefulWidget {
  final User? user;

  const UserAddEditScreen({super.key, this.user});

  @override
  State<UserAddEditScreen> createState() => _UserAddEditScreenState();
}

class _UserAddEditScreenState extends State<UserAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Color _pickerColor = Colors.blue;
  Color _currentColor = Colors.blue;
  String _title = "New user";

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.user?.name);

    super.initState();
    if (widget.user != null) {
      final Color newColor = widget.user?.flowerColor ?? Colors.blue;
      setState(() {
        _pickerColor = _currentColor = newColor;
        _title = "Edit user";
      });
    }
  }

  void _onSubmitPress() async {
    if (_formKey.currentState!.validate()) {
      if (widget.user == null) {
        final newUser = await User.create(
            name: _nameController.text, flowerColor: _currentColor);

        await Mood.create(
            userId: newUser.userId, mood: Moods.good, date: DateTime.now());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('A tutorial can be started from the settings.')),
          );
        }
      } else {
        widget.user?.name = _nameController.text;
        widget.user?.flowerColor = _currentColor;
      }

      if (context.mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill input')),
      );
    }
  }

  void _changeColor(Color newColor) {
    setState(() => _pickerColor = newColor);
  }

  _onPressedColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            currentColor: _pickerColor,
            onChange: _changeColor,
          ),
          // Use Block color picker if just a selection of colors wanted:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Done'),
            onPressed: () {
              setState(() => _currentColor = _pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onPressedDelete() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: const Text("Do you really want to delete this user?"),
              actions: [
                ElevatedButton(
                    onPressed: _onPressedDeleteFinal,
                    child: const Text("Delete finally")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"))
              ],
            ));
  }

  void _onPressedDeleteFinal() async {
    if (widget.user is User) {
      int userId = widget.user?.userId as int;
      await DBHandler().removeUser(userId);
    }
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
          actions: [
            IconButton(
                onPressed: _onPressedDelete,
                icon: const Icon(Icons.delete_forever))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: "Nickname (max. 8 characters)",
                              hintText: "Nicky"),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length > 8) {
                              return 'Please enter your nickname with maximum of 8 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                            style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: AppColors.primary.withOpacity(0.2),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: _currentColor,
                                minimumSize: const Size(double.infinity, 50)),
                            onPressed: () {
                              _onPressedColor(context);
                            },
                            child: const Text("change color")),
                      ],
                    )),
              ),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                          onPressed: _onSubmitPress,
                          child: const Text("Done"))),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Cancel")))
                ],
              )
            ],
          ),
        ));
  }
}
