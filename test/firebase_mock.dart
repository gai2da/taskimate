import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

Future<void> initializeMockFirebase() async {
  setupFirebaseAuthMocks();
  await Firebase.initializeApp();
}
