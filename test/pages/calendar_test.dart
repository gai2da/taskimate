import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_year_project/entity/animal.dart';
import 'package:final_year_project/pages/Calendar.dart';
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
import 'package:syncfusion_flutter_calendar/calendar.dart';
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

  testWidgets('Calender widget display elements correctly',
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
          child: Calendar(auth: mockFirebaseAuth, firestore: mockFirestore),
        ),
      ),
    );

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.byType(ListView), findsAny);
  });
  testWidgets('Calendar widget show SfCalendar', (WidgetTester tester) async {
    final mockUser = MockUser(uid: 'user1', email: 'test@example.com');

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
          child: Calendar(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Test Task'), findsNothing);
    expect(find.byType(SfCalendar), findsAny);
  });

  testWidgets('Calendar widget have all buttons ', (WidgetTester tester) async {
    final mockUser = MockUser(uid: 'user1', email: 'test@example.com');
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(
              create: (_) => Animal(firestore: firestore, auth: mockAuth),
            ),
          ],
          child: Calendar(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    await tester.pump();
    final addButton = find.byIcon(Icons.add);

    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Calendar widget  : add task work ', (WidgetTester tester) async {
    final mockUser = MockUser(uid: 'user1', email: 'test@example.com');

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(
              create: (_) => Animal(firestore: firestore, auth: mockAuth),
            ),
          ],
          child: Calendar(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    final addButton = find.byIcon(Icons.add);
    expect(addButton, findsOneWidget);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Calendar widget Check zoom in and zoom out work',
      (WidgetTester tester) async {
    final mockUser = MockUser(uid: 'user1', email: 'test@example.com');

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeManager()),
            ChangeNotifierProvider(
              create: (_) => Animal(firestore: firestore, auth: mockAuth),
            ),
          ],
          child: Calendar(auth: mockAuth, firestore: firestore),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.zoom_in));
    await tester.pump();
    expect(find.byType(SfCalendar), findsOneWidget);
    await tester.tap(find.byIcon(Icons.zoom_out));
    await tester.pump();
    expect(find.byType(SfCalendar), findsOneWidget);
  });
}
