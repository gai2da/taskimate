import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'animal.dart';

class Point {
  //final String userId = FirebaseAuth.instance.currentUser!.uid;
  //String? userId;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Point({required this.auth, required this.firestore});
  String? get userId => auth.currentUser?.uid;

  //read point

  Stream<int> getPoints() {
    //final user = FirebaseAuth.instance.currentUser;

    if (userId == null) {
      return Stream.value(0);
    }

    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      return data?['points'] ?? 0;
    });
  }

  //add point
  Future<void> addPoints(int num) async {
    if (userId == null) throw Exception("null user");
    final doc = firestore.collection('users').doc(userId);
    final s = await doc.get();
    if (!s.exists) {
      await doc.set({'points': 0});
    }

    // final currentPoints = s.data()?['points'] ?? 0;
    await doc.update({'points': FieldValue.increment(num)});

    print("done adding point");
  }

  //delete points ?
  Future<void> deletePoints(int quantity) async {
    if (userId == null) throw Exception("null user");
    final doc = firestore.collection('users').doc(userId);
    final s = await doc.get();
    if (!s.exists) {
      await doc.set({'points': 0});
    }

    await doc.update({'points': FieldValue.increment(-quantity)});

    print('point deleted successfully  ');
  }
}
