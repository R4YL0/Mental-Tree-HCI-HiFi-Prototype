import 'package:color_picker_field/color_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:mental_load/classes/User.dart';

class UserAddWidget extends StatefulWidget {
  const UserAddWidget({super.key});

  @override
  State<UserAddWidget> createState() => _UserAddWidgetState();
}

class _UserAddWidgetState extends State<UserAddWidget> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  // TextEditingController initialsController = TextEditingController();
  Color _color = Colors.blue;

  void onSubmitPress() async {
    if (_formKey.currentState!.validate()) {
      await User.create(name: nameController.text, flowerColor: _color);
      if (context.mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill input')),
      );
    }
  }

  void onChangedColor(List<Color> value) {
    setState(() {
      _color = value.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
        child: Center(
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
                          labelText: "Name",
                          hintText: "Awesome User"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    /* 
                    TextFormField(
                      controller: initialsController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Initials (max. 2 characters)",
                          hintText: "AU"),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length > 2) {
                          return 'Please enter your initials with a maximum of 2 characters';
                        }
                        return null;
                      },
                    ), */
                    ColorPickerFormField(
                      initialValue: const [],
                      defaultColor: Colors.blue,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxColors: 1,
                      decoration: const InputDecoration(
                        labelText: 'Colors',
                        helperText: 'Choose a color for your user',
                      ),
                      validator: (List<Color>? value) {
                        if (value!.isEmpty) {
                          return 'a minimum of 1 color is required';
                        }
                        return null;
                      },
                      onChanged: onChangedColor,
                    ),
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
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel")))
            ],
          )
        ],
      ),
    ));
  }
}
