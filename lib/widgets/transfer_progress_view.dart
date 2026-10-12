import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared progress UI used by the Sending and Receiving screens.
/// Progress is simulated; replace with real socket/FTP progress later.
class TransferProgressView extends StatefulWidget {
  final String title;
  final String subtitle;
  final String fileName;
  final double totalMb;
  final double speedMbps;
  final bool sending;
  final String cancelLabel;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const TransferProgressView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fileName,
    required this.totalMb,
    required this.speedMbps,
    required this.sending,
    required this.cancelLabel,
    required this.onCancel,
    required this.onDone,
  });

  @override
  State<TransferProgressView> createState() => _TransferProgressViewState();
}

class _TransferProgressViewState extends State<TransferProgressView> {
  double _done = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      setState(() => _done += widget.speedMbps * 0.3);
      if (_done >= widget.totalMb) {
        t.cancel();
        _done = widget.totalMb;
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = ((widget.totalMb - _done) / widget.speedMbps).ceil();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.title,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const Spacer(),
          CircleAvatar(
            radius: 55,
            backgroundColor: AppTheme.lightBlue,
            child: Icon(
                widget.sending
                    ? Icons.cloud_upload_outlined
                    : Icons.cloud_download_outlined,
                size: 40,
                color: AppTheme.primary),
          ),
          const Spacer(),
          Card(
            elevation: 0,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.fileName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                      '${_done.toStringAsFixed(1)} MB of ${widget.totalMb.toStringAsFixed(1)} MB ${widget.sending ? "sent" : "received"}',
                      style:
                      const TextStyle(fontSize: 11, color: Colors.black54)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _done / widget.totalMb,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(6),
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.lightBlue,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.bolt,
                            size: 14, color: AppTheme.primary),
                        Text(' ${widget.speedMbps} MB/s',
                            style: const TextStyle(fontSize: 11)),
                      ]),
                      Text('About $remaining seconds left',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: OutlinedButton(
              style: AppTheme.pillOutlined,
              onPressed: widget.onCancel,
              child: Text(widget.cancelLabel),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}