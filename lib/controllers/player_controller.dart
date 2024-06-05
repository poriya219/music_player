import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/controllers/app_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/home_screen/controller/home_controller.dart';

class PlayerController extends GetxController{

  @override
  void onClose() {
    AwesomeNotifications().cancel(10);
    super.onClose();
  }

  @override
  void onInit() {
    songListeningStream();
    super.onInit();
  }

  songListeningStream(){
    player.currentIndexStream.listen((event) async{
      if(event != null){
        int lastEvent = event;
        Timer(const Duration(seconds: 1), () {
          StreamSubscription? pStream;
          pStream = player.positionStream.listen((pEvent) async{
            int duration = pEvent.inSeconds;
            if(duration == 7){
              print('add to the list');
              List<IndexedAudioSource> list = player.sequence ?? <IndexedAudioSource>[];
              String songTitle = list[event].tag.title;
              int? id;
              final homeController = Get.find<HomeController>();
              for(var each in homeController.songs){
                if(each.title == songTitle){
                  id = each.id;
                  break;
                }
              }
              final prefs = await SharedPreferences.getInstance();
              String playCountsString = prefs.getString('playCount') ?? jsonEncode({});
              Map map = jsonDecode(playCountsString);
              map.putIfAbsent(id.toString(), () => 0);
              int count = map[id.toString()] ?? 0;
              map[id.toString()] = count + 1;
              print('map: $map');
              prefs.setString('playCount', jsonEncode(map));
              if(pStream != null){
                pStream.cancel();
                print('Stream cancelled');
              }
            }
          });
        });
      }
    });
  }

  bool isPlaying = false;
  setIsPlaying(bool value){
    isPlaying = value;
    update();
  }

  final player = AudioPlayer();

  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children: [],useLazyPreparation: true);
  resetPlayList(){
    playlist = ConcatenatingAudioSource(children: []);
    update();
  }

  int currentIndex = 0;
  setCurrentIndex(int value){
    currentIndex = value;
    update();
  }

  sourceListGetter({required List<SongModel> list,required int index}) async{
    if(list.isNotEmpty){
      resetPlayList();
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
      StreamSubscription? stream1;
      StreamSubscription? stream2;
      StreamSubscription? stream3;
      StreamSubscription? stream4;
      if(stream1 != null){
        await stream1.cancel();
      }
      stream1 = player.currentIndexStream.listen((event) async{
        setCurrentIndex(player.currentIndex ?? 0);
        String title = player.sequence![player.currentIndex ?? 0].tag.title;
        String artist = player.sequence![player.currentIndex ?? 0].tag.artist;
        QueryArtworkWidget artwork = player.sequence![player.currentIndex ?? 0].tag.artwork;
        final appController = Get.find<AppController>();
        Uint8List? listData = await appController.getSongImage(artwork.id);
        final Directory tempDir = await getTemporaryDirectory();
        File file = await File('${tempDir.path}/${artwork.id}.png').create();
        if(listData != null){
          await file.writeAsBytes(listData);
        }
        else{
          final ByteData bytes = await rootBundle.load('assets/images/gd.png');
          final Uint8List listBytes = bytes.buffer.asUint8List();
          await file.writeAsBytes(listBytes);
        }
        if(stream2 != null){
          await stream2!.cancel();
        }
        stream2 = player.playingStream.listen((plEvent) async{
          print('stream 2');
          bool isPlaying = plEvent;
          if(stream3 != null){
            await stream3!.cancel();
          }
          stream3 = player.durationStream.listen((dEvent) async{
            print('stream 3');
            Duration duration = dEvent ?? const Duration(seconds: 1);
            if(stream4 != null){
              await stream4!.cancel();
            }
            int lastProgress = 0;
            stream4 = player.positionStream.listen((poEvent) async{
              print('stream 4');
              Duration position = poEvent;
              print('current progress: ${((position.inSeconds / duration.inSeconds) * 100).toInt()}');
              int progress = ((position.inSeconds / duration.inSeconds) * 100).toInt();
              if(progress > lastProgress || lastProgress == 0){
                lastProgress = progress;
                createNotification(title: title, body: artist,path: file.path,isPlaying: isPlaying,progress: progress);
              }
            });
          });
        });
      });
    }
  }

  createNotification({required String title, required String body,required String path,required bool isPlaying, required int progress}){
    print('path: $path');
    // AwesomeNotifications().cancel(10);
    AwesomeNotifications().createNotification(
        content:
        NotificationContent(
            id: 10,
            channelKey: 'play_channel',
            category: NotificationCategory.Transport,
            title: title,
            body: body,
            summary: isPlaying ? 'Now playing' : '',
            notificationLayout: NotificationLayout.MediaPlayer,
            largeIcon: 'file://$path',
            bigPicture: 'file://$path',
            color: Colors.purple.shade700,
            progress: progress,
            autoDismissible: false,
            showWhen: false),
        // NotificationContent(
        //     id: 10,
        //     channelKey: 'play_channel',
        //     title: title,
        //     body: body,
        //     actionType: ActionType.KeepOnTop,
        //   // largeIcon: ,
        //   summary: isPlaying ? 'Now playing' : '',
        //     bigPicture: 'file://$path',
        //     largeIcon: 'file://$path',
        //   color: Colors.purple.shade700,
        //   category: NotificationCategory.Transport,
        //   notificationLayout: NotificationLayout.MediaPlayer,
        //   progress: progress,
        //   locked: true,
        //   showWhen: false,
        //   autoDismissible: false
        // ),
        actionButtons: [
          NotificationActionButton(
            key: "previous",
            label: "Previous",
            icon: 'resource://drawable/pre',
            autoDismissible: false,
          ),
          NotificationActionButton(
            key: "play",
            label: "Play",
            icon: isPlaying ? 'resource://drawable/pa' : 'resource://drawable/p',
            color: Colors.white,
            autoDismissible: false,
          ),
          NotificationActionButton(
            key: "next",
            label: "Next",
            icon: 'resource://drawable/n',
            color: Colors.white,
            autoDismissible: false,
          ),
        ],
    // );
    );
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