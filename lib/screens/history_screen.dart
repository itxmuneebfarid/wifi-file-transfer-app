import 'package:flutter/material.dart';
import '../models/transfer_record.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransferRecord> _items = List.of(sampleHistory);
  String _filter = 'All'; // All | Sent | Received

  List<TransferRecord> get _visible => switch (_filter) {
    'Sent' => _items.where((e) => e.sent).toList(),
    'Received' => _items.where((e) => !e.sent).toList(),
    _ => _items,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final f in ['All', 'Sent', 'Received'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f, style: const TextStyle(fontSize: 11)),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _items = []),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label:
                  const Text('Clear All', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? const Center(
                child: Text('No transfers yet',
                    style: TextStyle(color: Colors.black45)))
                : ListView.separated(
              itemCount: _visible.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = _visible[i];
                final color = r.sent ? AppTheme.primary : Colors.green;
                return ListTile(
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withAlpha(30),
                    child: Icon(
                        r.sent ? Icons.north_east : Icons.south_west,
                        size: 16,
                        color: color),
                  ),
                  title: Text(r.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  subtitle:
                  Text(r.meta, style: const TextStyle(fontSize: 10)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(r.sent ? 'Sent' : 'Received',
                        style: TextStyle(fontSize: 10, color: color)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}