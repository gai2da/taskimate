import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_year_project/entity/animal.dart';
import 'package:final_year_project/entity/point.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_year_project/entity/task.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../mocks.mocks.dart';
import '../firebase_mock.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as auth_mocks;
//import '../services/auth_test.mocks.dart';
import 'animal_test.mocks.dart';
import '../helpers/audioplayer_m.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  FirebaseFirestore,
  DocumentReference,
  DocumentSnapshot,
  Animal,
])
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth mockAuth;
  late auth_mocks.MockUser mockUser;
  late Animal animal;
  late MockAnimal mockAnimal;
  final AudioPlayer audioPlayer;

  setUpAll(() async {
    await initializeMockFirebase();
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockAudioPlayers();
  });
  setUp(() async {
    firestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = auth_mocks.MockUser(
      uid: "user1",
      email: "test@example.com",
    );
    mockAnimal = MockAnimal();
    //when(mockUser.uid).thenReturn("user1");
    when(mockAuth.currentUser).thenReturn(mockUser);

    animal = Animal(firestore: firestore, auth: mockAuth, testingBool: true);

    //mockHomeWidget = MockHomeWidget();
  });

  test("Animal.currentAnimal  correctly return mood", () {
    expect(animal.currentAnimal, animal.profileImages[animal.currentImageInd]);
    animal.changeToHappyAnimal();
    expect(animal.currentAnimal,
        animal.profileImagesHappy[animal.currentImageInd]);
    animal.changeToSadAnimal(true);
    expect(
        animal.currentAnimal, animal.profileImagesSad[animal.currentImageInd]);
    animal.changeToSadAnimal(false);
    expect(animal.currentAnimal, animal.profileImages[animal.currentImageInd]);
  });

  test("Animal.setController updates _controller ", () {
    final mockController = AnimationController(
      vsync: TestVSync(),
      duration: Duration(seconds: 1),
    );

    bool listenerCalled = false;
    animal.addListener(() {
      listenerCalled = true;
    });

    animal.setController(mockController);

    expect(animal.controller, mockController);
    expect(listenerCalled, true); // Ensure notifyListeners() was called
  });

//incrementProfileImageIndex()

  test("Animal.incrementProfileImageIndex correctly increments profile index",
      () async {
    await firestore.collection('users').doc(mockUser.uid).set({
      'profileImageIndex': 0,
      'animalMoving': true,
      'Sounds': true,
      'points': 400,
    });

    await animal.fetchAnimalPreferences();

    expect(animal.currentImageInd, 0);

    await animal.incrementProfileImageIndex();

    final doc = await firestore.collection('users').doc(mockUser.uid).get();
    expect(doc.data()?['profileImageIndex'], 1);
    expect(animal.currentImageInd, 1);
  });

//decreaseProfileImageIndex()
  test("Animal.decreaseProfileImageIndex correctly decreases profile index",
      () async {
    await firestore.collection('users').doc(mockUser.uid).set({
      'profileImageIndex': 2,
      'animalMoving': true,
      'Sounds': true,
      'points': 400,
    });

    await animal.fetchAnimalPreferences();
    expect(animal.currentImageInd, 2);
    await animal.decreaseProfileImageIndex();

    final doc = await firestore.collection('users').doc(mockUser.uid).get();
    expect(doc.data()?['profileImageIndex'], 1);
    expect(animal.currentImageInd, 1);
  });

//changeMovement()
  test("Animal.changeMovement  correctly change the animal movement ",
      () async {
    await firestore.collection('users').doc(mockUser.uid).set({
      'animalMoving': true,
    });
    //final s = await doc.get();

    //expect(s.exists, isFalse);
    await animal.changeMovement(false);

    final doc = await firestore.collection('users').doc(mockUser.uid).get();
    expect(doc.data()?['animalMoving'], false);
  });

//fetchAnimalPreferences()
  test("Animal.fetchAnimalPreferences correctly fetch properties", () async {
    await firestore.collection('users').doc(mockUser.uid).set({
      'profileImageIndex': 2,
      'animalMoving': false,
      'Sounds': false,
      'points': 300,
    });

    await animal.fetchAnimalPreferences();
    expect(animal.currentImageInd, 2);
    expect(animal.animalMoving, false);
    expect(animal.soundAnimal, false);
  });

//updateLastUnlockIndx()

  test(
      "Animal.updateLastUnlockIndx returns indx correct when checkProfileAppear is true",
      () {
    when(mockAnimal.checkProfileAppear(300, 2)).thenReturn(true);

    int r = animal.updateLastUnlockIndx(300, 2);
    expect(r, 2);
  });

//changeToSadAnimal() changeToHappyAnimal()
  test("Animal.changeToSadAnimal updates _animalSad correctly", () {
    animal.changeToSadAnimal(true);
    expect(animal.animalSad, true);
    animal.changeToSadAnimal(false);
    expect(animal.animalSad, false);
  });

//changeToHappyAnimal()
  test("Animal.changeToHappyAnimal updates _animalHappy correctly ", () async {
    animal.changeToHappyAnimal();

    expect(animal.animalHappy, true);
  });

//_stopSounds

//changeSound()

//getMood()

  test("Animal.getMood correctly returns the correct mood state", () {
    expect(animal.getMood(), "Normal");
    animal.changeToHappyAnimal();
    expect(animal.getMood(), "Happy");
    animal.changeToSadAnimal(true);
    expect(animal.getMood(), "Sad");
  });
}
