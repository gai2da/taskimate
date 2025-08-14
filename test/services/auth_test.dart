import 'package:final_year_project/services/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../firebase_mock.dart';
import 'auth_test.mocks.dart';

@GenerateMocks([
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  FirebaseAuth,
  User,
  UserCredential
], customMocks: [
  MockSpec<User>(as: #MockFirebaseUser),
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late Auth auth;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();

    auth = Auth(
      authInst: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  test("auth.user should return a user", () async {
    final mockUser = MockFirebaseUser();
    when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));

    expectLater(auth.user, emitsInOrder([mockUser]));
  });

  test("auth.register returns FirebaseAuthException error ", () async {
    when(mockAuth.createUserWithEmailAndPassword(
      email: "test@example.com",
      password: "password123",
    )).thenThrow(FirebaseAuthException(
      code: "email-already-in-use",
      message: "The email address is already in use by another account.",
    ));

    final result = await auth.register("test@example.com", "password123");
    expect(result, "The email address is already in use by another account.");
  });
  test("auth.signIn when successful login", () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: "test@example.com",
      password: "password123",
    )).thenAnswer((_) async => MockUserCredential());

    final login = await auth.signIn("test@example.com", "password123");
    expect(login, 'signIn successful');
  });

  test("auth.signIn when not successful login", () async {
    when(mockAuth.signInWithEmailAndPassword(
      email: "test@example.com",
      password: "password123",
    )).thenThrow(FirebaseAuthException(
      code: "wrong-password",
      message: "wrong password",
    ));

    final login = await auth.signIn("test@example.com", "password123");
    expect(login, contains("wrong password"));
  });

  test("auth.signInWithGoogle should return null when successful", () async {
    final mockGoogleSignInAccount = MockGoogleSignInAccount();
    final mockGoogleAuth = MockGoogleSignInAuthentication();

    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleAuth);
    when(mockAuth.signInWithCredential(any))
        .thenAnswer((_) async => MockUserCredential());

    expect(await auth.signInWithGoogle(), isNull);
  });

  test("auth.signInWithGoogle should return null on successful signin",
      () async {
    final mockGoogleSignInAccount = MockGoogleSignInAccount();
    final mockGoogleAuth = MockGoogleSignInAuthentication();

    when(mockGoogleSignIn.signIn())
        .thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication)
        .thenAnswer((_) async => mockGoogleAuth);

    final mockOAuthCredential = GoogleAuthProvider.credential(
      accessToken: "access-mock",
      idToken: "idtoken-mock",
    );
    when(mockAuth.signInWithCredential(mockOAuthCredential))
        .thenAnswer((_) async => MockUserCredential());

    expect(await auth.signInWithGoogle(), isNull);
  });

  test("auth.signOut return successful signOut", () async {
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());
    when(mockAuth.signOut()).thenAnswer((_) async => Future.value());

    final r = await auth.signOut();
    expect(r, 'SignOut successful');
  });

  test("auth.signOut return FirebaseAuthException", () async {
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());
    when(mockAuth.signOut()).thenThrow(FirebaseAuthException(
        code: "sign-out-failed", message: "FirebaseAuthException"));

    expect(await auth.signOut(), contains('FirebaseAuthException'));
  });

  test("auth.signOut return error", () async {
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());
    when(mockAuth.signOut()).thenThrow(Exception("auth.signOut return error"));

    expect(await auth.signOut(), contains('error'));
  });
}
