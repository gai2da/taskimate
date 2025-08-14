import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/widgets.dart';

@GenerateMocks([
  BuildContext,
  User,
  Firebase,
  FirebaseApp,
  FirebaseAuth,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  UserCredential,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  QuerySnapshot
])
void main() {}
