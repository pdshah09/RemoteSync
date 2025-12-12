import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:remotesync/screens/splash.dart';
import 'package:remotesync/services/remote_api_services.dart';
import 'theme/app_colors.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  // Start Python server on desktop platforms
  await RemoteApiService.startServer();
  await RemoteApiService.baseUrl;

  runApp(const PCRemoteApp());

}

class PCRemoteApp extends StatefulWidget {
  const PCRemoteApp({super.key});

  @override
  State<PCRemoteApp> createState() => _PCRemoteAppState();
}

class _PCRemoteAppState extends State<PCRemoteApp> {

  @override
  void initState() {
    super.initState();

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      await RemoteApiService.stopServer();
      return true; // Allow window to close
    });
  }

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
