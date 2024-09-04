import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/constans.dart';
import 'package:music_player/pages/home_screen/home_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'bindings.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'play_channel_group',
    androidNotificationChannelName: 'play channel',
    androidNotificationOngoing: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return GetMaterialApp(
        title: 'Music Player',
        initialBinding: Initializer(),
        themeMode: ThemeMode.system,
        darkTheme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white, //<-- SEE HERE
                displayColor: Colors.pinkAccent, //<-- SEE HERE
              ),
          primaryColor: kTextGreyColor,
          primaryColorLight: kBackBlackColor,
          iconTheme: const IconThemeData(color: Colors.white),
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
