import 'dart:math';
import 'package:final_year_project/managers/theme_Manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:final_year_project/entity/animal.dart';

class AnimalBubbleChat extends StatefulWidget {
  final String message;

  const AnimalBubbleChat({Key? key, required this.message}) : super(key: key);

  @override
  _AnimalBubbleChatState createState() => _AnimalBubbleChatState();
}

class _AnimalBubbleChatState extends State<AnimalBubbleChat> {
  late String message;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _changeMessage();
  }

  @override
  void didUpdateWidget(AnimalBubbleChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message) {
      _changeMessage();
    }
  }

  void _changeMessage() {
    setState(() {
      message = widget.message;
    });
    readMessage(message);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
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
                    message,
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
        ),
      ],
    );
  }
}
