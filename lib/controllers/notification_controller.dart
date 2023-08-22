import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:music_player/controllers/player_controller.dart';

class NotificationController {

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
      print('action: $receivedAction');
      final playerController = Get.put(PlayerController());
      if(receivedAction.buttonKeyPressed == "next"){
        playerController.player.seekToNext();
      }else if(receivedAction.buttonKeyPressed == "previous"){
        playerController.player.seekToPrevious();
      }
      else if(receivedAction.buttonKeyPressed == "play"){
        if(playerController.player.playing){
          playerController.player.pause();
        }
        else{
          playerController.player.play();
        }
      }
    }
}