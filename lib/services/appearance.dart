import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/UserEntity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../entity/animal.dart';
import '../managers/theme_Manager.dart';

class Appearance extends StatefulWidget {
  @override
  _AppearanceState createState() => _AppearanceState();
}

class _AppearanceState extends State<Appearance> {
  double fontSize = 10;
  int themeMode = 0; // 0 light, 1  dark

  @override
  void initState() {
    super.initState();
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    themeManager.fetchUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    final animalEntity = Provider.of<Animal>(context, listen: true);
    return AlertDialog(
      title: Text(
        "Appearance Settings",
        style: TextStyle(
          fontSize: themeManager.fontSize * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "App mode",
                  style: TextStyle(
                    fontSize: themeManager.fontSize * 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //light
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.light_mode),
                  onTap: () {
                    themeManager.updateMoodColor(0);
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  leading: Icon(Icons.dark_mode),
                  onTap: () {
                    themeManager.updateMoodColor(1);
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Font Size",
                style: TextStyle(
                  fontSize: themeManager.fontSize * 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Slider(
                  value: themeManager.fontSize,
                  min: 18,
                  max: 40,
                  divisions: 6,
                  label: fontSize.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      fontSize = value;
                    });
                  },
                  onChangeEnd: (double value) {
                    themeManager.updateFontSize(value);
                  },
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Enable Avatar Movement",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: animalEntity.animalMoving,
            onChanged: (bool value) {
              animalEntity.changeMovement(value);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Read Messages Aloud",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: themeManager.readSentence,
            onChanged: (bool value) {
              themeManager.updateReadSentence(value);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Enable Sounds",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: animalEntity.soundAnimal,
            onChanged: (bool value) {
              animalEntity.changeSound(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontSize: themeManager.fontSize * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "ok",
            style: TextStyle(
              fontSize: themeManager.fontSize * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
/*
  void updateMoodColor(int num) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'colorMood': num, //0 light  ,, 1 dark
      });
    }
  }

  void updateFontSize(double num) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fontSize': num,
      });
    }
  }*/
}
