import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remotesync/screens/splash.dart';
import 'screens/pc_remote_control_screen.dart';
import 'theme/app_colors.dart';

void main() {

  runApp(const PCRemoteApp());
  
}

class PCRemoteApp extends StatelessWidget {
  const PCRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: const Splash(),
    );
  }
}
