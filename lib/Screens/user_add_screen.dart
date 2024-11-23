import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mental_load/classes/User.dart';

class UserAddScreen extends StatefulWidget {
  const UserAddScreen({super.key});

  @override
  State<UserAddScreen> createState() => _UserAddScreenState();
}

class _UserAddScreenState extends State<UserAddScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  Color _pickerColor = Colors.blue;
  Color _currentColor = Colors.blue;

  void onSubmitPress() async {
    if (_formKey.currentState!.validate()) {
      await User.create(name: nameController.text, flowerColor: _currentColor);
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

  onPressedColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _pickerColor,
            onColorChanged: _changeColor,
            enableAlpha: false,
          ),
          // Use Block color picker if just a selection of colors wanted:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
        ),
        actions: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Text("New user setup"),
          Expanded(
            child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
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
                    FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: _currentColor),
                        onPressed: () {
                          onPressedColor(context);
                        },
                        child: const Text("Change color"))
                  ],
                )),
          ),
          Row(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                      onPressed: onSubmitPress, child: const Text("Done"))),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
