import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Returns true if the user taps Allow.
Future<bool> showPermissionsDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.lightBlue,
              child: Icon(Icons.shield_outlined, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            const Text('Permissions Needed',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'ShareSync requires local Wi-Fi network scanning and storage '
                  'access permissions to transfer files between devices.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _row(Icons.wifi, 'Wi-Fi & Network Access',
                'Required to scan and connect local devices'),
            _row(Icons.folder_outlined, 'Storage Read & Write',
                'Required to save received files'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: AppTheme.pillOutlined,
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Deny'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: AppTheme.pillFilled.copyWith(
                        minimumSize:
                        const WidgetStatePropertyAll(Size.fromHeight(44))),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Allow'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

Widget _row(IconData icon, String title, String sub) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    children: [
      Icon(icon, size: 18, color: AppTheme.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
            Text(sub,
                style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    ],
  ),
);