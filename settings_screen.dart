import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../services/cloud_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _editName(BuildContext context, AppState app) async {
    final c = TextEditingController(text: app.deviceName);
    final r = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Device name'),
        content: TextField(controller: c, autofocus: true, maxLength: 24, decoration: const InputDecoration(hintText: 'e.g. Farid Phone')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (r != null && r.isNotEmpty) app.setDeviceName(r);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    const bold = TextStyle(fontWeight: FontWeight.w600);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        const SectionLabel('This phone'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.smartphone_rounded, color: AppTheme.cyan),
              title: const Text('Device name', style: bold),
              subtitle: Text(app.deviceName),
              trailing: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.muted),
              onTap: () => _editName(context, app),
            ),
            ListTile(
              leading: Icon(app.net.connected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: app.net.connected ? AppTheme.green : AppTheme.coral),
              title: Text(app.net.label, style: bold),
              subtitle: Text(app.net.ip ?? 'Connect to Wi-Fi or a hotspot'),
              trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: app.refreshNetwork),
            ),
          ]),
        ),
        const SectionLabel('Transfers'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            SwitchListTile(
              title: const Text('Save photos & videos to Gallery', style: bold),
              value: app.autoGallery,
              onChanged: (v) => app.updateSettings(autoGallery: v),
            ),
            SwitchListTile(
              title: const Text('Keep screen on while transferring', style: bold),
              value: app.keepAwake,
              onChanged: (v) => app.updateSettings(keepAwake: v),
            ),
            ListTile(
              title: const Text('Received files folder', style: bold),
              subtitle: Text(app.receiveDirectory?.path ?? '—', style: const TextStyle(fontSize: 12)),
            ),
          ]),
        ),
        const SectionLabel('Firebase'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            ListTile(
              leading: Icon(Icons.cloud_outlined, color: app.cloud.ready ? AppTheme.green : AppTheme.coral),
              title: const Text('Status', style: bold),
              subtitle: Text(
                switch (app.cloud.status) {
                  CloudStatus.online => 'Connected • transfer records are saved',
                  CloudStatus.connecting => 'Connecting…',
                  CloudStatus.error => app.cloud.error ?? 'Error',
                  CloudStatus.off => 'Off',
                },
                style: const TextStyle(fontSize: 12),
              ),
              trailing: app.cloud.ready
                  ? const Pill(text: 'Online', color: AppTheme.green)
                  : TextButton(onPressed: app.cloud.retry, child: const Text('Retry')),
            ),
            if (app.cloud.uid != null)
              ListTile(
                title: const Text('User ID', style: bold),
                subtitle: Text(app.cloud.uid!, style: const TextStyle(fontSize: 12)),
              ),
          ]),
        ),
        const SectionLabel('Gesture mode'),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(children: [
            SwitchListTile(
              title: const Text('Enable gestures', style: bold),
              value: app.gestureEnabled,
              onChanged: (v) => app.updateSettings(gestureEnabled: v),
            ),
            ListTile(
              title: Text('Hold time: ${(app.holdMs / 1000).toStringAsFixed(1)} s', style: bold),
              subtitle: Slider(
                min: 400,
                max: 2000,
                divisions: 16,
                value: app.holdMs.toDouble().clamp(400, 2000),
                onChanged: (v) => app.updateSettings(holdMs: v.round()),
              ),
            ),
            ListTile(
              title: Text('Sensitivity: ${(app.sensitivity * 100).round()}%', style: bold),
              subtitle: Slider(value: app.sensitivity, onChanged: (v) => app.updateSettings(sensitivity: v)),
            ),
            SwitchListTile(
              title: const Text('Use front camera', style: bold),
              value: app.frontCamera,
              onChanged: (v) => app.updateSettings(frontCamera: v),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        const Center(child: Text('$kAppName v1.0', style: TextStyle(color: AppTheme.muted, fontSize: 12))),
      ],
    );
  }
}
