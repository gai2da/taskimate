import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

import 'package:home_widget/home_widget.dart';

class Animal extends ChangeNotifier {
  //the animals list
  final List<String> profileImages = [
    'assets/animated/normalEarth.json',
    'assets/animated/normalMars.json',
    'assets/animated/normal_dog.json',
    'assets/animated/doganimated.json',
  ];
  final List<String> profileImagesHappy = [
    'assets/animated/happyEarth.json',
    'assets/animated/happyMars.json',
    'assets/animated/happy_dog.json',
    'assets/animated/doganimated.json',
  ];
  final List<String> profileImagesSad = [
    'assets/animated/cryingEarth.json',
    'assets/animated/cryingMars.json',
    'assets/animated/crying_dog.json',
    'assets/animated/doganimated.json',
  ];

  final List<String> animalSoundsNormal = [
    'audio/space-rumble-29970.mp3',
    'audio/space-rumble-29970.mp3',
    'audio/dogNormal.mp3',
    'audio/dogNormal.mp3',
  ];
  final List<String> animalSoundsHappy = [
    'audio/happyDog.mp3',
    'audio/happyDog.mp3',
    'audio/happyDog.mp3',
    'audio/happyDog.mp3',
  ];
  int _currentImageInd = 0;
  bool _animalMoving = true;
  //bool for if task have been done then animal is happy
  bool _animalHappy = false;
  bool _animalSad = false;
  //timer
  Timer? _AnimalTimer;

  //animal sound
  bool soundAnimal = true;
  final _audio = AudioPlayer();

  late AnimationController? _controller;
  late final FirebaseFirestore firestore;
  final bool testingBool;
  late final FirebaseAuth auth;
  Animal({
    required this.firestore,
    required this.auth,
    bool? testingBool,
  }) : testingBool = testingBool ?? false;
  String? get userId => auth.currentUser?.uid;
  bool get animalMoving => _animalMoving;
  bool get animalSad => _animalSad;
  bool get animalHappy => _animalHappy;
  int get currentImageInd => _currentImageInd;

  String get currentAnimal {
    if (_animalHappy) {
      return profileImagesHappy[_currentImageInd];
    } else if (_animalSad) {
      return profileImagesSad[_currentImageInd];
    } else {
      return profileImages[_currentImageInd];
    }
  }

  AnimationController? get controller => _controller;

  void setController(AnimationController controller) {
    _controller = controller;
    notifyListeners();
  }

  Future<void> incrementProfileImageIndex() async {
    int size = profileImages.length;
    if (_currentImageInd < size && _currentImageInd != size - 1) {
      _currentImageInd += 1;
      print(" _currentImageInd = $_currentImageInd");
      await updateProfileImageIndex(_currentImageInd);
      notifyListeners();
    } else {
      print("cant increment more");
    }

    notifyListeners();
  }

  Future<void> decreaseProfileImageIndex() async {
    if (_currentImageInd > 0) {
      _currentImageInd -= 1;
    } else {
      print("already zero");
    }
    print("before $_currentImageInd");
    await updateProfileImageIndex(_currentImageInd);
    //await Future.delayed(Duration(milliseconds: 500));
    notifyListeners();
    print('dddd $_currentImageInd');
  }

  Future<void> updateProfileImageIndex(int index) async {
    if (userId != null) {
      await firestore
          .collection('users')
          .doc(userId)
          .update({'profileImageIndex': index});
    }
    notifyListeners();
  }

  Future<void> changeMovement(bool mvbool) async {
    if (userId != null) {
      await firestore
          .collection('users')
          .doc(userId)
          .update({'animalMoving': mvbool});
    }
    _animalMoving = mvbool;
    //if (!_animalMoving && _controller != null) {
    //  _controller!.reset();
    //}
    notifyListeners();
  }

  Future<void> fetchAnimalPreferences() async {
    if (userId != null) {
      print("fetching animal preferences for user: ${userId}");
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        print("Firestore document exists for user");
        print("Firestore data: ${doc.data()}");

        int firebaseindx = doc['profileImageIndex'] ?? 0;
        _animalMoving = doc['animalMoving'] ?? true;
        soundAnimal = doc['Sounds'] ?? true;
        int points = (doc.data()?['points'] ?? 0) as int;

        /// _currentImageInd
        if (points < 0) {
          points = 0;
        }
        ;
        int lastUnlockedIndex = updateLastUnlockIndx(points, firebaseindx);
        bool b = checkProfileAppear(points, firebaseindx);
        if (checkProfileAppear(points, firebaseindx)) {
          _currentImageInd = firebaseindx;
        } else {
          print("animal is locked ");
          _currentImageInd = lastUnlockedIndex;
        }

        _playAnimalSoundNormal();
        notifyListeners();
      } else {
        print("user doesnt exesit  index from firestore");
      }
    } else {
      print("No log in user found");
    }
  }

  int updateLastUnlockIndx(int points, int indxFirestore) {
    int lastUnlockIndex = (points / 100).floor();

    if (checkProfileAppear(points, indxFirestore)) {
      return indxFirestore;
    } else {
      return lastUnlockIndex;
    }
  }

  //appear the profile based on the points
  bool checkProfileAppear(int points, int profileIndx) {
    int pointsReq = 100 * profileIndx;
    return points >= pointsReq;
  }

  void changeToHappyAnimal() {
    _animalHappy = true;
    if (testingBool) {
      return;
    }
    _playAnimalSoundHappy();
    notifyListeners();

    _AnimalTimer?.cancel();

    _AnimalTimer = Timer(Duration(seconds: 5), () {
      _animalHappy = false;
      if (_animalSad) {
        changeToSadAnimal(false);
      }
      if (_animalMoving) {
        _playAnimalSoundNormal();
      } else {
        _stopSounds();
      }
      //---
      // HomeWidget.saveWidgetData('key_flutter', "happy ");
      // HomeWidget.updateWidget();
      notifyListeners();
    });
  }

  void changeToSadAnimal(bool sadBool) {
    _animalSad = sadBool;
    _animalHappy = false;
    print("animal is ------- : $sadBool");
    //---
    //HomeWidget.saveWidgetData('key_flutter', "you've got this");
    //HomeWidget.updateWidget();
    notifyListeners();
  }

  Future<void> _playAnimalSoundNormal() async {
    print("normal sound ");
    if (!_animalHappy & _animalMoving & soundAnimal) {
      try {
        _audio.play(AssetSource(animalSoundsNormal[_currentImageInd]));
        await _audio.setReleaseMode(ReleaseMode.loop);
        await _audio.setVolume(0.3);
        await _audio.resume();
        notifyListeners();
      } catch (e) {
        print("Error : $e");
      }
    }
  }

  void _stopSounds() async {
    await _audio.stop();
  }

  Future<void> _playAnimalSoundHappy() async {
    print("happy sound");
    if (_animalHappy & soundAnimal) {
      try {
        _stopSounds();
        _audio.play(AssetSource(animalSoundsHappy[_currentImageInd]));

        notifyListeners();
      } catch (e) {
        print("Error : $e");
      }
    }
  }

  void changeSound(bool mvbool) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .update({'Sounds': mvbool});
    }
    soundAnimal = mvbool;
    if (soundAnimal) {
      _playAnimalSoundNormal();
    } else {
      _stopSounds();
    }
    notifyListeners();
  }

  String getMood() {
    if (_animalHappy) {
      return "Happy";
    } else if (_animalSad) {
      return "Sad";
    } else {
      return "Normal";
    }
  }
}
