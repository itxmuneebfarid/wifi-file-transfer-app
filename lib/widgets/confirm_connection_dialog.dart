import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shows a PIN that must be confirmed on both devices. Returns true on OK.
Future<bool> showConfirmConnectionDialog(
    BuildContext context, String deviceName) async {
  final pin = (1000 + Random().nextInt(9000)).toString();
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
              child: Icon(Icons.vpn_key_outlined, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            const Text('Confirm Connection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                children: [
                  const TextSpan(text: 'Pair with '),
                  TextSpan(
                      text: deviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text: '. Please enter the connection PIN on both devices.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(pin,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: AppTheme.pillOutlined,
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: AppTheme.pillFilled.copyWith(
                        minimumSize:
                        const WidgetStatePropertyAll(Size.fromHeight(44))),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('OK'),
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