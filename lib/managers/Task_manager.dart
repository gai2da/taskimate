import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/UserEntity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../entity/animal.dart';
import '../managers/theme_Manager.dart';

class TasksManager extends ChangeNotifier {
  //defualt  is 10 -7
  TimeOfDay sleepingStartTime = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay sleepingEndTime = TimeOfDay(hour: 7, minute: 0);

  //productive time for scheduling
  TimeOfDay productiveStartTime = TimeOfDay(hour: 10, minute: 0);
  TimeOfDay productiveEndTime = TimeOfDay(hour: 16, minute: 0);

  //time can be work and break time
  int focusDuration = 30;
  int breakDuration = 10;

  Future<void> fetchUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};

      sleepingStartTime = _datetime2dayH(
          data?['sleepTimeStart']?.toDate() ?? DateTime(2024, 1, 1, 22, 0));

      sleepingEndTime = _datetime2dayH(
          data?['sleepTimeEnd']?.toDate() ?? DateTime(2024, 1, 2, 7, 0));

      productiveStartTime = _datetime2dayH(
          data?['productiveStartTime']?.toDate() ??
              DateTime(2024, 1, 1, 10, 0));

      productiveEndTime = _datetime2dayH(
          data?['productiveEndTime']?.toDate() ?? DateTime(2024, 1, 1, 16, 0));

      focusDuration = data?['focusDuration'] ?? 30;
      breakDuration = data?['breakDuration'] ?? 10;

      notifyListeners();
    }
  }

  Future<void> updateTaskPreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    DateTime sleepS = _dayH2datetime(sleepingStartTime);
    DateTime sleepE = _dayH2datetime(sleepingEndTime);
    DateTime prodS = _dayH2datetime(productiveStartTime);
    DateTime prodE = _dayH2datetime(productiveEndTime);
    //cuz i saved with day of updating (maybe find other way to)

    sleepE = checkIsBefore(sleepS, sleepE);
    prodE = checkIsBefore(prodS, prodE);
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'sleepTimeStart': sleepS,
        'sleepTimeEnd': sleepE,
        'productiveStartTime': prodS,
        'productiveEndTime': prodE,
        'focusDuration': focusDuration,
        'breakDuration': breakDuration,
      });
    }
    notifyListeners();
  }

  DateTime checkIsBefore(DateTime timeStart, DateTime timeEnd) {
    if (timeEnd.isBefore(timeStart)) {
      timeEnd = timeEnd.add(Duration(days: 1));
    }
    return timeEnd;
  }

  // from time of day to datetime (hh:mm > full )
  DateTime _dayH2datetime(TimeOfDay time) {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  // from time of day to datetime
  TimeOfDay _datetime2dayH(DateTime time) {
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  //getter and settiers
  void setSleepingStartTime(TimeOfDay time) {
    sleepingStartTime = time;
    notifyListeners();
  }

  void setSleepingEndTime(TimeOfDay time) {
    sleepingEndTime = time;
    notifyListeners();
  }

  void setProductiveStartTime(TimeOfDay time) {
    productiveStartTime = time;
    notifyListeners();
  }

  void setProductiveEndTime(TimeOfDay time) {
    productiveEndTime = time;
    notifyListeners();
  }

  void setFocusDuration(int duration) {
    focusDuration = duration;
    notifyListeners();
  }

  void setBreakDuration(int duration) {
    breakDuration = duration;
    notifyListeners();
  }

  DateTime timeOfDayWithGivenDate(DateTime date, TimeOfDay timeOfDay) {
    return DateTime(
        date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }
}
