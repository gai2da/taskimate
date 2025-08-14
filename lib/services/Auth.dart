import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/UserEntity.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth authInst;
  final GoogleSignIn googleSignIn;

  Auth({
    required this.authInst,
    required this.googleSignIn,
  });
  Stream<User?> get user => authInst.authStateChanges();
  Future<String?> register(String email, String password) async {
    try {
      final UserCredential userCredential =
          await authInst.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await UserEntity.addUser(firebaseUser.uid, email.trim());
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
          'email': email.trim(),
          'points': 0,
          'animalMoving': true,
          'soundAnimal': true,
          'readSentence': true,
          'theme': 0,
          'fontSize': 26.0,
          'notificationsEnabled': true,
          'sleepingStartTime': Timestamp.fromDate(DateTime(2024, 1, 1, 22, 0)),
          'sleepingEndTime': Timestamp.fromDate(DateTime(2024, 1, 2, 6, 0)),
          'productiveStartTime': Timestamp.fromDate(DateTime(2024, 1, 1, 9, 0)),
          'productiveEndTime': Timestamp.fromDate(DateTime(2024, 1, 1, 17, 0)),
          'focusDuration': 25,
          'breakDuration': 5,
        });
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.message;
    }
  }

  //sign in
  Future<String?> signIn(String email, String password) async {
    try {
      await authInst.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      print('signIn successful');
      return 'signIn successful';
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.message;
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? user = await googleSignIn.signIn();
      if (user == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await user.authentication;
      final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await authInst.signInWithCredential(oAuthCredential);
      return null;
    } catch (e) {
      print("$e");
      return null;
    }
  }

// Sign Out
  Future<String?> signOut() async {
    try {
      await googleSignIn.signOut();
      await authInst.signOut();
      return "SignOut successful";
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.message;
    } catch (e) {
      print("$e");
      return "$e error";
    }
  }
}
