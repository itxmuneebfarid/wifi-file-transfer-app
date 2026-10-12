import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'sending_screen.dart';

class _Folder {
  final String name;
  final String info;
  final IconData icon;
  const _Folder(this.name, this.info, this.icon);
}

class FileManagerScreen extends StatefulWidget {
  final String deviceName;
  const FileManagerScreen({super.key, required this.deviceName});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  static const _folders = [
    _Folder('Downloads', '120 items • 2.4 GB', Icons.folder_outlined),
    _Folder('Camera & Images', '2,401 items • 8.1 GB', Icons.image_outlined),
    _Folder('Videos', '48 items • 14.2 GB', Icons.videocam_outlined),
    _Folder('Music & Audio', '312 items • 1.1 GB', Icons.music_note_outlined),
    _Folder('Documents', '435 items • 214 MB', Icons.description_outlined),
  ];

  final Set<int> _selected = {0, 2};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Device Storage',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.64,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.lightBlue,
                  ),
                ),
                SizedBox(width: 12),
                Text('46 GB Free',
                    style: TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _folders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final f = _folders[i];
                return CheckboxListTile(
                  tileColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.trailing,
                  value: _selected.contains(i),
                  onChanged: (v) => setState(
                          () => v! ? _selected.add(i) : _selected.remove(i)),
                  secondary: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.lightBlue,
                    child: Icon(f.icon, size: 18, color: AppTheme.primary),
                  ),
                  title: Text(f.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(f.info, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Chip(
                  label: Text('${_selected.length} Folders Selected',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.primary)),
                  backgroundColor: AppTheme.lightBlue,
                  side: BorderSide.none,
                ),
                const Spacer(),
                FloatingActionButton(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SendingScreen(
                            deviceName: widget.deviceName)),
                  ),
                  child: const Icon(Icons.north_east),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}