import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/permissions_dialog.dart';
import 'discovery_screen.dart';
import 'receiving_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onSend(BuildContext context) async {
    final allowed = await showPermissionsDialog(context);
    if (!allowed || !context.mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const DiscoveryScreen()));
  }

  Future<void> _onReceive(BuildContext context) async {
    final allowed = await showPermissionsDialog(context);
    if (!allowed || !context.mounted) return;
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ReceivingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.lightBlue,
              child: Icon(Icons.person_outline,
                  size: 18, color: AppTheme.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                  child: _ActionCard(
                    icon: Icons.north_east,
                    title: 'Send Files',
                    subtitle: 'Share with others',
                    onTap: () => _onSend(context),
                  )),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionCard(
                    icon: Icons.south_west,
                    title: 'Receive',
                    subtitle: 'Wait for connection',
                    onTap: () => _onReceive(context),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.storage_outlined,
                          size: 18, color: AppTheme.primary),
                      SizedBox(width: 8),
                      Text('Storage Overview',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Spacer(),
                      Text('64% Used',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.primary)),
                    ],
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.64,
                    minHeight: 6,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.lightBlue,
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('82 GB Available',
                          style: TextStyle(fontSize: 10, color: Colors.black54)),
                      Text('128 GB Total',
                          style: TextStyle(fontSize: 10, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppTheme.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Make sure the receiving device is also on the same local Wi-Fi network.',
                    style: TextStyle(fontSize: 11, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.lightBlue,
                child: Icon(icon, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}