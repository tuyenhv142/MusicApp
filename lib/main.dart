import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app/views/pages/login_page.dart';
import 'package:app/views/pages/myhome_page.dart';
import 'package:app/view_models/AuthProvider.dart';
import 'package:app/view_models/banner_provide.dart';
import 'package:app/view_models/playList_provider.dart';
import 'package:app/view_models/singer_provider.dart';
import 'package:app/view_models/track_provide.dart';
import 'package:app/view_models/user_provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('idUser');
  bool isLoggedIn = userId != null;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BannerProvider>(
          create: (context) => BannerProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider<SingerProvider>(
          create: (context) => SingerProvider(),
        ),
        ChangeNotifierProvider<PlayListProvider>(
          create: (context) => PlayListProvider(),
        ),
        ChangeNotifierProvider<TrackProvider>(
          create: (context) => TrackProvider(),
        ),
        // ChangeNotifierProvider<AudioProvider>(
        //   create: (context) => AudioProvider(),
        // ),
      ],
      // child: DevicePreview(
      //     enabled: !kReleaseMode,
      //     builder: (context) => (MyApp(isLoggedIn: isLoggedIn))),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return MaterialApp(
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AnimatedSplashScreen(
        duration: 3000,
        splash: Center(
          child: Image.asset(
            "assets/images/app_logo.png",
            width: media.width * 0.8,
          ),
        ),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.white,
        nextScreen: isLoggedIn ? const MyHomePage() : const LoginPage(),
      ),
    );
  }
}
