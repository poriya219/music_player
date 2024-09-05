import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/controllers/app_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_slider/controller.dart';

import '../pages/home_screen/controller/home_controller.dart';

class PlayerController extends GetxController{

  @override
  void onInit() {
    songListeningStream();
    super.onInit();
  }

  songListeningStream(){
    player.currentIndexStream.listen((event) async{
      if(event != null){
        Timer(const Duration(seconds: 1), () {
          StreamSubscription? pStream;
          pStream = player.positionStream.listen((pEvent) async{
            int duration = pEvent.inSeconds;
            if(duration == 7){
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
              prefs.setString('playCount', jsonEncode(map));
              if(pStream != null){
                pStream.cancel();
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
    Directory tempDir =  await getApplicationDocumentsDirectory();
    String tempPath = tempDir.path;
    if(list.isNotEmpty){
      resetPlayList();
      setCurrentIndex(index);
      for(var each in list){
        var filePath = '$tempPath/file_${each.id}.png';
        playlist.add(AudioSource.uri(Uri.file(each.data),
          tag: MediaItem(
            id: each.id.toString(),
            title: each.title,
            album: each.album,
            artist: each.artist,
            artUri: File(filePath).uri,
          ),
        ),
        );
      }
      player.setAudioSource(playlist,initialIndex: index);
      player.play().then((value) {
        final appController = Get.find<AppController>();

        appController.seekSliderController(1);
      });

      StreamSubscription? stream1;
      StreamSubscription? stream2;
      StreamSubscription? stream3;
      if(stream1 != null){
        await stream1.cancel();
      }
      stream1 = player.currentIndexStream.listen((event) async{
        setCurrentIndex(player.currentIndex ?? 0);
        // String title = player.sequence![player.currentIndex ?? 0].tag.title;
        // String artist = player.sequence![player.currentIndex ?? 0].tag.artist;
        if(stream2 != null){
          await stream2!.cancel();
        }
        stream2 = player.playingStream.listen((plEvent) async{
          if(stream3 != null){
            await stream3!.cancel();
          }
          stream3 = player.durationStream.listen((dEvent) async{
          });
        });
      });
    }
  }

  initialPlay({required String path}) async{
    if(isPlaying){
      await player.stop();
    }
    await player.setAudioSource(AudioSource.file(path));
    setIsPlaying(true);
      await player.play();
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

  final SliderController sliderController = SliderController();

  bool isSeeking = false;
  setIsSeeking(bool value){
    isSeeking = value;
    update();
  }

  seekSliderController(int index){
    isSeeking = true;
    sliderController.moveTo!.call(index);
    update();
    Timer(const Duration(milliseconds: 300), () {
      setIsSeeking(false);
    });
  }
}