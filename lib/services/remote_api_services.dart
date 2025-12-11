import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class RemoteApiService {

  static Process? _serverProcess;

  static Future<void> startServer() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {

      final tempDir = await getTemporaryDirectory();
      final exePath = path.join(tempDir.path, 'RemoteServer.exe');

      // Delete old EXE if exists
      final oldExe = File(exePath);
      if (await oldExe.exists()) {
        try {
          await oldExe.delete();
        } catch (_) {}
      }

      // Copy fresh EXE
      final data = await rootBundle.load('assets/server/RemoteServer.exe');
      final bytes = data.buffer.asUint8List();
      await File(exePath).writeAsBytes(bytes, flush: true);

      // Start server
      _serverProcess = await Process.start(exePath, []);

      // Read logs
      Stream.multi((controller) {
        _serverProcess!.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) => controller.add('OUT: $line'));

        _serverProcess!.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) => controller.add('ERR: $line'));
      }).listen((log) => print('SERVER: $log'));

      await Future.delayed(Duration(seconds: 2));
    }
  }


  static Future<void> stopServer() async {
    if (_serverProcess != null) {
      // On Windows, Process.kill() doesn't always work reliably
      // Use taskkill to ensure the process is terminated
      if (Platform.isWindows) {
        try {
          await Process.run('taskkill', ['/F', '/IM', 'RemoteServer.exe']);
        } catch (e) {
          print('Error killing server: $e');
        }
      } else {
        _serverProcess?.kill(ProcessSignal.sigkill);
      }
      _serverProcess = null;
    }
  }

  // Auto-detect platform and return appropriate URL
  static String get baseUrl {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://192.168.1.2:8000';
    } else {
      return 'http://0.0.0.0:8000';
    }
  }



  // System Power Controls
  static Future<void> systemControl(String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/system/$action'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }

  // Media Controls
  static Future<void> mediaControl(String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/media/$action'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }

  // Browser
  static Future<void> openBrowser() async {
    final response = await http.post(
      Uri.parse('$baseUrl/app/browser'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }

  // Screenshot
  static Future<void> takeScreenshot() async {
    final response = await http.get(
      Uri.parse('$baseUrl/action/screenshot'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }
}
