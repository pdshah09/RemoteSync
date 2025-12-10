import 'dart:io';
import 'package:http/http.dart' as http;

class RemoteApiService {
  static String get baseUrl {
    // Auto-detect platform and return appropriate URL
    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://192.168.1.2:8000'; // Mobile: use PC's local IP
    } else {
      return 'http://0.0.0.0:8000'; // Desktop: use localhost
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
