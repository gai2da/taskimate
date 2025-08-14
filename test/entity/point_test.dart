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
import 'point_test.mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks;
//import '../services/auth_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  FirebaseFirestore,
  DocumentReference,
  DocumentSnapshot,
])
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late auth_mocks.MockUser mockUser;
  late Point point;

  setUpAll(() async {
    await initializeMockFirebase();
  });
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = auth_mocks.MockUser(
      uid: "user1",
      email: "test@example.com",
    );

    //when(mockUser.uid).thenReturn("user1");
    when(mockAuth.currentUser).thenReturn(mockUser);

    point = Point(auth: mockAuth, firestore: firestore);
  });
  test("Point.addPoints  correctly return 0 points when user is null ",
      () async {
    final doc = firestore.collection('users').doc(mockUser.uid);
    final s = await doc.get();

    expect(s.exists, isFalse);
    await point.addPoints(0);

    final updatedDoc =
        await firestore.collection('users').doc(mockUser.uid).get();
    expect(updatedDoc.data()?['points'], 0);
  });

  test("Point.addPoints  correctly add points", () async {
    await firestore.collection('users').doc(mockUser.uid).set({'points': 0});
    await point.addPoints(10);
    final updatedDoc =
        await firestore.collection('users').doc(mockUser.uid).get();
    expect(updatedDoc.data()?['points'], 10);
  });

  test("Point.deletePoints  correctly delete points", () async {
    await firestore.collection('users').doc(mockUser.uid).set({'points': 100});
    await point.deletePoints(10);
    final updatedDoc =
        await firestore.collection('users').doc(mockUser.uid).get();
    expect(updatedDoc.data()?['points'], 90);
  });
  test("Point.deletePoints  correctly return 0 points when user is null ",
      () async {
    final doc = firestore.collection('users').doc(mockUser.uid);
    final s = await doc.get();

    expect(s.exists, isFalse);
    await point.deletePoints(0);

    final updatedDoc =
        await firestore.collection('users').doc(mockUser.uid).get();
    expect(updatedDoc.data()?['points'], 0);
  });

  test("Point.getPoints  correctly return points", () async {
    await firestore.collection('users').doc(mockUser.uid).set({'points': 100});
    final pointStream = point.getPoints();
    expect(await pointStream.first, 100);
  });

  test("Point.getPoints  correctly return 0 when userID is null", () async {
    when(mockAuth.currentUser).thenReturn(null);
    final pointStream = point.getPoints();
    expect(await pointStream.first, 0);
  });
}
