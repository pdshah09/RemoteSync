import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class RemoteApiService {

  static Process? _serverProcess;
  static String? _cachedBaseUrl;

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

  static Future<bool> _testUrl(String url) async {
    try {
      print("${url}");
      final response = await http.get(Uri.parse('$url/verify')).timeout(
        const Duration(milliseconds: 300),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Scan 192.168.x.x range to find server (parallel)
  static Future<String?> _scanForServer() async {
    for (int j = 0; j <= 255; j++) {
      final futures = <Future<String?>>[];

      for (int i = 1; i <= 254; i++) {
        final url = 'http://192.168.$j.$i:8000';
        futures.add(_testUrl(url).then((success) => success ? url : null));
      }

      final results = await Future.wait(futures);
      final found = results.firstWhere((url) => url != null, orElse: () => null);
      if (found != null) return found;
    }

    return null;
  }


  // Auto-detect platform and return appropriate URL
  static Future<String> get baseUrl async {
    // Return cached URL if available
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }

    // Original discovery logic
    if (Platform.isAndroid || Platform.isIOS) {
      const primaryUrl = 'http://192.168.1.2:8000';
      if (await _testUrl(primaryUrl)) {
        _cachedBaseUrl = primaryUrl;
        return _cachedBaseUrl!;
      }

      final discovered = await _scanForServer();
      if (discovered != null) {
        _cachedBaseUrl = discovered;
        return _cachedBaseUrl!;
      }

      _cachedBaseUrl = primaryUrl;
      return _cachedBaseUrl!;
    } else {
      const primaryUrl = 'http://0.0.0.0:8000';
      const fallbackUrl = 'http://127.0.0.1:8000';

      if (await _testUrl(primaryUrl)) {
        _cachedBaseUrl = primaryUrl;
      } else {
        _cachedBaseUrl = fallbackUrl;
      }
      return _cachedBaseUrl!;
    }
  }



  // System Power Controls
  static Future<void> systemControl(String action) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/system/$action'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }

  // Media Controls
  static Future<void> mediaControl(String action) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/media/$action'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }

  // Browser
  static Future<void> openBrowser() async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/app/browser'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }

  // Screenshot
  static Future<void> takeScreenshot() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/action/screenshot'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.body}');
    }
  }
}
