import 'package:flutter/material.dart';
import 'package:mental_load/classes/DBHandler.dart';
import 'package:mental_load/classes/User.dart';

class UserAddWidget extends StatefulWidget {
  const UserAddWidget({super.key});

  @override
  State<UserAddWidget> createState() => _UserAddWidgetState();
}

class _UserAddWidgetState extends State<UserAddWidget> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController initialsController = TextEditingController();

  void onSubmitPress() async {
    if (_formKey.currentState!.validate()) {
      User newUser = await User.create(
          name: nameController.text, flowerColor: Colors.blue);
      await DBHandler().saveUser(newUser);
      if (context.mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill input')),
      );
    }
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
