import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/colorMood.dart';
import '../managers/Task_manager.dart';

class ThemeManager extends ChangeNotifier {
  ThemeData _currentTheme = light_mode;
  double _fontSize = 29;
  int _themeMode = 0;
  bool _animalMoving = true;
  bool _soundAnimal = true;
  bool _readSentence = true;
  // Task Settings
  TimeOfDay _sleepingStartTime = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _sleepingEndTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _productiveStartTime = TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _productiveEndTime = TimeOfDay(hour: 16, minute: 0);
  int _focusDuration = 30;
  int _breakDuration = 10;

  ThemeMode get themeMode =>
      (_themeMode == 1) ? ThemeMode.dark : ThemeMode.light;

  double get fontSize => _fontSize;
  ThemeData get currentTheme => _currentTheme;
  //int get themeMode => _themeMode;
  bool get animalMoving => _animalMoving;
  bool get soundAnimal => _soundAnimal;
  TimeOfDay get sleepingStartTime => _sleepingStartTime;
  TimeOfDay get sleepingEndTime => _sleepingEndTime;
  TimeOfDay get productiveStartTime => _productiveStartTime;
  TimeOfDay get productiveEndTime => _productiveEndTime;
  int get focusDuration => _focusDuration;
  int get breakDuration => _breakDuration;
  bool get readSentence => _readSentence;

  Future<void> fetchUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        _themeMode = doc['colorMood'] ?? 0;
        _fontSize = (doc['fontSize'] ?? 29).toDouble();
        _currentTheme = (_themeMode == 1) ? dark_mode : light_mode;
        _animalMoving = doc['animalMoving'] ?? true;
        _soundAnimal = doc['soundAnimal'] ?? true;
        _readSentence = doc['readSentence'] ?? true;
        _sleepingStartTime =
            datetime2dayH((doc['sleepingStartTime'] as Timestamp).toDate());
        _sleepingEndTime =
            datetime2dayH((doc['sleepingEndTime'] as Timestamp).toDate());
        _productiveStartTime =
            datetime2dayH((doc['productiveStartTime'] as Timestamp).toDate());
        _productiveEndTime =
            datetime2dayH((doc['productiveEndTime'] as Timestamp).toDate());
        _focusDuration = doc['focusDuration'] ?? 30;
        _breakDuration = doc['breakDuration'] ?? 10;
        notifyListeners();
      }
    }
  }

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
    _themeMode = num;
    _currentTheme = num == 1 ? dark_mode : light_mode;
    notifyListeners();
  }

  void updateReadSentence(bool isEnabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'readSentence': isEnabled,
      });
    }
    _readSentence = isEnabled;
    notifyListeners();
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
    _fontSize = num;
    notifyListeners();
  }

  // from time of day to datetime (hh:mm > full )
  DateTime dayH2datetime(TimeOfDay time) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  // from time of day to datetime
  TimeOfDay datetime2dayH(DateTime time) {
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }
}
