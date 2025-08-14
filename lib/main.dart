import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'managers/Task_manager.dart';
import 'pages/home.dart';
import 'pages/Calendar.dart';
import 'pages/profile.dart';
import 'pages/progress.dart';
import 'pages/resources.dart';
import 'managers/theme_Manager.dart';
import 'entity/colorMood.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'entity/animal.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  ThemeManager themeManager = ThemeManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeManager()..fetchUserPreferences(),
        ),
        ChangeNotifierProvider(
          create:
              (context) => Animal(
                firestore: FirebaseFirestore.instance,
                auth: FirebaseAuth.instance,
                testingBool: false,
              )..fetchAnimalPreferences(),
        ),
        ChangeNotifierProvider(create: (_) => TasksManager()),
      ],
      child: const MyApp(),
    ),
  );
  await startNotification();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          theme: light_mode,
          darkTheme: dark_mode,
          home: MainPage(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _navegationScreen createState() => _navegationScreen();
}

class _navegationScreen extends State<MainPage> {
  int _pageindex = 0;

  //pages on the navegation bar
  final List<Widget> _pages = [
    Home(firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance),
    Calendar(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
    Progress(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
    Resources(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _changeIndex(int ind) {
    setState(() {
      _pageindex = ind;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageindex,
        onTap: _changeIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Calendar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Resources'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

Future<void> startNotification() async {
  tz.initializeTimeZones();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
