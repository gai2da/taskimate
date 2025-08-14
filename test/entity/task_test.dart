import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_year_project/entity/animal.dart';
import 'package:final_year_project/entity/point.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_year_project/entity/task.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../mocks.mocks.dart';
import '../firebase_mock.dart';
import 'task_test.mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks;
//import '../services/auth_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  User,
  UserCredential,
  FirebaseFirestore,
  DocumentReference,
  DocumentSnapshot,
  Animal,
  Point,
], customMocks: [
  MockSpec<BuildContext>(as: #MockBuildContext),
])
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  //change whe re build
  late auth_mocks.MockUser mockUser;
  late MockPoint mockPoint;
  late MockAnimal mockAnimal;
  late MockBuildContext mockContext;
  late String taskId;
  late Task task;

  setUpAll(() async {
    await initializeMockFirebase();
  });
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = auth_mocks.MockUser(
      uid: "user_123",
      email: "test@example.com",
    );
    mockPoint = MockPoint();
    mockAnimal = MockAnimal();
    mockContext = MockBuildContext();
    taskId = "testTaskId";

    await firestore.collection('users').doc(mockUser.uid).set({'points': 0});

    when(mockContext.owner).thenReturn(null);
    when(mockAuth.currentUser).thenReturn(mockUser);
    final taskRef = await firestore.collection('tasks').add({
      'name': 'Test Task',
      'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
      'startTime':
          Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
      'endTime': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
      'done': false,
      'allDay': false,
      'userId': mockUser.uid,
    });

    task = Task(
      name: "Test Task",
      date: Timestamp.now(),
      startTime: Timestamp.now(),
      endTime: Timestamp.now(),
      done: false,
      allDay: false,
      color: Colors.blue,
      priority: "High",
      id: taskRef.id,
      description: "Test Description",
      recurrence: null,
      flexible: false,
      userId: mockUser.uid,
    );

    taskId = taskRef.id;
  });

  test("task.updateDoneBool should update true bool ", () async {
    final taskId = "task123";
    await firestore.collection('tasks').doc(taskId).set({
      'done': false,
    });

    await task.updateDoneBool(firestore, true, taskId, null, mockAuth);

    final updatedTask = await firestore.collection('tasks').doc(taskId).get();

    expect(updatedTask.data()?['done'], true);
  });

  test("Task.updateDoneBool should update false bool and delete points",
      () async {
    final taskId = "task123";
    await firestore.collection('tasks').doc(taskId).set({
      'done': true,
    });

    await task.updateDoneBool(firestore, false, taskId, null, mockAuth);

    final updatedTask = await firestore.collection('tasks').doc(taskId).get();

    expect(updatedTask.data()?['done'], false);
  });

  test('Task.getTodaysTasksList should return only today tasks', () async {
    final today = DateTime.now().toUtc();
    final String testUserId = mockUser.uid;
    await firestore.collection('tasks').add({
      'name': 'todays Task',
      'date': Timestamp.fromDate(today),
      'startTime': Timestamp.fromDate(today),
      'endTime': Timestamp.fromDate(today.add(Duration(hours: 1))),
      'done': false,
      'allDay': false,
      'userId': testUserId,
    });

    await firestore.collection('tasks').add({
      'name': 'prev Task',
      'date': Timestamp.fromDate(today.subtract(Duration(days: 1))),
      'startTime': Timestamp.fromDate(today.subtract(Duration(days: 1))),
      'endTime': Timestamp.fromDate(today.subtract(Duration(days: 1))),
      'done': false,
      'allDay': false,
      'userId': testUserId,
    });

    final tasks = await Task.getTodaysTasksList(
      firestore,
      mockUser.uid,
    );

    expect(tasks.length, 1);
    expect(tasks.first.name, 'todays Task');
  });

  test('Task.toFirestore saves correctly ', () {
    final task = Task(
      name: "task1",
      date: Timestamp.fromDate(DateTime(2025, 5, 12)),
      startTime: Timestamp.fromDate(DateTime(2025, 5, 12, 15, 00)),
      endTime: Timestamp.fromDate(DateTime(2025, 5, 12, 16, 30)),
      done: false,
      allDay: false,
      userId: "user1",
      priority: "High",
      description: "try",
    );

    final save = task.toFirestore();

    expect(save['name'], "task1");
    expect(save['done'], false);
    expect(save['priority'], "High");
    expect(save['description'], "try");
    expect(save['userId'], "user1");
  });

  test('Task.fromFirestore return correctly from firestore', () {
    final data = {
      'name': "Task try",
      'date': Timestamp.fromDate(DateTime(2025, 6, 20)),
      'startTime': Timestamp.fromDate(DateTime(2025, 6, 20, 10, 00)),
      'endTime': Timestamp.fromDate(DateTime(2025, 6, 20, 11, 30)),
      'done': true,
      'allDay': false,
      'userId': "user4",
      'priority': "Medium",
      'description': "test saving to firestore",
    };

    final task = Task.fromFirestore("task123", data);

    expect(task.name, equals("Task try"));
    expect(task.priority, equals("Medium"));
    expect(task.done, isTrue);
    expect(task.allDay, isFalse);
    expect(task.startTime.toDate().hour, 10);
    expect(task.endTime.toDate().minute, 30);
  });

  test('Task.calculateProgress should return correct percentage', () {
    final tasks = [
      Task(
        name: "Task 1",
        date: Timestamp.fromDate(DateTime(2025, 5, 12)),
        startTime: Timestamp.fromDate(DateTime(2025, 5, 12, 10, 00)),
        endTime: Timestamp.fromDate(DateTime(2025, 5, 12, 11, 00)),
        done: true,
        allDay: false,
        userId: "user2",
      ),
      Task(
        name: "Task 2",
        date: Timestamp.fromDate(DateTime(2025, 5, 12)),
        startTime: Timestamp.fromDate(DateTime(2025, 5, 12, 12, 00)),
        endTime: Timestamp.fromDate(DateTime(2025, 5, 12, 13, 00)),
        done: false,
        allDay: false,
        userId: "user2",
      ),
    ];
    final progress = Task.calculateProgress(tasks);
    expect(progress, equals(0.5));
  });

  ///updateDoneBool(FirebaseFirestore firestore, bool isDone,String idTask, BuildContext context)
  ///
  ///
  test('Task.getFlexibleTaskToghether should group them together', () async {
    final userId = "user2";

    await firestore.collection('tasks').add({
      'name': 'task 1, sub 1',
      'date': Timestamp.now(),
      'startTime': Timestamp.now(),
      'endTime': Timestamp.now(),
      'done': false,
      'allDay': false,
      'userId': userId,
    });

    await firestore.collection('tasks').add({
      'name': 'task 1, sub 2',
      'date': Timestamp.now(),
      'startTime': Timestamp.now(),
      'endTime': Timestamp.now(),
      'done': false,
      'allDay': false,
      'userId': userId,
    });

    await firestore.collection('tasks').add({
      'name': 'task 1',
      'date': Timestamp.now(),
      'startTime': Timestamp.now(),
      'endTime': Timestamp.now(),
      'done': false,
      'allDay': false,
      'userId': userId,
    });

    final flexTasks = await Task.getFlexibleTaskToghether(firestore, userId);

    expect(flexTasks['task 1']!.length, 2);
    expect(flexTasks.containsKey('task 2'), false);
  });

  test('Task.getTasksOfPriorityStr filters tasks by priority', () {
    final allTasks = {
      'group1': [
        Task(
          name: "High task",
          date: Timestamp.now(),
          startTime: Timestamp.now(),
          endTime: Timestamp.now(),
          done: false,
          allDay: false,
          priority: "High",
          userId: "user1",
        ),
        Task(
          name: "Low task",
          date: Timestamp.now(),
          startTime: Timestamp.now(),
          endTime: Timestamp.now(),
          done: false,
          allDay: false,
          priority: "Low",
          userId: "user1",
        ),
      ],
      'group2': [
        Task(
          name: "Low task",
          date: Timestamp.now(),
          startTime: Timestamp.now(),
          endTime: Timestamp.now(),
          done: false,
          allDay: false,
          priority: "Low",
          userId: "user1",
        ),
        Task(
          name: "High  task",
          date: Timestamp.now(),
          startTime: Timestamp.now(),
          endTime: Timestamp.now(),
          done: false,
          allDay: false,
          priority: "High",
          userId: "user1",
        ),
      ],
    };

    final highPriorityTasks =
        Task.getTasksOfPriorityStr(allTasks, "High", false);
    final lowPriorityTasks = Task.getTasksOfPriorityStr(allTasks, "Low", false);

    expect(highPriorityTasks.containsKey('group1'), true);
    expect(highPriorityTasks['group1']!.length, 2);

    expect(highPriorityTasks.containsKey('group2'), true);

    expect(lowPriorityTasks.containsKey('group2'), true);
    expect(lowPriorityTasks['group2']!.length, 2);

    expect(lowPriorityTasks.containsKey('group1'), true);
  });
}
