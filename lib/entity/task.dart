import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../entity/point.dart';
import 'animal.dart';

class Task {
  final String name;
  final Timestamp startTime;
  final Timestamp endTime;
  final Timestamp date;
  bool done;
  final Color? color;
  final bool allDay;
  final String? id;
  final String? priority;
  final String? description;
  final String? userId;
  String? recurrence;
  bool flexible;
  //final CollectionReference allTasks =FirebaseFirestore.instance.collection('tasks');

  Task(
      {required this.name,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.done,
      required this.allDay,
      this.color,
      this.priority,
      this.id,
      this.description,
      this.recurrence,
      this.flexible = false,
      this.userId});

  factory Task.fromFirestore(String? id, Map<String, dynamic> js) {
    return Task(
      userId: js['userId'],
      id: id,
      name: js['name']! as String,
      date: js['date'] as Timestamp,
      startTime: js['startTime'] as Timestamp,
      endTime: js['endTime'] as Timestamp,
      done: js['done']! as bool,
      allDay: js['allDay']! as bool,
      color: js['color'] != null ? Color(js['color']) : null,
      priority: js['priority'],
      description: js['description'],
      recurrence: js['recurrence'] ?? 'None',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'done': done,
      'allDay': allDay,
      'color': color?.value,
      'priority': priority,
      'description': description,
      'recurrence': recurrence,
    };
  }

  static Future<List<Task>> getTodaysTasksList(
      FirebaseFirestore firestore, String? userId) async {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final endDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final readfirebase = await firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();
    List<Task> tasks = readfirebase.docs
        .map((doc) {
          final data = doc.data();
          final DateTime start_time = (data['startTime'] as Timestamp).toDate();

          if (start_time.isAfter(dayStart) && start_time.isBefore(endDay)) {
            return Task.fromFirestore(doc.id, data);
          }
          return null;
        })
        .whereType<Task>()
        .toList();

    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    return tasks;
  }

  static Future<List<Task>> getAllTasks(
      FirebaseFirestore firestore, String userId) async {
    print('user:  $userId');
    final allTasks = await firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();
    print('Tasks fetched: ${allTasks.docs.length}');
    return allTasks.docs
        .map((doc) => Task.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<void> updateDoneBool(FirebaseFirestore firestore, bool isDone,
      String idTask, BuildContext? context, FirebaseAuth auth) async {
    final point = Point(auth: auth, firestore: firestore);

    await firestore.collection('tasks').doc(idTask).update({
      'done': isDone,
      'color': isDone ? Colors.grey.value : Colors.green.value,
    });

    if (isDone) {
      if (context != null) {
        final animalEntity = Provider.of<Animal>(context, listen: false);
        animalEntity.changeToHappyAnimal();
      }
      await point.addPoints(10);
      print("Points added");
    } else {
      await point.deletePoints(10);
      print("Points removed");
    }
  }

  static Future<Map<String, List<Task>>> getFlexibleTaskToghether(
      FirebaseFirestore firestore, String userId) async {
    final tasks = await Task.getAllTasks(firestore, userId);
    final Map<String, List<Task>> allTasksFlexible = {};

    for (var task in tasks) {
      if (task.name.contains(', sub')) {
        String taskName = task.name.split(', sub')[0].trim();

        if (!allTasksFlexible.containsKey(taskName)) {
          allTasksFlexible[taskName] = [];
        }
        allTasksFlexible[taskName]!.add(task);
      }
    }
    return allTasksFlexible;
  }

  static Map<String, List<Task>> getTasksOfPriorityStr(
      Map<String, List<Task>> allTaskList, String priority, bool filter) {
    final Map<String, List<Task>> resultList = {};
    const allPriorities = {'High', 'Medium', 'Low'};
    if (!allPriorities.contains(priority)) {
      priority = 'Low';
    }

//week checking
    DateTime startOfWeek =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .subtract(Duration(days: DateTime.now().weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    allTaskList.forEach((taskName, sub) {
      bool samePriority = sub.any((task) => task.priority == priority);

      bool notdoneTasks = sub.any((task) => !task.done);

      bool thisWeek = sub.any((task) {
        DateTime taskDate = task.date.toDate();
        return taskDate.isAfter(startOfWeek.subtract(Duration(seconds: 1))) &&
            taskDate.isBefore(endOfWeek.add(Duration(days: 1)));
      });

      //filter = true this week    ,,,, flase then unfinished
      if (samePriority) {
        if (filter && thisWeek) {
          resultList[taskName] = sub;
        } else if (!filter && notdoneTasks) {
          resultList[taskName] = sub.where((task) => !task.done).toList();
        }
      }
    });

    return resultList;
  }

  static double calculateProgress(List<Task> tasks) {
    int doneTasks = tasks.where((task) => task.done).length;
    return doneTasks / tasks.length;
  }
}
