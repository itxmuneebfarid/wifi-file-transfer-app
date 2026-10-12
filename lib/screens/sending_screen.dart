import 'package:flutter/material.dart';
import '../widgets/transfer_progress_view.dart';

class SendingScreen extends StatelessWidget {
  final String deviceName;
  const SendingScreen({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('File Transfer',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
      body: TransferProgressView(
        title: 'Sending...',
        subtitle: 'Connecting to $deviceName',
        fileName: 'Vacation_Video_2026_4K.mp4',
        totalMb: 350,
        speedMbps: 12.4,
        sending: true,
        cancelLabel: 'Cancel Transfer',
        onCancel: () => Navigator.popUntil(context, (r) => r.isFirst),
        onDone: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Transfer complete')));
          Navigator.popUntil(context, (r) => r.isFirst);
        },
      ),
    );
  }
}