import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_year_project/entity/UserEntity.dart';
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
import 'userEntity_test.mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks;
//import '../services/auth_test.mocks.dart';
import 'package:firebase_core/firebase_core.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  FirebaseFirestore,
  DocumentSnapshot,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late auth_mocks.MockUser mockUser;
  late FakeFirebaseFirestore firestore;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeMockFirebase();
  });
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = auth_mocks.MockUser(uid: "user1", email: "test@example.com");

    when(mockAuth.currentUser).thenReturn(mockUser);
  });

  test("UserEntity initializes correctly", () {
    final user = UserEntity(
      id: "user1",
      email: "test@example.com",
      points: 50,
      profileImageIndex: 2,
    );

    expect(user.id, "user1");
    expect(user.email, "test@example.com");
    expect(user.points, 50);
    expect(user.profileImageIndex, 2);
  });

  test("UserEntity.tofireStoreFormate correctly", () {
    final user = UserEntity(
      id: "user1",
      email: "test@example.com",
      points: 100,
      profileImageIndex: 1,
    );

    final firestoreData = user.tofireStoreFormate();

    expect(firestoreData['email'], "test@example.com");
    expect(firestoreData['points'], 100);
    expect(firestoreData['profileImageIndex'], 1);
  });

  test("UserEntity.fromfireStoreFormate correctly ", () {
    final data = {
      'email': "test@example.com",
      'points': 50,
      'profileImageIndex': 2,
    };

    final user = UserEntity.fromfireStoreFormate("user2", data);

    expect(user.id, "user2");
    expect(user.email, "test@example.com");
    expect(user.points, 50);
    expect(user.profileImageIndex, 2);
  });
}
