class TransferRecord {
  final String name;
  final String meta;
  final bool sent; // true = Sent, false = Received
  const TransferRecord(this.name, this.meta, this.sent);
}

const sampleHistory = <TransferRecord>[
  TransferRecord('Document_Brief_Draft.pdf', 'Today, 10:15 AM  •  4.2 MB', true),
  TransferRecord('Presentation_TechLaunch.pptx', 'Yesterday, 4:32 PM  •  28.0 MB', false),
  TransferRecord('IMG_3840_FullRes.jpg', 'Jan 12, 2026  •  6.4 MB', true),
  TransferRecord('Podcast_Episode_51.mp3', 'Jan 10, 2026  •  45.1 MB', false),
  TransferRecord('ShareSync_Backup.zip', 'Jan 08, 2026  •  120.5 MB', true),
];