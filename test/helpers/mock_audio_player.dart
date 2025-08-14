import 'package:audioplayers/audioplayers.dart';
import 'package:mockito/mockito.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {
  @override
  Future<void> play(
    Source source, {
    double? volume,
    Duration? position,
    double? balance,
    AudioContext? ctx,
    PlayerMode? mode,
  }) async {
    return;
  }

  @override
  Future<void> stop() async {
    return;
  }

  @override
  Future<void> pause() async {
    return;
  }

  @override
  Future<void> resume() async {
    return;
  }

  @override
  Future<void> dispose() async {
    return;
  }

  @override
  Future<void> setSource(Source source) async {
    return;
  }
}
