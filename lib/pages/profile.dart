import 'package:final_year_project/entity/point.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../managers/theme_Manager.dart';
import '../services/Auth.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../entity/UserEntity.dart';
import '../services/appearance.dart';
import '../services/TasksSettings.dart';
import 'package:provider/provider.dart';
import '../entity/animal.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _FirebaseFirestore = FirebaseFirestore.instance;
  final Auth auth = Auth(
    authInst: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
  );

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool authbool = false;

  String? errorText;
  bool signed = false;

  //the animals list

  @override
  Widget build(BuildContext context) {
    return authbool ? profileBuild(context) : LoginBuild(context);
  }

  @override
  void initState() {
    super.initState();

    final user = _auth.currentUser;
    if (user != null) {
      authbool = true;
    }
  }

  @override
  Widget LoginBuild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task Manager")),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: "Enter your email",
            textField: true,
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
              ),
              autocorrect: false,
              //enableSuggestions: false,
            ),
          ),
          Semantics(
              label: "Enter your password",
              textField: true,
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                ),
                obscureText: true,
                autocorrect: false,
                //enableSuggestions: false,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                button: true,
                label: "Log in to your account",
                child: ElevatedButton(
                  onPressed: () async {
                    String? signing = await auth.signIn(
                        _emailController.text.trim(),
                        _passwordController.text.trim());

                    setState(() {
                      if (signing != null) {
                        errorText = signing;
                        SemanticsService.announce(
                            errorText!, TextDirection.ltr);
                      } else {
                        errorText = null;
                        authbool = true;
                      }
                    });
                  },
                  child: Text("Log In"),
                ),
              ),
              Semantics(
                button: true,
                label: "register a new account",
                child: ElevatedButton(
                  onPressed: () async {
                    String? registering = await auth.register(
                        _emailController.text.trim(),
                        _passwordController.text.trim());

                    setState(() {
                      if (registering != null) {
                        errorText = registering;
                        SemanticsService.announce(
                            errorText!, TextDirection.ltr);
                      } else {
                        errorText = null;
                        authbool = true;
                      }
                    });
                  },
                  child: Text("register"),
                ),
              ),
            ],
          ),
          Semantics(
            button: true,
            label: "Sign in with Google",
            child: ElevatedButton(
              child: Text("Sign in with Google"),
              onPressed: () async {
                String? result = await auth.signInWithGoogle();

                setState(() {
                  if (result == null) {
                    authbool = true;
                  } else {
                    errorText = result;
                    SemanticsService.announce(errorText!, TextDirection.ltr);
                  }
                });
              },
            ),
          ),
          if (errorText != null)
            Text(
              errorText!,
              style: TextStyle(color: Colors.red),
            ),
        ],
      )),
    );
  }

  Widget profileBuild(BuildContext context) {
    var themeManager = Provider.of<ThemeManager>(context);
    final animalEntity = Provider.of<Animal>(context, listen: true);
    final pointEntity = Point(auth: _auth, firestore: _FirebaseFirestore);
    int profileIndex = animalEntity.currentImageInd;
    return StreamBuilder<int>(
        stream: pointEntity.getPoints(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          int point = snapshot.data ?? 0;
          bool appearbool =
              animalEntity.checkProfileAppear(point, profileIndex);
          print(appearbool);
          return Scaffold(
            appBar: AppBar(
                title: Semantics(
              header: true,
              child: Text(
                "Welcome",
                style: TextStyle(
                  fontSize: themeManager.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            body: Consumer<Animal>(
              builder: (context, animalEntity, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Semantics(
                      label: "Change profile picture",
                      button: true,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Semantics(
                              button: true,
                              label: "Previous profile picture",
                              child: ElevatedButton(
                                onPressed: () {
                                  //  if (appearbool) {
                                  animalEntity.decreaseProfileImageIndex();
                                  //  }
                                },
                                child: Text(
                                  '<',
                                  style: TextStyle(
                                    fontSize: themeManager.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 100.0,
                                  child: Semantics(
                                    label: "Profile picture",
                                    child: Lottie.asset(
                                      animalEntity.profileImages[
                                          animalEntity.currentImageInd],
                                      animate: animalEntity.animalMoving,
                                    ),
                                  ),
                                ),
                                if (!appearbool)
                                  Semantics(
                                    label:
                                        "Profile locked. Earn more points to unlock.",
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Semantics(
                              button: true,
                              label: "Next profile picture",
                              child: ElevatedButton(
                                onPressed: () {
                                  //   if (appearbool) {
                                  animalEntity.incrementProfileImageIndex();
                                  //   }
                                },
                                child: Text(
                                  '>',
                                  style: TextStyle(
                                    fontSize: themeManager.fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(
                        width: 350,
                        height: 70,
                        child: Semantics(
                          button: true,
                          label: "Change appearance settings",
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Appearance();
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Text(
                              "Appearance settings",
                              style: TextStyle(
                                fontSize: themeManager.fontSize * 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                    SizedBox(
                      width: 350,
                      height: 70,
                      child: Semantics(
                        button: true,
                        label: "Change task settings",
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return TasksSettings();
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(
                            "Task settings",
                            style: TextStyle(
                              fontSize: themeManager.fontSize * 0.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      height: 70,
                      child: Semantics(
                        button: true,
                        label: "Sign out of your account",
                        child: ElevatedButton(
                          onPressed: () async {
                            await auth.signOut();
                            clearEmailAndPassController();
                            SemanticsService.announce(
                              "Signed out successfully",
                              TextDirection.ltr,
                            );
                            setState(() {
                              authbool = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(
                            "sign out",
                            style: TextStyle(
                              fontSize: themeManager.fontSize * 0.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }

  void clearEmailAndPassController() {
    _emailController.clear();
    _passwordController.clear();
  }
}
