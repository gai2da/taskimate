import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/UserEntity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../entity/animal.dart';
import '../managers/theme_Manager.dart';
import '../managers/Task_manager.dart';

class TasksSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    final animalEntity = Provider.of<Animal>(context, listen: true);
    final tasksManager = Provider.of<TasksManager>(context);
    return AlertDialog(
      title: Text(
        "Task Settings",
        style: TextStyle(
          fontSize: themeManager.fontSize * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              "Sleeping Start Time",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              tasksManager.sleepingStartTime.format(context),
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: tasksManager.sleepingStartTime,
              );
              if (pickedTime != null) {
                tasksManager.setSleepingStartTime(pickedTime);
              }
            },
          ),
          ListTile(
            title: Text(
              "Sleeping End Time",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              tasksManager.sleepingEndTime.format(context),
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: tasksManager.sleepingEndTime,
              );
              if (pickedTime != null) {
                tasksManager.setSleepingEndTime(pickedTime);
              }
            },
          ),
          ListTile(
            title: Text(
              "Productive  Time start",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              tasksManager.productiveStartTime.format(context),
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: tasksManager.productiveStartTime,
              );
              if (time != null) {
                tasksManager.setProductiveStartTime(time);
              }
            },
          ),
          ListTile(
            title: Text(
              "Productive  Time ends",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              tasksManager.productiveEndTime.format(context),
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: tasksManager.productiveEndTime,
              );
              if (time != null) {
                tasksManager.setProductiveEndTime(time);
              }
            },
          ),
          ListTile(
            title: Text(
              "Focus Duration",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              "${tasksManager.focusDuration} min",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Slider(
            value: tasksManager.focusDuration.toDouble(),
            min: 20,
            max: 120,
            divisions: 20,
            onChanged: (double value) {
              tasksManager.setFocusDuration(value.toInt());
            },
          ),
          ListTile(
            title: Text(
              "Break Duration",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.45,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              "${tasksManager.breakDuration} min",
              style: TextStyle(
                fontSize: themeManager.fontSize * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Slider(
            value: tasksManager.breakDuration.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            onChanged: (double value) {
              tasksManager.setBreakDuration(value.toInt());
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
          onPressed: () async {
            await tasksManager.updateTaskPreferences();

            Navigator.pop(context);
          },
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
}
