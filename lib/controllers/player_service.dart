import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  PlayerService() {
    _player.currentIndexStream.listen((index) {
      final queueList = queue.value;
      if (index != null && index < queueList.length) {
        mediaItem.add(queueList[index]);
      }
    });
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    queue.add(newQueue);
    final sources =
        newQueue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList();
    await _playlist.clear();
    _playlist.addAll(sources);
    await _player.setAudioSource(_playlist);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _playlist.length) {
      await _player.seek(Duration.zero, index: index);
    }
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
}
