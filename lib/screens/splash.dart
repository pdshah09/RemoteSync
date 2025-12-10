import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:remotesync/main.dart';
import 'package:remotesync/screens/pc_remote_control_screen.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CupertinoColors.black,
            CupertinoColors.systemIndigo,
          ],
        ),
      ),

      child: AnimatedSplashScreen(
        duration: 1500,
        animationDuration: const Duration(milliseconds: 1300),
        splash: Image.asset('assets/icon/remotesync.png'),
        nextScreen: const PCRemoteControlScreen(),
        splashTransition: SplashTransition.scaleTransition,
        pageTransitionType: PageTransitionType.fade,
        curve: Curves.fastEaseInToSlowEaseOut,
        splashIconSize: 240,
        centered: true,
        backgroundColor: CupertinoColors.black.withOpacity(0.5),
      ),
    );

  }
}
