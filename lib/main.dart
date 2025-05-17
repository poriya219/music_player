import 'package:MusicFlow/controllers/analytics.dart';
import 'package:MusicFlow/controllers/player_controller.dart';
import 'package:MusicFlow/firebase_options.dart';
import 'package:MusicFlow/translations/translation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:MusicFlow/constans.dart';
import 'package:MusicFlow/pages/home_screen/home_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(backgroundCallback);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'play_channel_group',
    androidNotificationChannelName: 'play channel',
    androidNotificationOngoing: true,
  );
  await Translator.initLanguages();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final prefs = await SharedPreferences.getInstance();
  String userLocale = prefs.getString('locale') ??
      (Get.deviceLocale ?? const Locale('en')).languageCode;
  bool? isDark = prefs.getBool('isDark');
  runApp(MyApp(
    userLocale: userLocale,
    isDark: isDark,
  ));
}

class MyApp extends StatelessWidget {
  final String userLocale;
  final bool? isDark;
  MyApp({super.key, required this.userLocale, required this.isDark});
  AnalyticsServices analyticsService = AnalyticsServices();

  @override
  Widget build(BuildContext context) {
    analyticsService.logAppOpen();
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return GetMaterialApp(
        title: 'MusicFlow',
        debugShowCheckedModeBanner: false,
        initialBinding: Initializer(),
        navigatorObservers: <NavigatorObserver>[analyticsService.getObserver()],
        themeMode: isDark == null
            ? ThemeMode.system
            : (isDark == true ? ThemeMode.dark : ThemeMode.light),
        locale: Locale(userLocale),
        darkTheme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white, //<-- SEE HERE
                displayColor: Colors.pinkAccent, //<-- SEE HERE
                fontFamily: userLocale == 'fa' ? "Peyda" : "OpenSans",
              ),
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
            ),
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
          drawerTheme: DrawerThemeData(
            backgroundColor: kBackBlackColor, // رنگ دلخواه
          ),
          cardTheme: CardTheme(
            color: kBackBlackColor,
          ),
          useMaterial3: true,
        ),
        theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: kBackBlackColor, //<-- SEE HERE
                displayColor: Colors.pinkAccent, //<-- SEE HERE
                fontFamily: userLocale == 'fa' ? "Peyda" : "OpenSans",
              ),
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              color: kBackBlackColor,
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
            ),
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
          drawerTheme: const DrawerThemeData(
            backgroundColor: Colors.white, // رنگ دلخواه
          ),
          cardTheme: const CardTheme(
            color: Colors.white,
          ),
          useMaterial3: true,
        ),
        home: HomeScreen(),
      );
    });
  }
}

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  final String action = uri.host;

  WidgetsFlutterBinding.ensureInitialized();
  print('action: ${uri?.host}');
  final playerController = Get.put(PlayerController());
  switch (action) {
    case 'play_pause':
      if (playerController.player.playing) {
        playerController.player.pause();
      } else {
        playerController.player.play();
      }
      break;
    case 'next':
      playerController.player.seekToNext();
      break;
    case 'previous':
      playerController.player.seekToPrevious();
      break;
    case 'like':
      // toggle like
      break;
  }
}
