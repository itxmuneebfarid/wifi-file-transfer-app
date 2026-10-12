import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _deviceName = 'ShareSync_Phone01';
  bool _keepAwake = true;
  bool _highBandwidth = true;
  final int _ftpPort = 2121;
  final String _downloadDir = '/Internal/Downloads/ShareSync';

  Future<void> _editName() async {
    final c = TextEditingController(text: _deviceName);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Device Display Name'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, c.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _deviceName = result);
    }
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(t,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _section('GENERAL OPTIONS'),
          ListTile(
            tileColor: Colors.white,
            title: const Text('Device Display Name',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(_deviceName, style: const TextStyle(fontSize: 11)),
            trailing:
            TextButton(onPressed: _editName, child: const Text('Edit')),
          ),
          SwitchListTile(
            tileColor: Colors.white,
            title: const Text('Keep Screen Awake',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Prevent sleeping during fast file transfers',
                style: TextStyle(fontSize: 11)),
            value: _keepAwake,
            onChanged: (v) => setState(() => _keepAwake = v),
          ),
          _section('NETWORK & SPEED'),
          SwitchListTile(
            tileColor: Colors.white,
            title: const Text('Use Highest Bandwidth',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Enable 5GHz Wi-Fi channels when available',
                style: TextStyle(fontSize: 11)),
            value: _highBandwidth,
            onChanged: (v) => setState(() => _highBandwidth = v),
          ),
          ListTile(
            tileColor: Colors.white,
            title: const Text('FTP Port',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(
                'Default FTP transfer port is configured to $_ftpPort',
                style: const TextStyle(fontSize: 11)),
            trailing: Text('$_ftpPort',
                style: const TextStyle(color: AppTheme.primary)),
          ),
          _section('STORAGE PATH'),
          ListTile(
            tileColor: Colors.white,
            title: const Text('Download Directory',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(_downloadDir, style: const TextStyle(fontSize: 11)),
            trailing:
            TextButton(onPressed: () {}, child: const Text('Change')),
          ),
        ],
      ),
    );
  }
}