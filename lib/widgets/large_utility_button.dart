import 'package:flutter/material.dart';
import 'package:remotesync/widgets/alertBox.dart';

class LargeUtilityButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final Future<void> Function()? onPressedAsync;  // NEW: Async callback
  final String? errorTitle;  // NEW: Custom error title
  final double height;
  final Duration timeout;  // NEW: Configurable timeout

  const LargeUtilityButton({
    super.key,
    required this.icon,
    required this.label,
    this.backgroundColor = const Color(0xFF3A3A3A),
    this.onPressed,
    this.onPressedAsync,
    this.errorTitle,
    this.height = 200,
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
    return Expanded(
      child: SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: (onPressed != null || onPressedAsync != null)
              ? () => _handlePress(context)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
