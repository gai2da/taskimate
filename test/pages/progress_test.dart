import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_year_project/entity/animal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:final_year_project/pages/progress.dart';
import 'package:final_year_project/entity/task.dart';
import 'package:provider/provider.dart';
import 'package:final_year_project/managers/theme_Manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_mock.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUpAll(() async {
    await initializeMockFirebase();
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockUser = MockUser(
      isAnonymous: false,
      uid: 'user1',
      email: 'test@example.com',
      displayName: 'test',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
  });

  testWidgets('Progress widget display elements correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => Animal(firestore: firestore, auth: mockAuth)),
            ChangeNotifierProvider(create: (_) => ThemeManager()),
          ],
          child: Progress(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    expect(find.text('Progress Page'), findsOneWidget);
    expect(find.text('Unfinished Tasks'), findsOneWidget);
    expect(find.text("This Week's Tasks"), findsOneWidget);
    //expect(find.byType(ListView), findsOneWidget);
  });
  testWidgets('Progress widget displays tasks correctly based on priority',
      (WidgetTester tester) async {
    print("starttt");
    final today = DateTime.now().toUtc();
    await firestore.collection('tasks').add({
      'name': 'task high , sub',
      'done': false,
      'priority': 'High',
      'date': Timestamp.fromDate(today),
      'startTime': Timestamp.fromDate(today),
      'endTime': Timestamp.fromDate(today.add(Duration(hours: 1))),
      'allDay': false,
      'userId': mockUser.uid,
    });
    final taskDocs = await firestore.collection('tasks').get();
    print('Tasks in Firestore:');
    taskDocs.docs.forEach((doc) {
      print(doc.data());
    });
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(
                create: (_) => Animal(firestore: firestore, auth: mockAuth)),
          ],
          child: Progress(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('task high'), findsOneWidget);
    expect(find.text('low test'), findsNothing);
  });

  testWidgets('Progress bar shows 0% progress for incomplete task',
      (WidgetTester tester) async {
    final today = DateTime.now().toUtc();
    await firestore.collection('tasks').add({
      'name': 'task high , sub',
      'done': false,
      'priority': 'High',
      'date': Timestamp.fromDate(today),
      'startTime': Timestamp.fromDate(today),
      'endTime': Timestamp.fromDate(today.add(Duration(hours: 1))),
      'allDay': false,
      'userId': mockUser.uid,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(
                create: (_) => Animal(firestore: firestore, auth: mockAuth)),
          ],
          child: Progress(auth: mockAuth, firestore: firestore),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final progressBar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).first,
    );
    expect(progressBar.value, 0.0);
  });

  testWidgets('Progress bar shows 100% progress for complete task',
      (WidgetTester tester) async {
    final today = DateTime.now().toUtc();
    await firestore.collection('tasks').add({
      'name': 'task high , sub',
      'done': true,
      'priority': 'High',
      'date': Timestamp.fromDate(today),
      'startTime': Timestamp.fromDate(today),
      'endTime': Timestamp.fromDate(today.add(Duration(hours: 1))),
      'allDay': false,
      'userId': mockUser.uid,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(
                create: (_) => Animal(firestore: firestore, auth: mockAuth)),
          ],
          child: Progress(auth: mockAuth, firestore: firestore),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    final progressBar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator).first,
    );
    expect(progressBar.value, 1.0);
  });
}
