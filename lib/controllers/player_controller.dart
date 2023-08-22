import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/constans.dart';
import 'package:music_player/controllers/app_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

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
      player.currentIndexStream.listen((event) async{
        setCurrentIndex(player.currentIndex ?? 0);
        String title = player.sequence![player.currentIndex ?? 0].tag.title;
        String artist = player.sequence![player.currentIndex ?? 0].tag.artist;
        QueryArtworkWidget artwork = player.sequence![player.currentIndex ?? 0].tag.artwork;
        final appController = Get.find<AppController>();
        print('before listdata:');
        Uint8List? listData = await appController.getSongImage(artwork.id);
        print('listdata: $listData');
        final Directory tempDir = await getTemporaryDirectory();
        File file = await File('${tempDir.path}/${artwork.id}.png').create();
        if(listData != null){
          await file.writeAsBytes(listData);
        }
        else{
          print('null listdata:');
          final ByteData bytes = await rootBundle.load('assets/images/gd.png');
          final Uint8List listBytes = bytes.buffer.asUint8List();
          await file.writeAsBytes(listBytes);
        }
        createNotification(title: title, body: artist,path: file.path);
      });
    }
  }

  createNotification({required String title, required String body,required String path}){
    print('path: $path');
    // AwesomeNotifications().cancel(10);
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'play_channel',
            title: title,
            body: body,
            actionType: ActionType.KeepOnTop,
          // largeIcon: ,
          summary: isPlaying ? 'Now playing' : '',
            bigPicture: 'file://$path',
            largeIcon: 'file://$path',
          color: Colors.purple.shade700,
          category: NotificationCategory.Transport,
          notificationLayout: NotificationLayout.MediaPlayer,
          progress: 50,
          locked: true,
          showWhen: false,
          autoDismissible: false,
        ),
        actionButtons: [
          NotificationActionButton(
            key: "previous",
            label: "Previous",
            icon: 'resource://drawable/previous',
            color: Colors.white
          ),
          NotificationActionButton(
            key: "play",
            label: "Play",
            icon: 'resource://drawable/play',
            color: Colors.white
          ),
          NotificationActionButton(
            key: "next",
            label: "Next",
            icon: 'resource://drawable/next',
            color: Colors.white
          )
        ]
    // );
    );
  }

  getLyrics(){}

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