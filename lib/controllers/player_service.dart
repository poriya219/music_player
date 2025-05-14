import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayerService extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  PlayerService() {
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      final processingState = {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!;

      playbackState.add(
        PlaybackState(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: processingState,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _player.currentIndex,
        ),
      );
    });

    _player.currentIndexStream.listen((index) {
      final q = queue.value;
      if (index != null && index < q.length) {
        if (mediaItem.value?.id != q[index].id) {
          mediaItem.add(q[index]);
        }
      }
    });

    _player.positionStream.listen((position) {
      customState.add({
        'position': position.inMilliseconds,
      });
    });
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue,
      {int startIndex = 0}) async {
    queue.add(newQueue);

    final sources =
        newQueue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList();

    _playlist.clear();
    _playlist.addAll(sources);

    await _player.setAudioSource(_playlist, initialIndex: startIndex);
    mediaItem.add(newQueue[startIndex]); // sync MediaItem
  }

  Future<void> updateQueueWithIndex(
      List<MediaItem> newQueue, int startIndex) async {
    queue.add(newQueue);

    final sources =
        newQueue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList();

    _playlist.clear();
    _playlist.addAll(sources);

    await _player.setAudioSource(_playlist, initialIndex: startIndex);

    mediaItem.add(newQueue[startIndex]); // sync MediaItem
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
