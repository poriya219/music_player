import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/constans.dart';
import 'package:music_player/controllers/player_controller.dart';
import 'package:music_player/pages/home_screen/home_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'controllers/notification_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    //   'resource://drawable/res_app_icon',
    null,
      [
        NotificationChannel(
            channelGroupKey: 'play_channel_group',
            channelKey: 'play_channel',
            channelName: 'Play notifications',
            channelDescription: 'Notification channel for Play Music',
            defaultColor: Color(0xFF9D50DD),
            playSound: false,
            enableVibration: false,
            enableLights: false,
            importance: NotificationImportance.High,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'play_channel_group',
            channelGroupName: 'Play group')
      ],
      debug: true
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) => NotificationController.onActionReceivedMethod(receivedAction),
    );
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return GetMaterialApp(
        title: 'Music Player',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white, //<-- SEE HERE
                displayColor: Colors.pinkAccent, //<-- SEE HERE
              ),
          primaryColor: kTextGreyColor,
          primaryColorLight: kBackBlackColor,
          iconTheme: IconThemeData(color: Colors.white),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            background: kBackBlackColor,
            secondary: kTextGreyColor,
            surface: kBackBlackColor,
            surfaceTint: kBackBlackColor,
          ),
          useMaterial3: true,
        ),
        theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: kBackBlackColor, //<-- SEE HERE
            displayColor: Colors.pinkAccent, //<-- SEE HERE
          ),
          primaryColor: kTextGreyColor,
          primaryColorLight: Colors.white,
          iconTheme: IconThemeData(color: kBackBlackColor),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            background: Colors.white,
            secondary: kTextGreyColor,
            surface: Colors.white,
            surfaceTint: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: HomeScreen(),
      );
    });
  }
}
