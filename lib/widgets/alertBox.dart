import 'package:flutter/material.dart';
import 'package:remotesync/theme/responsive_helper.dart';

class ErrorAlert extends StatelessWidget {
  final String message;
  final String? title;

  const ErrorAlert({
    Key? key,
    required this.message,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.of(context).size.width;
        final dialogPadding = ResponsiveHelper.getDialogContentPadding(width);
        final iconSize = width >= 900 ? 48.0 : (width >= 600 ? 44.0 : 40.0);
        final titleSize = width >= 900 ? 22.0 : (width >= 600 ? 20.0 : 18.0);
        final messageSize = width >= 900 ? 15.0 : (width >= 600 ? 14.0 : 13.0);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 16,
          insetPadding: ResponsiveHelper.getDialogInsetPadding(width),
          child: Container(
            padding: dialogPadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade50, Colors.white],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(width >= 900 ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline_rounded, size: iconSize, color: Colors.red.shade600),
                ),
                SizedBox(height: width >= 900 ? 20 : 16),
                Text(
                  title ?? 'Operation Failed',
                  style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: width >= 900 ? 12 : 10),
                Text(
                  message,
                  style: TextStyle(fontSize: messageSize, color: Colors.grey.shade600, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: width >= 900 ? 24 : 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: width >= 900 ? 32 : 24,
                          vertical: width >= 900 ? 12 : 10,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Close', style: TextStyle(fontSize: width >= 900 ? 16 : 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  static Future<void> show(
      BuildContext context, {
        required String message,
        String? title,
        VoidCallback? onRetry,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ErrorAlert(message: message, title: title),
    );
  }
}
