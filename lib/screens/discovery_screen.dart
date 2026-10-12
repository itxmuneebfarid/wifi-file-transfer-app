import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/confirm_connection_dialog.dart';
import 'file_manager_screen.dart';

class _Device {
  final String name;
  final IconData icon;
  const _Device(this.name, this.icon);
}

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final List<_Device> _devices = [];
  bool _scanning = true;

  @override
  void initState() {
    super.initState();
    _simulateScan();
  }

  // Replace with real mDNS / UDP broadcast discovery later.
  Future<void> _simulateScan() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _devices
        .add(const _Device('Device-01_Wireless', Icons.laptop_mac_outlined)));
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _devices.add(const _Device('Phone_01', Icons.smartphone)));
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _scanning = false);
  }

  Future<void> _connect(_Device d) async {
    final ok = await showConfirmConnectionDialog(context, d.name);
    if (!ok || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FileManagerScreen(deviceName: d.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovering Devices',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                  color: AppTheme.lightBlue, shape: BoxShape.circle),
              child: const Center(
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.sync, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(_scanning ? 'Scanning...' : 'Scan complete',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            const Text('Tap a device to connect',
                style: TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('DEVICES ON SAME NETWORK',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: Colors.black45)),
            ),
            const SizedBox(height: 8),
            if (_scanning)
              const Card(
                elevation: 0,
                child: ListTile(
                  dense: true,
                  leading: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  title: Text('Searching...', style: TextStyle(fontSize: 12)),
                ),
              ),
            for (final d in _devices)
              Card(
                elevation: 0,
                child: ListTile(
                  dense: true,
                  leading: Icon(d.icon, color: AppTheme.primary),
                  title: Text(d.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  onTap: () => _connect(d),
                ),
              ),
          ],
        ),
      ),
    );
  }
}