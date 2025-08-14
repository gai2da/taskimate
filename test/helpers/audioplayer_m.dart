import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupMockAudioPlayers() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioplayersPlatformInterface.instance = FakeAudioplayersPlatform();
  final audioCache = AudioCache();
  audioCache.prefix = '';
}

class FakeAudioplayersPlatform extends AudioplayersPlatformInterface {
  @override
  Future<void> play(String playerId, String sourceUrl, {bool? isLocal}) async {
    return;
  }

  @override
  Future<void> stop(String playerId) async {
    return;
  }

  @override
  Future<void> create(String playerId) async {
    // TODO: implement create
    return;
  }

  @override
  Future<void> dispose(String playerId) async {
    // TODO: implement dispose
    return;
  }

  @override
  Future<void> emitError(String playerId, String code, String message) async {
    // TODO: implement emitError
    return;
  }

  @override
  Future<void> emitLog(String playerId, String message) async {
    // TODO: implement emitLog
    return;
  }

  @override
  Future<int?> getCurrentPosition(String playerId) async {
    // TODO: implement getCurrentPosition
    return 0;
  }

  @override
  Future<int?> getDuration(String playerId) async {
    // TODO: implement getDuration
    return 3000;
  }

  @override
  Stream<AudioEvent> getEventStream(String playerId) {
    // TODO: implement getEventStream
    return const Stream.empty();
  }

  @override
  Future<void> pause(String playerId) async {
    // TODO: implement pause
    return;
  }

  @override
  Future<void> release(String playerId) async {
    // TODO: implement release
    return;
  }

  @override
  Future<void> resume(String playerId) async {
    // TODO: implement resume
    return;
  }

  @override
  Future<void> seek(String playerId, Duration position) async {
    // TODO: implement seek
    return;
  }

  @override
  Future<void> setAudioContext(
      String playerId, AudioContext audioContext) async {
    // TODO: implement setAudioContext
    return;
  }

  @override
  Future<void> setBalance(String playerId, double balance) async {
    // TODO: implement setBalance
    return;
  }

  @override
  Future<void> setPlaybackRate(String playerId, double playbackRate) async {
    // TODO: implement setPlaybackRate
    return;
  }

  @override
  Future<void> setPlayerMode(String playerId, PlayerMode playerMode) async {
    // TODO: implement setPlayerMode
    return;
  }

  @override
  Future<void> setReleaseMode(String playerId, ReleaseMode releaseMode) async {
    // TODO: implement setReleaseMode
    return;
  }

  @override
  Future<void> setSourceBytes(String playerId, Uint8List bytes,
      {String? mimeType}) async {
    // TODO: implement setSourceBytes
    return;
  }

  @override
  Future<void> setSourceUrl(String playerId, String url,
      {bool? isLocal, String? mimeType}) async {
    // TODO: implement setSourceUrl
    return;
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {
    return;
  }
}
