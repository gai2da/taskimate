import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserEntity {
  final String id;
  final String email;

  int points;
  int profileImageIndex;

  UserEntity({
    required this.id,
    required this.email,
    this.points = 0,
    this.profileImageIndex = 0,
  });

  //fetch user from firebase
  factory UserEntity.fromfireStoreFormate(
      String id, Map<String, dynamic> data) {
    return UserEntity(
      id: id,
      email: data['email'] ?? '',
      points: data['points'] ?? 0,
      profileImageIndex: data['profileImageIndex'] ?? 0,
    );
  }

  //store using in firebase
  Map<String, dynamic> tofireStoreFormate() {
    return {
      'email': email,
      'points': points,
      'profileImageIndex': profileImageIndex,
    };
  }

  static Future<UserEntity?> fetchUser(String id) async {
    final instanceUser =
        await FirebaseFirestore.instance.collection('users').doc(id).get();

    if (instanceUser.exists) {
      return UserEntity.fromfireStoreFormate(
          instanceUser.id, instanceUser.data()!);
    }
    return null;
  }

  static Future<void> addUser(String id, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(id).set({
      'email': email,
      'points': 0,
      'profileImageIndex': 0,
      // Theme Settings
      'colorMood': 0,
      'fontSize': 29,
      'animalMoving': true,
      'soundAnimal': true,
      'readSentence': true,
      // Task Preferences
      'sleepTimeStart': DateTime(2024, 1, 1, 22, 0),
      'sleepTimeEnd': DateTime(2024, 1, 2, 7, 0),
      'productiveStartTime': DateTime(2024, 1, 1, 10, 0),
      'productiveEndTime': DateTime(2024, 1, 1, 16, 0),
      'focusDuration': 30,
      'breakDuration': 10,
    });
  }

  static Future<int> getProfileIndex() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("debuging ");
      throw Exception("No user signed in");
    }
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data()?['profileImageIndex'] as int? ?? 0;
  }
}
