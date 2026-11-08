import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All';

  Future<void> _confirmClear(AppState app) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Clear history?'),
        content: const Text('This removes the list only. Received files stay on your phone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear', style: TextStyle(color: AppTheme.coral))),
        ],
      ),
    );
    if (ok == true) app.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = switch (_filter) {
      'Sent' => app.history.where((e) => e.sent).toList(),
      'Received' => app.history.where((e) => !e.sent).toList(),
      _ => app.history,
    };
    final sentBytes = app.history.where((e) => e.sent).fold<int>(0, (a, e) => a + e.bytes);
    final recvBytes = app.history.where((e) => !e.sent).fold<int>(0, (a, e) => a + e.bytes);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Row(children: [
          Expanded(child: _Stat(Icons.north_east, 'Sent', formatBytes(sentBytes), AppTheme.cyan)),
          const SizedBox(width: 12),
          Expanded(child: _Stat(Icons.south_west, 'Received', formatBytes(recvBytes), AppTheme.green)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          for (final f in ['All', 'Sent', 'Received', 'Cloud'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f)),
            ),
          const Spacer(),
          if (app.history.isNotEmpty && _filter != 'Cloud')
            TextButton(onPressed: () => _confirmClear(app), child: const Text('Clear')),
        ]),
      ),
      Expanded(
        child: _filter == 'Cloud'
            ? _CloudList(app: app)
            : items.isEmpty
            ? const EmptyState(icon: Icons.history, title: 'No transfers yet', subtitle: 'Files you send and receive will be listed here.')
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final r = items[i];
                  final c = r.sent ? AppTheme.cyan : AppTheme.green;
                  final canOpen = r.path != null && File(r.path!).existsSync();
                  return GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    onTap: canOpen ? () => OpenFilex.open(r.path!) : null,
                    child: Row(children: [
                      IconBadge(r.sent ? Icons.north_east : Icons.south_west, color: c, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${r.sent ? 'To' : 'From'} ${r.peer} • ${formatBytes(r.bytes)}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                          Text(relativeTime(r.time), style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                        ]),
                      ),
                      Pill(text: r.sent ? 'Sent' : 'Received', color: c),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }
}

/// Records saved in Firestore (`transfers` collection) by this phone.
class _CloudList extends StatefulWidget {
  final AppState app;
  const _CloudList({required this.app});
  @override
  State<_CloudList> createState() => _CloudListState();
}

class _CloudListState extends State<_CloudList> {
  Stream<List<Map<String, dynamic>>>? _stream;

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    if (!app.cloud.ready) {
      _stream = null;
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Firebase not connected',
        subtitle: app.cloud.error ?? 'Connect to the internet, then open Settings → Firebase → Retry.',
      );
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream ??= app.cloud.myTransfers(),
      builder: (context, snap) {
        if (snap.hasError) {
          return EmptyState(icon: Icons.error_outline, title: 'Could not load records', subtitle: '${snap.error}');
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        if (list.isEmpty) {
          return const EmptyState(
              icon: Icons.cloud_queue, title: 'No cloud records yet', subtitle: 'Every transfer is saved here automatically.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final m = list[i];
            final sent = m['direction'] == 'sent';
            final status = (m['status'] as String?) ?? 'done';
            final ok = status == 'done';
            final c = !ok ? AppTheme.coral : (sent ? AppTheme.cyan : AppTheme.green);
            final t = m['clientTime'];
            final time = t is Timestamp ? relativeTime(t.toDate()) : '';
            final other = sent ? m['toName'] : m['fromName'];
            return GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(children: [
                IconBadge(sent ? Icons.north_east : Icons.south_west, color: c, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${m['fileName'] ?? ''}',
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${sent ? 'To' : 'From'} ${other ?? 'Unknown'} • ${formatBytes((m['bytes'] as num?) ?? 0)}',
                        style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                    Text(time, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                  ]),
                ),
                Pill(text: ok ? (sent ? 'Sent' : 'Received') : status, color: c),
              ]),
            );
          },
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _Stat(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => GlassCard(
        child: Row(children: [
          IconBadge(icon, color: color, size: 38),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
          ]),
        ]),
      );
}
