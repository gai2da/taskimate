import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_year_project/entity/task.dart';

void main() {
  group('Task Manager Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('Task Fetch from fireStore', () async {
      final taskRef = await fakeFirestore.collection('tasks').add({
        'name': "try",
        'date': Timestamp.fromDate(DateTime(2025, 8, 20)),
        'startTime': Timestamp.fromDate(DateTime(2025, 8, 20, 12, 00)),
        'endTime': Timestamp.fromDate(DateTime(2025, 8, 20, 16, 00)),
        'done': false,
        'allDay': false,
        'userId': "user456",
        'priority': "Medium",
        'description': "Try testing ",
      });

      final docSnapshot = await taskRef.get();
      final task = Task.fromFirestore(taskRef.id, docSnapshot.data()!);

      expect(task.name, "try");
      expect(task.priority, "Medium");
      expect(task.done, isFalse);
      expect(task.allDay, isFalse);
      expect(task.startTime.toDate().hour, 12);
      expect(task.endTime.toDate().minute, 00);
    });

    test('Fetch All Tasks for a User ', () async {
      const userId = "Me123";

      await fakeFirestore.collection('tasks').add({
        'name': "tryOne",
        'date': Timestamp.fromDate(DateTime.now()),
        'startTime': Timestamp.fromDate(DateTime.now().add(Duration(hours: 1))),
        'endTime': Timestamp.fromDate(DateTime.now().add(Duration(hours: 2))),
        'done': false,
        'allDay': false,
        'userId': userId,
        'priority': "Low",
        'description': "trying",
      });

      final tasks = await Task.getAllTasks(fakeFirestore, userId);

      expect(tasks.length, greaterThan(0));
      expect(tasks.first.name, equals("tryOne"));
    });
  });
}
