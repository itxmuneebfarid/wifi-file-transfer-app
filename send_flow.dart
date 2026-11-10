import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/models.dart';
import '../services/file_picking.dart';
import '../services/network_info.dart';
import '../services/share_intent_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

// =====================================================================
// STEP 1 — Connect: same Wi-Fi (recommended) or phone hotspot
// =====================================================================
class ConnectScreen extends StatefulWidget {
  final bool forSending;
  const ConnectScreen({super.key, required this.forSending});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    app.refreshNetwork();
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => app.refreshNetwork());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  void _next() {
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => widget.forSending ? const PickFilesScreen() : const ReceiveScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final net = app.net;
    return Scaffold(
      appBar: AppBar(title: Text(widget.forSending ? 'Send • Connect' : 'Receive • Connect')),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
              _StatusCard(net: net),
              const SectionLabel('Choose a connection'),
              _OptionCard(
                icon: Icons.wifi_rounded,
                title: 'Same Wi-Fi',
                badge: 'Recommended',
                active: net.kind == NetKind.wifi,
                body: 'Connect both phones to the same Wi-Fi router. Fastest and most stable. '
                    'If the Wi-Fi has internet, records are also saved in Firebase.',
                action: 'Open Wi-Fi settings',
                onAction: SystemChannel.openWifiSettings,
              ),
              const SizedBox(height: 10),
              _OptionCard(
                icon: Icons.wifi_tethering_rounded,
                title: 'Phone hotspot',
                badge: 'No Wi-Fi?',
                active: net.kind == NetKind.hotspotHost,
                body: 'Turn ON hotspot on one phone, then connect the other phone to that hotspot. '
                    'Works anywhere, no router needed.',
                action: 'Open hotspot settings',
                onAction: SystemChannel.openHotspotSettings,
              ),
              const SizedBox(height: 14),
              const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.muted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mobile data alone cannot transfer files. Both phones must be on the same Wi-Fi or hotspot, '
                    'with ShareSync open.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.4),
                  ),
                ),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              FilledButton(
                onPressed: net.connected ? _next : null,
                child: Text(net.connected ? 'Continue' : 'Connect to Wi-Fi or hotspot first'),
              ),
              if (!net.connected) TextButton(onPressed: _next, child: const Text('Continue anyway')),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final NetStatus net;
  const _StatusCard({required this.net});
  @override
  Widget build(BuildContext context) {
    final ok = net.connected;
    final c = ok ? AppTheme.green : AppTheme.coral;
    return GlassCard(
      borderColor: c.withValues(alpha: 0.4),
      child: Row(children: [
        IconBadge(ok ? Icons.check_rounded : Icons.wifi_off_rounded, color: c),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(net.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(ok ? 'IP ${net.ip}' : 'Choose an option below', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title, badge, body, action;
  final bool active;
  final VoidCallback onAction;
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.body,
    required this.action,
    required this.onAction,
    required this.active,
  });

  @override
  Widget build(BuildContext context) => GlassCard(
        borderColor: active ? AppTheme.cyan : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconBadge(icon, size: 40),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
            if (active)
              const Pill(icon: Icons.check, text: 'In use', color: AppTheme.green)
            else
              Pill(text: badge, color: badge == 'Recommended' ? AppTheme.cyan : AppTheme.amber),
          ]),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.4)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            onPressed: onAction,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(action),
          ),
        ]),
      );
}

// =====================================================================
// STEP 2 — Pick files (single or multiple): photos, videos, documents, any
// =====================================================================
class PickFilesScreen extends StatelessWidget {
  const PickFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final busy = app.active?.isRunning ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select files'),
        actions: [if (app.queue.isNotEmpty) TextButton(onPressed: app.clearQueue, child: const Text('Clear'))],
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(children: [
              Expanded(child: _Pick(Icons.photo_library_outlined, 'Photos', AppTheme.green, () async => app.addFiles(await pickFilesOf(FileType.image)))),
              const SizedBox(width: 8),
              Expanded(child: _Pick(Icons.videocam_outlined, 'Videos', AppTheme.coral, () async => app.addFiles(await pickFilesOf(FileType.video)))),
              const SizedBox(width: 8),
              Expanded(child: _Pick(Icons.description_outlined, 'Docs', AppTheme.amber, () async => app.addFiles(await pickDocuments()))),
              const SizedBox(width: 8),
              Expanded(child: _Pick(Icons.folder_outlined, 'Files', AppTheme.cyan, () async => app.addFiles(await pickFilesOf(FileType.any)))),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text('Tip: long-press in the gallery to select many at once.', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          ),
          Expanded(
            child: app.queue.isEmpty
                ? const EmptyState(
                    icon: Icons.add_photo_alternate_outlined,
                    title: 'No files selected',
                    subtitle: 'Choose photos, videos, documents or any file above.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: app.queue.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final f = app.queue[i];
                      return GlassCard(
                        padding: const EdgeInsets.all(10),
                        child: Row(children: [
                          _Thumb(file: f),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(formatBytes(f.size), style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                            ]),
                          ),
                          IconButton(icon: const Icon(Icons.close, size: 20, color: AppTheme.muted), onPressed: () => app.removeFile(f)),
                        ]),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: FilledButton.icon(
              onPressed: app.queue.isEmpty || busy
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ScanScreen())),
              icon: const Icon(Icons.send_rounded),
              label: Text(app.queue.isEmpty ? 'Select files to send' : 'Send now • ${app.queue.length} file(s) • ${formatBytes(app.queueBytes)}'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Pick extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _Pick(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          IconBadge(icon, color: color, size: 42),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
      );
}

class _Thumb extends StatelessWidget {
  final QueuedFile file;
  const _Thumb({required this.file});
  @override
  Widget build(BuildContext context) {
    final isImg = kImageExt.contains(p.extension(file.name).toLowerCase());
    if (isImg) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(file.path),
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          cacheWidth: 140,
          errorBuilder: (_, __, ___) => IconBadge(fileIcon(file.name), color: fileColor(file.name), size: 46),
        ),
      );
    }
    return IconBadge(fileIcon(file.name), color: fileColor(file.name), size: 46);
  }
}

// =====================================================================
// STEP 3 — Scan nearby phones in real time, tap one to send an invitation
// =====================================================================
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().refreshDiscovery();
  }

  Future<void> _invite(AppState app, Peer peer) async {
    if (app.active?.isRunning ?? false) return;
    app.selectTarget(peer);
    await app.sendQueue(); // sends the invitation; the progress screen opens automatically
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final busy = app.active?.isRunning ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a device')),
      body: SafeArea(
        top: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
          SizedBox(height: 230, child: Radar(color: AppTheme.cyan, center: Icons.north_east_rounded)),
          Center(
            child: Text(app.peers.isEmpty ? 'Searching for nearby phones…' : '${app.peers.length} device(s) found',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text('${app.queue.length} file(s) • ${formatBytes(app.queueBytes)} ready to send',
                style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(onPressed: app.refreshDiscovery, icon: const Icon(Icons.refresh, size: 18), label: const Text('Rescan')),
          ),
          const SectionLabel('Tap a device to send'),
          if (app.queue.isEmpty)
            const GlassCard(child: Text('No files selected. Go back and select files first.', style: TextStyle(color: AppTheme.muted)))
          else if (app.peers.isEmpty)
            const GlassCard(
              child: Text(
                'On the other phone: open ShareSync → Receive.\n'
                'Both phones must be on the same Wi-Fi or hotspot.',
                style: TextStyle(color: AppTheme.muted, height: 1.5),
              ),
            )
          else
            for (final peer in app.peers)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: busy ? null : () => _invite(app, peer),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.cyan.withValues(alpha: 0.16),
                      child: Text(peer.name.isEmpty ? '?' : peer.name[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.w800, fontSize: 18)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(peer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(peer.viaCloud ? '${peer.ip} • found via Firebase' : '${peer.ip} • same network',
                            style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                      ]),
                    ),
                    const Icon(Icons.send_rounded, color: AppTheme.cyan),
                  ]),
                ),
              ),
        ]),
      ),
    );
  }
}

// =====================================================================
// RECEIVE — stay visible; invitations pop up as Accept / Reject
// =====================================================================
class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});
  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().refreshDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: SafeArea(
        top: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
          SizedBox(height: 260, child: Radar(color: AppTheme.green, center: Icons.south_west_rounded)),
          const Center(child: Text('Ready to receive', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20))),
          const SizedBox(height: 6),
          Center(
            child: Text('Visible as "${app.deviceName}"', style: const TextStyle(color: AppTheme.muted)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(app.net.connected ? app.net.ip! : 'Not on Wi-Fi / hotspot',
                style: TextStyle(color: app.net.connected ? AppTheme.muted : AppTheme.coral, fontSize: 12)),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('On the sending phone', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _step('1', 'Tap Send and select files'),
              _step('2', 'Tap Send now'),
              _step('3', 'Tap "${app.deviceName}" in the list'),
              _step('4', 'Accept the invitation here'),
            ]),
          ),
          const SizedBox(height: 12),
          if (!app.receiverOn)
            GlassCard(
              borderColor: AppTheme.coral.withValues(alpha: 0.5),
              child: Row(children: [
                const Expanded(child: Text('Receiver is off.', style: TextStyle(color: AppTheme.coral))),
                TextButton(onPressed: app.startNetworking, child: const Text('Restart')),
              ]),
            ),
          Center(
            child: Text('${app.peers.length} other ShareSync phone(s) on this network',
                style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
          ),
        ]),
      ),
    );
  }

  Widget _step(String n, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppTheme.green.withValues(alpha: 0.18),
            child: Text(n, style: const TextStyle(color: AppTheme.green, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
        ]),
      );
}

// =====================================================================
// Radar animation
// =====================================================================
class Radar extends StatefulWidget {
  final Color color;
  final IconData center;
  const Radar({super.key, required this.color, required this.center});
  @override
  State<Radar> createState() => _RadarState();
}

class _RadarState extends State<Radar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _RadarPainter(_c.value, widget.color),
          child: Center(
            child: CircleAvatar(radius: 30, backgroundColor: widget.color, child: Icon(widget.center, color: Colors.white, size: 28)),
          ),
        ),
      );
}

class _RadarPainter extends CustomPainter {
  final double t;
  final Color color;
  _RadarPainter(this.t, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = math.min(size.width, size.height) / 2;
    for (var i = 0; i < 3; i++) {
      final v = (t + i / 3) % 1;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: (1 - v) * 0.5);
      canvas.drawCircle(c, 34 + (maxR - 34) * v, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.t != t;
}
