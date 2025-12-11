import 'package:flutter/material.dart';
import 'package:remotesync/widgets/alertBox.dart';

class RemoteButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final Future<void> Function()? onPressedAsync;
  final String? errorTitle;
  final double iconSize;
  final double fontSize;
  final Duration timeout;  // NEW: Configurable timeout

  const RemoteButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.onPressed,
    this.onPressedAsync,
    this.errorTitle,
    this.iconSize = 24,
    this.fontSize = 15,
    this.timeout = const Duration(seconds: 2),
  });

  Future<void> _handlePress(BuildContext context) async {
    if (onPressedAsync != null) {
      try {
        await onPressedAsync!().timeout(
          timeout,
          onTimeout: () {
            throw Exception('Operation timed out after ${timeout.inSeconds} seconds');
          },
        );
      } catch (e) {
        if (context.mounted) {
          ErrorAlert.show(
            context,
            message: e.toString().replaceAll('Exception: ', ''),
            title: errorTitle ?? 'System Control Failed',
          );
        }
      }
    } else if (onPressed != null) {
      onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        onPressed: (onPressed != null || onPressedAsync != null)
            ? () => _handlePress(context)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: fontSize, color: Colors.white),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
