import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerController extends GetxController{

  bool isPlaying = false;
  setIsPlaying(bool value){
    isPlaying = value;
    update();
  }

  final player = AudioPlayer();

  final playlist = ConcatenatingAudioSource(children: []);

  int currentIndex = 0;
  setCurrentIndex(int value){
    currentIndex = value;
    update();
  }

  sourceListGetter({required List<SongModel> list,required int index}) async{
    if(list.isNotEmpty){
      setCurrentIndex(index);
      for(var each in list){
        playlist.add(AudioSource.uri(Uri.file(each.data),
          tag: AudioMetadata(
            album: each.album!,
            title: each.title,
            artist: each.artist ?? '',
            artwork:
            QueryArtworkWidget(
                artworkBorder: BorderRadius.circular(20),
                artworkQuality: FilterQuality.high,
                size: 5000,
                quality: 100,
                format: ArtworkFormat.JPEG,
                id: each.id, type: ArtworkType.AUDIO),
          ),
        ),
        );
        // print('====================================================== $list');
      }
      player.setAudioSource(playlist,initialIndex: index);
      player.play();
      player.currentIndexStream.listen((event) {
        setCurrentIndex(player.currentIndex ?? 0);
      });
    }
  }



  initialPlay({required String path}) async{
    if(isPlaying){
      await player.stop();
    }
    final duration = await player.setAudioSource(AudioSource.file(path));
    setIsPlaying(true);
      await player.play();


    // Isolate isolate = await Isolate.spawn(runIsolate, {'path':path,});
    //
    // // Send a message to the isolate
    // isolate.controlPort.send('Message from main isolate!');
    //
    // // Receive a message from the isolate
    // ReceivePort receivePort = ReceivePort();
    // isolate.addOnExitListener(receivePort.sendPort);
    // listenToMessages(receivePort);
  }

  listenToMessages(ReceivePort receivePort){
    receivePort.listen((dynamic message) {
      switch(message['type']){
        case 'isPlaying':
          if(message['value'] == true){
            setIsPlaying(true);
          }
          else{
            setIsPlaying(false);
          }
      }
    });
  }

  void runIsolate(dynamic message) async{
    print('play songId: $message');

    // Send a message to the main isolate
    SendPort? sendPort = IsolateNameServer.lookupPortByName('main');
    // sendPort!.send('Message from isolate!');
    final player = AudioPlayer();
    final duration = await player.setAudioSource(AudioSource.file(message['path'] ?? ''));
    try{
      await player.play();
      sendPort!.send({'type': 'isPlaying', 'value': true});
    }
    catch(e){
      sendPort!.send({'type': 'isPlaying', 'value': false});
    }
    // Receive a message from the main isolate
    ReceivePort receivePort = ReceivePort();
    sendPort!.send(receivePort.sendPort);
    receivePort.listen((dynamic message) {
      print('Received message in isolate: $message');
    });
  }
}

class AudioMetadata {
  final String album;
  final String title;
  final String artist;
  final QueryArtworkWidget artwork;

  AudioMetadata({
    required this.album,
    required this.title,
    required this.artist,
    required this.artwork,
  });
}