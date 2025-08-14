import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphite/graphite.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../entity/task.dart';
import '../managers/theme_Manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class Progress extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Progress({required this.auth, required this.firestore});
  @override
  _Progress createState() => _Progress();
}

class _Progress extends State<Progress> {
  late Future<Map<String, List<Task>>> _taskForProgressList;
  Map<String, List<Task>> _highPriorityTasks = {};
  Map<String, List<Task>> _mediumPriorityTasks = {};
  Map<String, List<Task>> _lowPriorityTasks = {};
  String? userId;
  Map<String, bool> _expandTaskNameToShowGraph = {};
  String _selectedTasks = "This Week's Tasks";

  @override
  void initState() {
    super.initState();
    final user = widget.auth.currentUser;
    userId = user?.uid;
    print("should be signed $userId");

    if (userId != null) {
      _taskForProgressList =
          Task.getFlexibleTaskToghether(widget.firestore, userId!);

      _taskForProgressList.then((tasks) {
        print('Tasks loaded initi: $tasks');
      });
    } else {
      _taskForProgressList = Future.value({});
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progress Page',
          style: TextStyle(
            fontSize: themeManager.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(30),
                constraints: BoxConstraints(minWidth: 80, minHeight: 40),
                isSelected: [
                  _selectedTasks == "Unfinished Tasks",
                  _selectedTasks == "This Week's Tasks"
                ],
                onPressed: (int index) {
                  setState(() {
                    _selectedTasks =
                        index == 0 ? "Unfinished Tasks" : "This Week's Tasks";
                  });
                },
                children: [
                  Semantics(
                    button: true,
                    label: "Filter Unfinished Tasks",
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Unfinished Tasks",
                          style: TextStyle(
                            fontSize: themeManager.fontSize * 0.5,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  Semantics(
                    button: true,
                    label: "Filter  This Week Tasks",
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "This Week's Tasks",
                          style: TextStyle(
                            fontSize: themeManager.fontSize * 0.5,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, List<Task>>>(
              future: _taskForProgressList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }

                final taskDic = snapshot.data ?? {};
                print('Tasks loaded: $taskDic');
                bool filterTask = _selectedTasks == "This Week's Tasks";
                _highPriorityTasks =
                    Task.getTasksOfPriorityStr(taskDic, "High", filterTask);
                _mediumPriorityTasks =
                    Task.getTasksOfPriorityStr(taskDic, "Medium", filterTask);
                _lowPriorityTasks =
                    Task.getTasksOfPriorityStr(taskDic, "Low", filterTask);

                return ListView(
                  children: [
                    _buildEachPriority(
                        context, themeManager, "High", _highPriorityTasks),
                    _buildEachPriority(
                        context, themeManager, "Medium", _mediumPriorityTasks),
                    _buildEachPriority(
                        context, themeManager, "Low", _lowPriorityTasks)
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEachPriority(BuildContext context, ThemeManager themeManager,
      String priority, Map<String, List<Task>> taskDic) {
    Color c = Colors.white;
    if (priority == 'Low') {
      c = Colors.green;
    }
    if (priority == 'Medium') {
      c = const Color.fromARGB(255, 186, 174, 63);
    }
    if (priority == 'High') {
      c = Colors.red;
    }

    if (taskDic.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8.0),
            child: Column(children: [
              Stack(
                children: [
                  Text(
                    "$priority Priority Tasks",
                    style: TextStyle(
                      fontSize: themeManager.fontSize,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.black,
                    ),
                  ),
                  Text(
                    "$priority Priority Tasks",
                    style: TextStyle(
                      fontSize: themeManager.fontSize,
                      fontWeight: FontWeight.bold,
                      color: c,
                    ),
                  ),
                ],
              )
            ])),
        const SizedBox(height: 10),
        Text(
          "   No sub tasks to view",
          style: TextStyle(
            fontSize: themeManager.fontSize * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Stack(
            children: [
              Text(
                "$priority Priority Tasks",
                style: GoogleFonts.poppins(
                  fontSize: themeManager.fontSize,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.black,
                ),
              ),
              Text(
                "$priority Priority Tasks",
                style: GoogleFonts.poppins(
                  fontSize: themeManager.fontSize,
                  fontWeight: FontWeight.bold,
                  color: c,
                ),
              ),
            ],
          )),
      ...taskDic.entries.map((entry) {
        final taskName = entry.key;
        final subTasks = entry.value;
        final progress = Task.calculateProgress(subTasks);

        bool allSubtasksCompleted = subTasks.every((task) => task.done);
        Color taskColor = allSubtasksCompleted ? Colors.green : Colors.red;
        subTasks.sort((a, b) {
          final aNum = int.tryParse(a.name.split(', sub').last.trim()) ?? 0;
          final bNum = int.tryParse(b.name.split(', sub').last.trim()) ?? 0;
          return aNum.compareTo(bNum);
        });

        final subList = [
          '{"id":"$taskName","next":[${subTasks.map((subTask) {
            final number = subTask.name.split(', sub').last.trim();
            final des = subTask.description;
            return '{"outcome":"$number $des"}';
          }).join(',')}]}'
        ];

        for (var subTask in subTasks) {
          final number = subTask.name.split(', sub').last.trim();
          final des = subTask.description;
          subList.add('{"id":"$number $des","next":[]}');
        }

        final subListString = '[${subList.join(',')}]';

        print(subListString);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: "Task ${taskName}",
                child: Text(
                  taskName,
                  style: TextStyle(
                    fontSize: themeManager.fontSize * 0.8,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Semantics(
                label: "Progress: ${(progress * 100).toInt()}% completed",
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(20),
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    color: progress == 1.0
                        ? Colors.green
                        : const Color.fromARGB(255, 179, 74, 74),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    bool clicked =
                        _expandTaskNameToShowGraph[taskName] ?? false;
                    _expandTaskNameToShowGraph[taskName] = !clicked;
                  });
                },
                child: Text(
                  _expandTaskNameToShowGraph[taskName] ?? false ? '^' : '>',
                  style: TextStyle(
                    fontSize: themeManager.fontSize * 0.8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: _expandTaskNameToShowGraph[taskName] ?? false,
                child: IntrinsicHeight(
                  child: Center(
                    child: Container(
                      child: InteractiveViewer(
                        child: DirectGraph(
                          orientation: MatrixOrientation.Horizontal,
                          list: nodeInputFromJson(subListString),
                          defaultCellSize: const Size(130.0, 60.0),
                          cellPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          nodeBuilder: (context, node) {
                            Color box_color;
                            String taskStatus = "Incomplete";

                            bool allCompleted =
                                subTasks.every((task) => task.done);
                            if (node.id == taskName) {
                              box_color = allCompleted
                                  ? Colors.green
                                  : const Color.fromARGB(205, 255, 255, 255);
                            } else {
                              final ind = subTasks.indexWhere((task) {
                                final taskNumber =
                                    task.name.split(', sub').last.trim();
                                return node.id.startsWith(taskNumber);
                              });

                              if (ind == -1) {
                                print('Subtask not found: ${node.id}');
                                box_color = Colors.grey;
                                taskStatus = "Unknown ";
                              } else {
                                if (subTasks[ind].done) {
                                  box_color = Colors.green;
                                  taskStatus = "Completed";
                                } else {
                                  box_color =
                                      const Color.fromARGB(255, 179, 74, 74);
                                }
                              }
                            }
                            return GestureDetector(
                                onTap: () {
                                  if (node.id != taskName) {
                                    _taskInfoFromProgress(
                                        subTasks, node.id, context);
                                  }
                                },
                                child: Semantics(
                                  label: "${node.id}, Status: $taskStatus",
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: box_color,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      node.id,
                                      style: TextStyle(
                                        fontSize: themeManager.fontSize * 0.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }).toList(),
    ]);
  }

  Future<String?> getTaskById(
      String name, DateTime startTime, DateTime endTime) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('name', isEqualTo: name)
        .where('startTime', isEqualTo: Timestamp.fromDate(startTime))
        .where('endTime', isEqualTo: Timestamp.fromDate(endTime))
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print("Task found");
      return querySnapshot.docs.first.id;
    } else {
      print("Task not found");
      return null;
    }
  }

  void _taskInfoFromProgress(
      List<Task> subTasks, String subTaskName, BuildContext context) async {
    Task? selectedSubTask = subTasks.firstWhere(
      (task) => subTaskName.startsWith(task.name.split(', sub').last.trim()),
      orElse: () => Task(
        name: subTaskName,
        date: Timestamp.now(),
        startTime: Timestamp.now(),
        endTime: Timestamp.now(),
        done: false,
        allDay: false,
      ),
    );

    if (selectedSubTask == null) return;

    String? taskId = await getTaskById(
      selectedSubTask.name,
      selectedSubTask.startTime.toDate(),
      selectedSubTask.endTime.toDate(),
    );

    Task? allTaskParam;
    if (taskId != null) {
      final taskDoc = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .get();
      if (taskDoc.exists) {
        allTaskParam = Task.fromFirestore(taskDoc.id, taskDoc.data()!);
      }
    }

    TextEditingController descriptionController = TextEditingController(
        text: allTaskParam?.description ?? "No description");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Subtask Information',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 300,
            height: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Task: "${selectedSubTask.name}"\n'
                    'Start: ${DateFormat('HH:mm').format(selectedSubTask.startTime.toDate())}\n'
                    'End: ${DateFormat('HH:mm').format(selectedSubTask.endTime.toDate())}\n',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Task Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      minLines: 2,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (taskId != null) {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(taskId)
                      .update({'description': descriptionController.text});
                  print('Description updated');
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
