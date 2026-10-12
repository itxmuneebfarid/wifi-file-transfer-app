import 'package:flutter/material.dart';
import '../widgets/transfer_progress_view.dart';

class ReceivingScreen extends StatelessWidget {
  const ReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('File Transfer',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
      body: TransferProgressView(
        title: 'Receiving...',
        subtitle: 'Incoming from Device-01_Wireless',
        fileName: 'Album_Archive_Compressed.zip',
        totalMb: 850,
        speedMbps: 18.2,
        sending: false,
        cancelLabel: 'Cancel',
        onCancel: () => Navigator.pop(context),
        onDone: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('File received')));
          Navigator.pop(context);
        },
      ),
    );
  }
}