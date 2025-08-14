import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_year_project/entity/animal.dart';
import 'package:final_year_project/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:final_year_project/pages/progress.dart';
import 'package:final_year_project/entity/task.dart';
import 'package:mockito/mockito.dart';
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

  testWidgets('Home widget display elements correctly',
      (WidgetTester tester) async {
    final mockFirebaseAuth = MockFirebaseAuth();
    final mockFirestore = FakeFirebaseFirestore();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => Animal(firestore: firestore, auth: mockAuth)),
            ChangeNotifierProvider(create: (_) => ThemeManager()),
          ],
          child: Home(auth: mockFirebaseAuth, firestore: mockFirestore),
        ),
      ),
    );

    expect(find.text('Task Manager'), findsOneWidget);
    //expect(find.byType(ListView), findsOneWidget);
  });
  testWidgets('Home widget displays tasks on Todays tasks ',
      (WidgetTester tester) async {
    final mockUser = MockUser(uid: 'user1', email: 'test@example.com');

    await firestore.collection('users').doc('user1').set({
      'profileImageIndex': 1,
      'animalMoving': false,
      'Sounds': false,
      'points': 300,
    });

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

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(
              create: (_) => Animal(firestore: firestore, auth: mockAuth),
            ),
          ],
          child: Home(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('task high , sub'), findsOneWidget);
    expect(find.text('low test'), findsNothing);
  });
  testWidgets('Home widget displays  checkbox is ticked when task is done ',
      (WidgetTester tester) async {
    final mockUser = MockUser(uid: 'user1', email: 'test@example.com');

    await firestore.collection('users').doc(mockUser.uid).set({
      'profileImageIndex': 1,
      'animalMoving': false,
      'Sounds': false,
      'points': 300,
    });

    final today = DateTime.now().toUtc();
    final task = await firestore.collection('tasks').add({
      'name': 'task high , sub',
      'done': true,
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
              create: (_) => Animal(firestore: firestore, auth: mockAuth),
            ),
          ],
          child: Home(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('task high , sub'), findsOneWidget);
    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);
  });
}
