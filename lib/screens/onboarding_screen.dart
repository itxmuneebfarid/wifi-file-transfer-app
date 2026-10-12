import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                    color: AppTheme.lightBlue, shape: BoxShape.circle),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.smartphone, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Icon(Icons.wifi, color: AppTheme.primary, size: 18),
                    SizedBox(width: 8),
                    Icon(Icons.desktop_windows_outlined,
                        color: AppTheme.primary),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Connect devices in\nseconds over local Wi-Fi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'No mobile data usage, no internet required.\n'
                    'Fast peer-to-peer connection over local wireless networks.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              FilledButton(
                style: AppTheme.pillFilled,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainShell()),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}