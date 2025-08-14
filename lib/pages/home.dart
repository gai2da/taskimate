import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/entity/CreatureMessages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:provider/provider.dart';
import '../entity/animal.dart';
import '../entity/task.dart';
import '../entity/point.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';
import '../managers/theme_Manager.dart';
import 'profile.dart';
import '../entity/UserEntity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:home_widget/home_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:developer';

class Home extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Home({required this.auth, required this.firestore});

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  int currentProfileIndex = 0;
  List<Task> todaysTasksList = [];
  late FirebaseFirestore firestore;
  late FirebaseAuth auth;
  late Point point;
  String mes = "points = ";
  String key = "key_flutter";
  String groupName = "group.homewidget";
  String iosWidgetName = "HomeWidget";
  @override
  void initState() {
    super.initState();

    firestore = widget.firestore;
    auth = widget.auth;

    final user = auth.currentUser;
    if (user != null) {
      print('User is signed in ${user.uid}');
    } else {
      print('No user signed in');
    }
    point = Point(auth: auth, firestore: firestore);
    HomeWidget.setAppGroupId(groupName);
    _saveWidgetData();
    //fetchTodaysTasks();
    print(todaysTasksList);
    //fetchProfileIndex();
    if (user != null) {
      print('User sign ${user.uid}');
      fetchTodaysTasks();
      fetchProfileIndex();
    } else {
      print('No user signed in');
      _clearWidgetData();
      setState(() {
        todaysTasksList = [];
      });
    }
    print(point.getPoints());
  }

  Future<void> _clearWidgetData() async {
    await HomeWidget.saveWidgetData<String>(
        'headline_title', "No tasks available.");
    await HomeWidget.saveWidgetData<String>('animal_currently', "happyMars");
    await HomeWidget.updateWidget(iOSName: iosWidgetName);
  }

  Future<void> _saveWidgetData() async {
    try {
      Task? nextTask = await getNextTask();
      final animalEntity = Provider.of<Animal>(context, listen: false);

      Map<String, String> animalMap = {
        "assets/animated/normalEarth.json": "normalEarth",
        "assets/animated/normalMars.json": "normalMars",
        "assets/animated/normal_dog.json": "normal_dog",
        "assets/animated/doganimated.json": "normal_dog",
        "assets/animated/happyEarth.json": "normalEarth",
        "assets/animated/happyMars.json": "normalMars",
        "assets/animated/happy_dog.json": "normal_dog",
        "assets/animated/cryingEarth.json": "normalEarth",
        "assets/animated/cryingMars.json": "normalMars",
        "assets/animated/crying_dog.json": "normal_dog",
      };

      String lottieAsset = animalEntity.currentAnimal;
      String pngName = animalMap[lottieAsset] ?? "happyMars";
      String backgC = "#282828";
      String textC = "#F8DA40";
      String tasktxt;
      if (nextTask != null) {
        String taskTime =
            DateFormat('HH:mm').format(nextTask.startTime.toDate());
        tasktxt = "Next Up: \n ${nextTask.name} at $taskTime";
      } else {
        tasktxt = "No tasks for now! \n Enjoy your break! ";
      }

      print(tasktxt);
      if (tasktxt.length > 40) {
        tasktxt = tasktxt.substring(0, 37) + "...";
      }

      await HomeWidget.saveWidgetData<String>('headline_title', tasktxt);
      await HomeWidget.saveWidgetData<String>('animal_currently', pngName);
      //  await HomeWidget.saveWidgetData<String>('text_color', textC);
      //  await HomeWidget.saveWidgetData<String>('background_color', backgC);
      await HomeWidget.updateWidget(iOSName: iosWidgetName);

      print("taks is  $tasktxt and animal : $pngName");
    } catch (e) {
      log("Error in _saveWidgetData: $e");
    }
  }

  Future<Task?> getNextTask() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        print("No signed in");
        return null;
      }
      List<Task> tasks = await Task.getTodaysTasksList(firestore, user.uid);
      tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
      DateTime now = DateTime.now();
      for (var task in tasks) {
        DateTime taskStartTime = task.startTime.toDate();
        if (taskStartTime.isAfter(now) && !task.done) {
          return task;
        }
        print(task.name);
      }
      return null;
    } catch (e) {
      print("Error getting next task $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    final animalEntity = Provider.of<Animal>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Task Manager",
          style: TextStyle(
            fontSize: themeManager.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              StreamBuilder<int>(
                stream: point.getPoints(),
                builder: (context, snapshot) {
                  final points = snapshot.data ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      " $points ",
                      style: GoogleFonts.poppins(
                        fontSize: themeManager.fontSize + 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 120,
              width: 150,
              margin: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CreatureMessage(mood: animalEntity.getMood()),
              ),
            ),
          ),

          //SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 220,
              width: 220,
              child: Lottie.asset(
                animalEntity.currentAnimal,
                height: 250,
                width: 250,
                animate: animalEntity.animalMoving,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: FutureBuilder<List<Task>>(
                future: auth.currentUser != null
                    ? Task.getTodaysTasksList(firestore, auth.currentUser!.uid)
                    : Future.value([]),
                builder: (context, snapshot) {
                  List<Task> todaysTasksList = snapshot.data ?? [];
                  // todaysTasksList = [];
                  if (todaysTasksList.isNotEmpty) {
                    todaysTasksList.sort((a, b) {
                      if (a.done == b.done) return 0;
                      return a.done ? 1 : -1;
                    });
                  }
                  return Column(children: [
                    Container(
                      child: Text(
                        "Today's Tasks",
                        style: GoogleFonts.poppins(
                          fontSize: themeManager.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: todaysTasksList.map((task) {
                          String taskstartT = DateFormat('HH:mm')
                              .format(task.startTime.toDate());
                          taskstartT = '' + taskstartT;
                          if (task.allDay) {
                            taskstartT = 'All day';
                          }
                          return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ListTile(
                                  leading: Semantics(
                                    label: task.done
                                        ? "Task completed"
                                        : "Task not completed",
                                    child: Checkbox(
                                      shape: CircleBorder(),
                                      value: task.done,
                                      onChanged: (bool? boolV) {
                                        setState(() {
                                          task.done = boolV ?? false;
                                        });

                                        task.updateDoneBool(
                                          firestore,
                                          boolV ?? false,
                                          task.id!,
                                          context,
                                          auth,
                                        );

                                        _saveWidgetData();
                                      },
                                      checkColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      //activeColor: Colors.transparent,
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          width: 2),
                                    ),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(task.name,
                                          style: GoogleFonts.poppins(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize:
                                                themeManager.fontSize * 0.7,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text(taskstartT,
                                          style: GoogleFonts.poppins(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontSize:
                                                themeManager.fontSize * 0.6,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ],
                                  )));
                        }).toList(),
                      ),
                    ),
                  ]);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void fetchTodaysTasks() async {
    final user = auth.currentUser;
    if (user == null) {
      print("null user");
      setState(() {
        todaysTasksList = [];
      });
      return;
    }
    print("in fetchTodaysTasks");
    try {
      final tasks = await Task.getTodaysTasksList(firestore, user.uid);
      tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
      bool tasksDoneBool = tasks.any((task) => task.done);
      setState(() {
        print('Fetched tasks: $todaysTasksList');
        todaysTasksList = tasks;
        print('Fetched taskssss: $todaysTasksList');
        final animalEntity = Provider.of<Animal>(context, listen: false);
        print('Fetched tasks---: $todaysTasksList');
        animalEntity.changeToSadAnimal(!tasksDoneBool);
        print('Fetched tasks: $todaysTasksList');
      });
      print("done  fetchTodaysTasks");
      for (var task in tasks) {
        if (!task.done) {
          scheduleTaskNotification(task);
        }
      }
    } catch (e) {
      print('Error fetching : $e');
    }
  }

  Future<void> fetchProfileIndex() async {
    try {
      final user = widget.auth.currentUser;
      if (user == null) {
        throw Exception("No user signed in");
      }
      final doc =
          await widget.firestore.collection('users').doc(user.uid).get();
      final index = doc.data()?['profileImageIndex'] as int? ?? 0;

      setState(() {
        currentProfileIndex = index;
      });
    } catch (e) {
      print('Error  profile index: $e');
    }
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.allDay || task.done) {
      print("skip task");
      return;
    }

    final DateTime taskTime = task.startTime.toDate();

    //change later to 10 min
    final DateTime notificationTime = taskTime.subtract(Duration(minutes: 10));

    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      "Task Reminder",
      "Your task '${task.name}' starts in 10 minutes!",
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("done notifiction");
  }
}
