import 'dart:math';
import 'package:final_year_project/managers/theme_Manager.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreatureMessage extends StatefulWidget {
  final String mood;

  CreatureMessage({Key? key, required this.mood}) : super(key: key);

  @override
  _CreatureMessageState createState() => _CreatureMessageState();
}

class _CreatureMessageState extends State<CreatureMessage> {
  late String message;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _changeMessage();
  }

  @override
  void didUpdateWidget(CreatureMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood != oldWidget.mood) {
      _changeMessage();
    }
  }

  void _changeMessage() {
    setState(() {
      message = _getRandomMessageFrom(widget.mood);
    });
    readMessage(message);
  }

  final List<String> happyMessages = [
    "You're doing great!\nKeep it up",
    "Keep it up!  \nyou can do it",
    "You're on track!\nKeep it up"
  ];

  final List<String> sadMessages = [
    "Oops, \nrunning late?  ",
    "No tasks done yet, time to get started.",
    "Some tasks are overdue, let's catch up!"
  ];

  final List<String> normalMessages = [
    "You're making progress, keep pushing!  ",
    "Stay focused, you're almost there!     ",
    "You're on the right track,keep pushing!"
  ];
  String _getRandomMessageFrom(String mood) {
    switch (mood) {
      case 'Happy':
        return _getRandomMessage(happyMessages);
      case 'Sad':
        return _getRandomMessage(sadMessages);

      default:
        return _getRandomMessage(normalMessages);
    }
  }

  String _getRandomMessage(List<String> messages) {
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  void readMessage(String txt) async {
    var themeManager = Provider.of<ThemeManager>(context, listen: false);
    if (!themeManager.readSentence) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(txt);
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/others/bubbleChat.svg',
            width: 200,
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                message ?? "tests",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
