import 'dart:isolate';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class PlayerController extends GetxController{

  bool isPlaying = false;
  setIsPlaying(bool value){
    isPlaying = value;
    update();
  }

  initialPlay({required String path}) async{
    final player = AudioPlayer();
    Isolate isolate = await Isolate.spawn(runIsolate, {'path':path,'player': player});

    // Send a message to the isolate
    isolate.controlPort.send('Message from main isolate!');

    // Receive a message from the isolate
    ReceivePort receivePort = ReceivePort();
    isolate.addOnExitListener(receivePort.sendPort);
    listenToMessages(receivePort);
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
    final player = message['player'];
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