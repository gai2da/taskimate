import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/task.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../managers/Task_manager.dart';
import '../managers/theme_Manager.dart';
import 'package:flutter/services.dart';
import '../services/GoogleService.dart';
import 'package:googleapis/calendar/v3.dart' as gogl;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as speech2text;
import 'package:flutter/semantics.dart';

import 'package:share_plus/share_plus.dart';
import 'dart:ui' as useri;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Calendar({required this.auth, required this.firestore});

  @override
  _taskManaging createState() => _taskManaging();
}

class _taskManaging extends State<Calendar> {
  List<Appointment> tasksMeeting = <Appointment>[];
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController DateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<String> days = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"];
  late FirebaseFirestore firestore;
  late FirebaseAuth auth;
  DateTime taskAddedDate = DateTime.now();
  DateTime taskEndDate = DateTime.now();
  DateTime taskStartDate = DateTime.now();
  DateTime datedisplay = DateTime.now();
  String displayedDate = "Date";
  bool allDaybool = false;
  //final userId = FirebaseAuth.instance.currentUser!.uid;
  bool flexibleScheduling = false;

  CalendarView _calendarView = CalendarView.week;

  // Voice Input
  late speech2text.SpeechToText _speechToText;
  Map<TextEditingController, bool> _listeningforeachController = {};
  String _Listenedtext = "";

  User? user;
  String? userId;

  final List<Color> ColorsList = [
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    //to handle null user

    firestore = widget.firestore;
    auth = widget.auth;

    final user = auth.currentUser;
    // user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
    _speechToText = speech2text.SpeechToText();
    fetching();
  }

  void fetching() async {
    tasksMeeting = await gettasks();
    final sleepingT = await setSleepingTime();
    if (sleepingT != null) {
      tasksMeeting.add(sleepingT);
    }
    final List<Appointment> googleCalendarTasks = await getGoogleTasks();
    tasksMeeting.addAll(googleCalendarTasks);
    print("Tasks fetched: ${tasksMeeting.length}");
    setState(() {});
  }

  void listening(TextEditingController txt) async {
    txt.clear();
    if (await _speechToText.initialize()) {
      setState(() => _listeningforeachController[txt] = true);
      _speechToText.listen(
        onResult: (result) => setState(() => txt.text = result.recognizedWords),
      );
    } else {
      SemanticsService.announce(
        "Speech to text not available.",
        useri.TextDirection.ltr,
      );
      print("Speech to text not available.");
    }
  }

  void stopListening(TextEditingController txt) {
    _speechToText.stop();
    setState(() {
      _listeningforeachController[txt] = false;
    });
  }

  //method to read
  Future<List<Appointment>> gettasks() async {
    if (userId == null) {
      return [];
    }
    final readfirebase = await firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();
    print("tasks for user: $userId");

    return readfirebase.docs.map((doc) {
      //final data = doc.data();
      //bool isAllDay = data['allDay'] ?? false;
      final task = Task.fromFirestore(doc.id, doc.data());

      DateTime taskDate = task.date.toDate();
      DateTime startDate = task.allDay
          ? DateTime(taskDate.year, taskDate.month, taskDate.day) // Midnight
          : task.startTime.toDate();

      DateTime endDate = task.allDay ? startDate : task.endTime.toDate();
      String byDay = days[startDate.weekday % 7];
      String? recurrenceTask;
      if (task.recurrence == "Weekly") {
        recurrenceTask = 'FREQ=WEEKLY;BYDAY=$byDay';
      } else if (task.recurrence == "Monthly") {
        recurrenceTask == 'FREQ=MONTHLY;BYMONTHDAY=${startDate.day}';
      } else if (task.recurrence == "Yearly") {
        recurrenceTask =
            'FREQ=YEARLY;BYMONTH=${startDate.month};BYMONTHDAY=${startDate.day}';
      }
      return Appointment(
        startTime: startDate,
        endTime: endDate,
        subject: task.name,
        isAllDay: task.allDay,
        color: task.color ?? Colors.blue,
        recurrenceRule: recurrenceTask,
      );
    }).toList();
  }

  Future<List<Appointment>> getGoogleTasks() async {
    final GoogleService _GoogleService = GoogleService();
    List<Appointment> googleTasks = [];
    try {
      List<gogl.Event> events = await _GoogleService.getTasksFromGoogle();

      for (var event in events) {
        if (event.start?.dateTime != null && event.end?.dateTime != null) {
          googleTasks.add(
            Appointment(
              startTime: event.start!.dateTime!,
              endTime: event.end!.dateTime!,
              subject: event.summary ?? "google calandar",
              color: const Color.fromARGB(255, 224, 91, 215),
            ),
          );
        }
      }
    } catch (e) {
      print("error $e");
    }

    return googleTasks;
  }

  Future<void> saveCalendar() async {
    try {
      List<Task> tasks = await Task.getTodaysTasksList(firestore, userId);

      List<List<String>> column = [
        ["Task Name", "Start Time", "End Time", "All Day"]
      ];

      if (tasks.isNotEmpty) {
        for (var task in tasks) {
          column.add([
            task.name,
            DateFormat('yyyy-MM-dd HH:mm').format(task.startTime.toDate()),
            DateFormat('yyyy-MM-dd HH:mm').format(task.endTime.toDate()),
            task.allDay ? "Yes" : "No"
          ]);
        }
      }
      String toStr = const ListToCsvConverter().convert(column);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/calendar_exported.csv';
      final file = File(filePath);
      await file.writeAsString(toStr);

      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      print(" $e");
    }
  }

  Future<void> _addTask(Color? colorTask, String? selected_priority,
      String? selected_recurrent) async {
    //print(datedisplay);
    selected_recurrent ??= 'None';
    selected_priority ??= 'Low';

    final tasksManager = Provider.of<TasksManager>(context, listen: false);
    DateTime sleepStart = tasksManager.timeOfDayWithGivenDate(
        datedisplay, tasksManager.sleepingStartTime);
    DateTime sleepEnd = tasksManager.timeOfDayWithGivenDate(
        datedisplay, tasksManager.sleepingEndTime);
    sleepEnd = tasksManager.checkIsBefore(sleepStart, sleepEnd);

    int duration = 0;
    DateTime finalStartT = DateTime(datedisplay.year, datedisplay.month,
        datedisplay.day, taskAddedDate.hour, taskAddedDate.minute, 0);

    DateTime finalEndT = DateTime(datedisplay.year, datedisplay.month,
        datedisplay.day, taskEndDate.hour, taskEndDate.minute, 0);
    if (flexibleScheduling) {
      duration = int.tryParse(durationController.text) ?? 0;
      //show error if zero  ------------

      //
      finalEndT = taskStartDate.add(Duration(minutes: duration));
      print('$finalEndT , ---end ');
    }

    //check overlapping with sleep and make the user decide
    bool overlapWithSleep =
        checkOverlapping(finalStartT, finalEndT, sleepStart, sleepEnd);

    print('$overlapWithSleep with sleeepp----');
    duration = _calc_duration(finalStartT, finalEndT);
    if (overlapWithSleep) {
      bool decision = await _alertSleepDialog(context);
      if (!decision) {
        //start after 30 min from sleep end
        finalStartT = sleepEnd.add(Duration(minutes: 30));
        finalEndT = finalStartT.add(Duration(minutes: duration));
      }
    }

    bool overlappingBool =
        await _checkTwoTaskOverlapping(finalStartT, finalEndT);
    if (overlappingBool && !flexibleScheduling) {
      print("task can't be added due to overlapping with other task");
      await displayErrorDialog(
          context, "task can't be added due to overlapping with other task");

      return;
    } else if (overlappingBool && flexibleScheduling) {
      print(
          "Your task is overlapping with another task. Would you like to reschedule your task after the conflicting one?");
      bool? r = await displaydisitionDialog(context,
          "Your task is overlapping with another task. Would you like to reschedule your task after the conflicting one?");
      if (!r) {
        return;
      }
    }

    if (flexibleScheduling) {
      _addTaskFlexible(taskNameController.text, finalStartT, duration,
          colorTask, selected_priority, selected_recurrent);
    } else {
      final task = Task(
        name: taskNameController.text,
        date: Timestamp.fromDate(datedisplay),
        startTime: Timestamp.fromDate(allDaybool ? datedisplay : finalStartT),
        endTime: Timestamp.fromDate(allDaybool ? datedisplay : finalEndT),
        done: false,
        allDay: allDaybool,
        userId: userId,
        color: colorTask,
        priority: selected_priority,
        description: descriptionController.text,
        recurrence: selected_recurrent,
      );

      if (userId == null) {
        tasksMeeting.add(
          Appointment(
            startTime: taskAddedDate,
            endTime: taskEndDate,
            subject: taskNameController.text,
            color: colorTask ?? Colors.blue,
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('tasks')
            .add(task.toFirestore());
        fetching();
      }
    }

    taskNameController.clear();
    DateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    durationController.clear();
    descriptionController.clear();
    taskStartDate = DateTime.now();
    taskEndDate = DateTime.now();
  }

  bool checkOverlapping(
      DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
    print(bStart);
    print(bEnd);
    print(aStart);
    print(aEnd);
    List<Map<String, DateTime>> sleepListBoundery = [];
    sleepListBoundery.add({
      'start': bStart.subtract(Duration(days: 1)),
      'end': bEnd.subtract(Duration(days: 1)),
    });
    sleepListBoundery.add({
      'start': bStart,
      'end': bEnd,
    });
    sleepListBoundery.add({
      'start': bStart.add(Duration(days: 1)),
      'end': bEnd.add(Duration(days: 1)),
    });

    // if (aEnd.isAfter(bStart)){
    //  return aStart.isBefore(bEnd) && aEnd.isAfter(bStart);
    // }
    for (var period in sleepListBoundery) {
      if (aStart.isBefore(period['end']!) && aEnd.isAfter(period['start']!)) {
        return true;
      }
    }
    return false;
  }

  Future<DateTime?> getAvailableTimeForTask(DateTime productiveStart,
      DateTime productiveEnd, int taskDuration) async {
    final tasks = await Task.getAllTasks(firestore, userId!);

//taks maybe map instead ???
    List<Appointment> appointments = tasks.map((task) {
      return Appointment(
        startTime: task.startTime.toDate(),
        endTime: task.endTime.toDate(),
        subject: task.name,
        color: task.color ?? Colors.blue,
      );
    }).toList();

    List<Appointment> overlappingTasks = appointments.where((task) {
      DateTime taskStart = task.startTime;
      DateTime taskEnd = task.endTime;
      return taskStart.isBefore(productiveEnd) &&
          taskEnd.isAfter(productiveStart);
    }).toList();

    overlappingTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

    DateTime previousEnd = productiveStart;

    for (var task in overlappingTasks) {
      DateTime taskStart = task.startTime;
      DateTime taskEnd = task.endTime;
      if (taskStart.difference(previousEnd).inMinutes >= taskDuration) {
        return previousEnd;
      }

      previousEnd = taskEnd;
    }

    if (productiveEnd.difference(previousEnd).inMinutes >= taskDuration) {
      return previousEnd;
    }

    return null;
  }

  Future<bool> _alertSleepDialog(BuildContext context) async {
    bool? boolr = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adding task in sleep time'),
          content: Text(
              'This task is scheduled during your sleeping time. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
    return boolr ?? false;
  }

  void _addTaskFlexible(String name, DateTime timeS, int duration,
      Color? colorTask, String? priorityTask, String? recurrenceTask) async {
    print("ssssssss-------");
    final tasksManager = Provider.of<TasksManager>(context, listen: false);
    // bool isOccupied = await isProductiveTimeOccupied(timeS, taskEnd);
    DateTime productiveStart = tasksManager.timeOfDayWithGivenDate(
        timeS, tasksManager.productiveStartTime);
    DateTime productiveEnd = tasksManager.timeOfDayWithGivenDate(
        timeS, tasksManager.productiveEndTime);

    DateTime? thereIsavailableTime =
        await getAvailableTimeForTask(productiveStart, productiveEnd, duration);
    bool? r;
    if (thereIsavailableTime != null) {
      print(
          "There is available time in the productive time window. Would you like to move the task to this time?");
      r = await displaydisitionDialog(context,
          "There is available time in the productive time window. Would you like to move the task to this time?");

      if (r == true) {
        timeS = thereIsavailableTime;
      }
    }

    int sub_num = 1;
    while (duration > 0) {
      DateTime? nextSlot =
          await _checkNextSlotAvailable(timeS, tasksManager.focusDuration);

      //maybe delete ? make it not nullable
      if (nextSlot == null) {
        displayErrorDialog(
            context, "unavailable time slot found for flexible scheduling.");
        return;
      }
      int currentDuration = min(tasksManager.focusDuration, duration);
      DateTime taskSubTime = nextSlot.add(Duration(minutes: currentDuration));
      final task = Task(
        name: "$name , sub $sub_num",
        date: Timestamp.fromDate(datedisplay),
        startTime: Timestamp.fromDate(nextSlot),
        endTime: Timestamp.fromDate(taskSubTime),
        done: false,
        allDay: false,
        userId: userId,
        color: colorTask,
        priority: priorityTask,
        description: descriptionController.text,
        recurrence: recurrenceTask,
      );

      if (userId == null) {
        tasksMeeting.add(
          Appointment(
            startTime: nextSlot,
            endTime: taskEndDate,
            subject: task.name,
            color: colorTask ?? Colors.blue,
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('tasks')
            .add(task.toFirestore());
      }
      duration -= currentDuration;
      //timeS = taskSubTime;
      timeS = taskSubTime.add(Duration(minutes: tasksManager.breakDuration));
      sub_num++;
    }
    print("ssssssss--sss-----");
    fetching();
  }

  int _calc_duration(start, end) {
    Duration duration = end.difference(start);
    return duration.inMinutes;
  }

  Future<DateTime?> _checkNextSlotAvailable(DateTime start, int focusD) async {
    //------ change getTodaysTasksList for all task after the start time (add methodd in tasks)
    final tasks = await Task.getAllTasks(FirebaseFirestore.instance, userId!);

    tasks.sort((x, y) => x.startTime.compareTo(y.startTime));

    DateTime tempTime = start;

    while (true) {
      DateTime endTime = start.add(Duration(minutes: focusD));

      bool foundTime = true;
      for (var task in tasks) {
        DateTime taskS = task.startTime.toDate();
        DateTime taskE = task.endTime.toDate();

        if ((start.isBefore(taskE) && endTime.isAfter(taskS))) {
          foundTime = false;
          break;
        }
      }
      if (foundTime) {
        return start;
      }
      start = endTime;
    }
  }

  Future<void> _deleteTask(String taskId) async {
    print("tasks for user: $userId");

    print("delete task");
    try {
      await firestore.collection('tasks').doc(taskId).delete();
      print("deleted success");
      SemanticsService.announce(
        "Task deleted successfully",
        useri.TextDirection.ltr,
      );
      fetching();
    } catch (e) {
      SemanticsService.announce(
        "An error occurred while deleting the task.",
        useri.TextDirection.ltr,
      );

      print("Error : $e");
    }
  }

  void _deleteTaskLocally(int? taskId) {
    print("tasks for user: $userId");
    if (userId == null) {
      setState(() {
        tasksMeeting.removeWhere((task) => task.id == taskId);
      });
      print("deleted task");
      return;
    } else {
      //_deleteTask(taskId);
      print("error deleting task locally");
    }
  }

  Future<void> _updateTask(String taskId, String taskName, DateTime startDate,
      DateTime endDate, DateTime date, bool dn, String taskDescription) async {
    DateTime finalStartT = DateTime(
        date.year, date.month, date.day, startDate.hour, startDate.minute, 0);
    DateTime finalEndT = DateTime(
        date.year, date.month, date.day, endDate.hour, endDate.minute, 0);
    try {
      await firestore.collection('tasks').doc(taskId).update({
        'name': taskName,
        'date': Timestamp.fromDate(date),
        'startTime': Timestamp.fromDate(finalStartT),
        'endTime': Timestamp.fromDate(finalEndT),
        'done': dn,
        'allDay': allDaybool,
        'description': taskDescription,
      });

      print('updated ');
    } catch (e) {
      print(e);
    }
    fetching();
  }

  Future<bool> _checkTwoTaskOverlapping(
      DateTime checkStartTime, DateTime checkendTime) async {
    final querySnapshot = await firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    for (var d in querySnapshot.docs) {
      final task = Task.fromFirestore(d.id, d.data());
      DateTime taskStart = task.startTime.toDate();
      DateTime taskEnd = task.endTime.toDate();
      if ((checkStartTime.isBefore(taskEnd) &&
              checkendTime.isAfter(taskStart)) ||
          (checkStartTime.isBefore(taskStart) &&
              checkendTime.isAfter(taskStart)) ||
          (checkStartTime.isBefore(taskEnd) && checkendTime.isAfter(taskEnd))) {
        return true;
      }
    }
    return false;
  }

  Future<void> displayErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> displaydisitionDialog(
      BuildContext context, String message) async {
    bool? r = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Task Adjustment"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("NO"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    return r ?? false;
  }

  Future<Appointment?> setSleepingTime() async {
    //final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        final sleepingStart =
            (doc.data()?['sleepTimeStart'] as Timestamp?)?.toDate() ??
                DateTime(2024, 1, 1, 22, 0);

        final sleepingEnd =
            (doc.data()?['sleepTimeEnd'] as Timestamp?)?.toDate() ??
                DateTime(2024, 1, 2, 7, 0);

        return Appointment(
          startTime: sleepingStart,
          endTime: sleepingEnd,
          subject: 'Sleeping Time',
          recurrenceRule: 'FREQ=DAILY',
          isAllDay: false,
          color: Colors.transparent,
        );
      }
    }
    return null;
  }

  void _dialogstarting(BuildContext context) {
    taskNameController.clear();
    DateController.clear();
    startTimeController.clear();
    endTimeController.clear();

    datedisplay = DateTime.now();
    taskStartDate = DateTime.now();
    taskEndDate = DateTime.now();
    allDaybool = false;
    String? selected_priority;
    Color selected_Color = Colors.blue;
    String? selectedRecurrence;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: taskNameController,
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.mic,
                              color: _listeningforeachController[
                                          taskNameController] ==
                                      true
                                  ? Colors.green
                                  : Colors.blue),
                          onPressed: () {
                            if (_listeningforeachController[
                                    taskNameController] ==
                                true) {
                              stopListening(taskNameController);
                            } else {
                              listening(taskNameController);
                            }
                          },
                        ),
                      ),
                    ),
                    TextField(
                      controller: DateController,
                      decoration: InputDecoration(
                        labelText: 'Task Date',
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: datedisplay,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2090),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            datedisplay = pickedDate;
                            DateController.text =
                                DateFormat('yyyy-MM-dd').format(datedisplay);
                            print(DateController);
                          });
                        }
                      },
                    ),
                    CheckboxListTile(
                      title: Text("All Day Task"),
                      value: allDaybool,
                      onChanged: (bool? value) {
                        setState(() {
                          allDaybool = value ?? false;
                        });
                      },
                    ),
                    if (!allDaybool)
                      CheckboxListTile(
                        title: Text("Flexible Scheduling"),
                        value: flexibleScheduling,
                        onChanged: (bool? value) {
                          setState(() {
                            flexibleScheduling = value ?? false;
                          });
                        },
                      ),
                    if (!allDaybool)
                      TextField(
                          controller: startTimeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Start time',
                          ),
                          onTap: () async {
                            TimeOfDay? pickedStartTime = await showTimePicker(
                              context: context,
                              initialEntryMode: TimePickerEntryMode.input,
                              initialTime:
                                  TimeOfDay.fromDateTime(taskStartDate),
                            );

                            if (pickedStartTime != null) {
                              setState(() {
                                taskStartDate = DateTime(
                                  datedisplay.year,
                                  datedisplay.month,
                                  datedisplay.day,
                                  pickedStartTime.hour,
                                  pickedStartTime.minute,
                                );
                                taskAddedDate = taskStartDate;
                                startTimeController.text =
                                    DateFormat('HH:mm').format(taskStartDate);
                              });
                            }
                            //check if the time b4 the start date :
                          }),
                    if (!allDaybool && flexibleScheduling)
                      TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Duration (min)',
                        ),
                      ),
                    if (!allDaybool && !flexibleScheduling)
                      TextField(
                          controller: endTimeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'End time',
                          ),
                          onTap: () async {
                            TimeOfDay? pickedEndTime = await showTimePicker(
                              context: context,
                              initialEntryMode: TimePickerEntryMode.input,
                              initialTime:
                                  TimeOfDay.fromDateTime(taskStartDate),
                            );

                            if (pickedEndTime != null) {
                              setState(() {
                                DateTime selectedTime = DateTime(
                                  datedisplay.year,
                                  datedisplay.month,
                                  datedisplay.day,
                                  pickedEndTime.hour,
                                  pickedEndTime.minute,
                                );
                                taskEndDate = selectedTime;

                                endTimeController.text =
                                    DateFormat('HH:mm').format(taskEndDate);
                              });
                            }
                            //check if the time b4 the start date :
                          }),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Task description',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.mic,
                              color: _listeningforeachController[
                                          descriptionController] ==
                                      true
                                  ? Colors.green
                                  : Colors.blue),
                          onPressed: () {
                            if (_listeningforeachController[
                                    descriptionController] ==
                                true) {
                              stopListening(descriptionController);
                            } else {
                              listening(descriptionController);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selected_priority,
                      hint: Text("Select priority"),
                      onChanged: (String? value) {
                        setState(() {
                          selected_priority = value;
                        });
                      },
                      items: <String>['Low', 'Medium', 'High']
                          .map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
                    DropdownButton<String>(
                      value: selectedRecurrence,
                      hint: Text("Select Recurrence"),
                      onChanged: (String? value) {
                        setState(() {
                          selectedRecurrence = value;
                        });
                      },
                      items: <String>["None", "Weekly", "Monthly", "Yearly"]
                          .map<DropdownMenuItem<String>>(
                        (String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ColorsList.map((Color c) {
                          bool isSelected = selected_Color == c;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selected_Color = c;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c,
                                border: isSelected
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (!allDaybool &&
                        !flexibleScheduling &&
                        taskEndDate.isBefore(taskStartDate)) {
                      // Show error message if the end time is before the start time
                      await displayErrorDialog(
                          context, "End time cannot be before the start time.");
                      return;
                    }
                    await _addTask(
                        selected_Color, selected_priority, selectedRecurrence);
                    durationController.clear();
                    flexibleScheduling = false;
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    durationController.clear();
                    flexibleScheduling = false;
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          });
        });
  }

  void _dialogModifing(BuildContext context, Appointment currentTask) {
    taskNameController.text = currentTask.subject;
    DateController.text =
        DateFormat('dd/MM/yyyy').format(currentTask.startTime);
    startTimeController.text =
        DateFormat('HH:mm').format(currentTask.startTime);
    endTimeController.text = DateFormat('HH:mm').format(currentTask.endTime);
    taskAddedDate = currentTask.startTime;
    taskEndDate = currentTask.endTime;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Modifing Task'),
            content: Column(
              children: [
                TextField(
                  controller: taskNameController,
                  decoration: InputDecoration(
                    labelText: 'Task Name',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic,
                          color:
                              _listeningforeachController[taskNameController] ==
                                      true
                                  ? Colors.green
                                  : Colors.blue),
                      onPressed: () {
                        if (_listeningforeachController[taskNameController] ==
                            true) {
                          stopListening(taskNameController);
                        } else {
                          listening(taskNameController);
                        }
                      },
                    ),
                  ),
                ),
                TextField(
                  controller: DateController,
                  decoration: InputDecoration(
                    labelText: 'Task Date',
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: taskAddedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2090),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        datedisplay = pickedDate;
                        DateController.text =
                            DateFormat('yyyy-MM-dd').format(datedisplay);
                        print(DateController);
                      });
                    }
                  },
                ),
                TextField(
                  controller: startTimeController,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedStartTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(taskAddedDate),
                    );

                    if (pickedStartTime != null) {
                      setState(() {
                        taskAddedDate = DateTime(
                          datedisplay.year,
                          datedisplay.month,
                          datedisplay.day,
                          pickedStartTime.hour,
                          pickedStartTime.minute,
                        );
                        startTimeController.text =
                            DateFormat('HH:mm').format(taskAddedDate);
                        //endTimeController.text = taskAddedDate.toString();
                      });
                    }
                  },
                ),
                TextField(
                  controller: endTimeController,
                  decoration: InputDecoration(
                    labelText: 'End Time',
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedStartTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(taskEndDate),
                    );

                    if (pickedStartTime != null) {
                      setState(() {
                        taskEndDate = DateTime(
                          datedisplay.year,
                          datedisplay.month,
                          datedisplay.day,
                          pickedStartTime.hour,
                          pickedStartTime.minute,
                        );
                        endTimeController.text =
                            DateFormat('HH:mm').format(taskEndDate);
                        //endTimeController.text = taskAddedDate.toString();
                      });
                    }
                  },
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Task description',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.mic,
                          color:
                              _listeningforeachController[taskNameController] ==
                                      true
                                  ? Colors.green
                                  : Colors.blue),
                      onPressed: () {
                        if (_listeningforeachController[taskNameController] ==
                            true) {
                          stopListening(taskNameController);
                        } else {
                          listening(taskNameController);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  String? currentId = await getTaskById(currentTask.subject,
                      currentTask.startTime, currentTask.endTime);
                  print(currentId);
                  if (currentId != null) {
                    await _updateTask(
                        currentId,
                        taskNameController.text,
                        taskAddedDate,
                        taskEndDate,
                        datedisplay,
                        false,
                        descriptionController.text);
                    print('done updating');
                  } else {
                    print('task doesnt exist');
                  }
                },
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  Future<void> updateTaskDatefireStore(
      String taskId, DateTime newStartTime, DateTime newEndTime) async {
    try {
      await firestore.collection('tasks').doc(taskId).update({
        'startTime': Timestamp.fromDate(newStartTime),
        'endTime': Timestamp.fromDate(newEndTime),
      });

      print("update successful.");
    } catch (e) {
      print("update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    DateTime? oldStartTime;
    DateTime? oldEndTime;

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
      body: Semantics(
        label:
            "Task Calendar. Swipe left or right to navigate. Double tap a task for details.",
        child: SfCalendar(
          // allowAppointmentResize: false,
          key: ValueKey(_calendarView),
          view: _calendarView, //weekly calender
          firstDayOfWeek: 1, //monday 1
          dataSource: Tasks(tasksMeeting),
          showNavigationArrow: true,
          allowDragAndDrop: true,
          appointmentTextStyle: TextStyle(fontSize: 10, color: Colors.black),
          timeSlotViewSettings: TimeSlotViewSettings(
            timeIntervalHeight: 80,
            timeIntervalWidth: 100,
          ),

          headerStyle: CalendarHeaderStyle(
            backgroundColor: Theme.of(context).colorScheme.surface,
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          onDragStart: (AppointmentDragStartDetails details) {
            if (details.appointment == null) return;

            final Appointment draggedTask = details.appointment as Appointment;
            oldStartTime = draggedTask.startTime;
            oldEndTime = draggedTask.endTime;
            print(oldStartTime);
            print(oldEndTime);
          },
          onDragEnd: (AppointmentDragEndDetails details) async {
            if (details.appointment == null || details.droppingTime == null)
              return;

            final Appointment draggedTask = details.appointment as Appointment;

            if (oldStartTime == null || oldEndTime == null) {
              return;
            }
            int durationOldTask = _calc_duration(oldStartTime, oldEndTime);

            final DateTime newStartTime = details.droppingTime!;
            final DateTime newEndTime =
                newStartTime.add(Duration(minutes: durationOldTask));

            String? taskId = await getTaskById(
                draggedTask.subject, oldStartTime!, oldEndTime!);

            if (taskId != null) {
              print("found task.");
              await updateTaskDatefireStore(taskId, newStartTime, newEndTime);
            } else {
              print("task not found");
            }
            oldStartTime = null;
            oldEndTime = null;
          },

          //delete this

          onTap: (CalendarTapDetails info) {
            if (info.appointments != null) {
              final Appointment theAppot =
                  info.appointments!.first as Appointment;

              if (theAppot.subject == 'Sleeping Time') {
                return;
              }
              SemanticsService.announce(
                "Task: ${theAppot.subject}. Starts at ${DateFormat('hh:mm a').format(theAppot.startTime)}. Ends at ${DateFormat('hh:mm a').format(theAppot.endTime)}",
                useri.TextDirection.ltr,
              );

              _taskInfo(theAppot, context);
            }
          },
        ),
      ),

      // ---
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "exportBtn",
            onPressed: saveCalendar,
            child: Icon(Icons.share),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoomBtn",
            onPressed: _calendarZoomIn,
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoomOutBtn",
            onPressed: _calendarZoomOut,
            child: Icon(Icons.zoom_out),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "addBtn",
            onPressed: () {
              _dialogstarting(context);
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _calendarZoomIn() {
    setState(() {
      if (_calendarView == CalendarView.week) {
        _calendarView = CalendarView.day;
      } else if (_calendarView == CalendarView.month) {
        _calendarView = CalendarView.week;
      }
    });
  }

  void _calendarZoomOut() {
    setState(() {
      if (_calendarView == CalendarView.day) {
        _calendarView = CalendarView.week;
      } else if (_calendarView == CalendarView.week) {
        _calendarView = CalendarView.month;
      }
    });
  }

  void _taskInfo(Appointment currentTask, BuildContext context) async {
    final taskName = currentTask.subject;
    final taskstartT = DateFormat('HH:mm').format(currentTask.startTime);
    final taskendT = DateFormat('HH:mm').format(currentTask.endTime);

    final bool isAllDayTask = currentTask.isAllDay;

    final String taskTimeInfo = isAllDayTask
        ? "All Day Task"
        : "Start: ${DateFormat('HH:mm').format(currentTask.startTime)}\n"
            "End: ${DateFormat('HH:mm').format(currentTask.endTime)}";

    String? taskid = await getTaskById(
      currentTask.subject,
      currentTask.startTime,
      currentTask.endTime,
    );

    Task? allTaskParam;
    if (taskid != null) {
      final taskDoc = await firestore.collection('tasks').doc(taskid).get();

      if (taskDoc.exists) {
        allTaskParam = Task.fromFirestore(taskDoc.id, taskDoc.data()!);
      }
    }

    final taskDescription = allTaskParam?.description ?? 'No description';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Semantics(
              label: "Task information", child: Text('Task information')),
          content: Text(
              'Task: "$taskName"\nStart: ${taskstartT}\nEnd: ${taskendT}\nDescription: $taskDescription'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _dialogModifing(context, currentTask);
                print('Modify Task: ${currentTask.subject}');
              },
              child: Text('Modify'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                String? currentId = await getTaskById(currentTask.subject,
                    currentTask.startTime, currentTask.endTime);
                print('deleting  Task: ${currentId}');
                print('deleting  Task: ${currentTask.startTime}');
                if (currentId != null) {
                  await _deleteTask(currentId);
                  print('done deleting');
                } else {
                  int? currentInd = getTaskLocally(currentTask.subject,
                      currentTask.startTime, currentTask.endTime);

                  _deleteTaskLocally(currentInd);

                  print('task doesnt exist');
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> getTaskById(
      String name, DateTime startTime, DateTime endTime) async {
    QuerySnapshot querySnapshot;
    if (allDaybool) {
      DateTime taskDate =
          DateTime(startTime.year, startTime.month, startTime.day);
      querySnapshot = await firestore
          .collection('tasks')
          .where('name', isEqualTo: name)
          .where('date', isEqualTo: Timestamp.fromDate(taskDate))
          .where('allDay', isEqualTo: true)
          .get();
    } else {
      querySnapshot = await firestore
          .collection('tasks')
          .where('name', isEqualTo: name)
          .where('startTime', isEqualTo: Timestamp.fromDate(startTime))
          .where('endTime', isEqualTo: Timestamp.fromDate(endTime))
          .get();
    }

    if (querySnapshot.docs.isNotEmpty) {
      print("task found");
      return querySnapshot.docs.first.id;
    } else {
      print("task not found");
      return null;
    }
  }

  int? getTaskLocally(String name, DateTime startTime, DateTime endTime) {
    final ind = tasksMeeting.indexWhere(
      (task) =>
          task.subject == name &&
          task.startTime == startTime &&
          task.endTime == endTime,
    );

    if (ind == -1) {
      return null;
    }
    return ind;
  }
}

class Tasks extends CalendarDataSource {
  Tasks(List<Appointment> tasksList) {
    appointments = tasksList;
  }
}
