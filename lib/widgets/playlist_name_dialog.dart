import 'package:flutter/material.dart';

Future<String?> showPlaylistNameDialog(
  BuildContext context, {
  String? initialName,
}) => showDialog<String>(
  context: context,
  builder: (_) => _PlaylistNameDialog(initialName: initialName),
);

class _PlaylistNameDialog extends StatefulWidget {
  const _PlaylistNameDialog({this.initialName});
  final String? initialName;
  @override
  State<_PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<_PlaylistNameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.initialName == null ? 'New Playlist' : 'Rename Playlist',
    ),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 80,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(labelText: 'Playlist name'),
      onChanged: (_) => setState(() {}),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: _controller.text.trim().isEmpty ? null : _submit,
        child: Text(widget.initialName == null ? 'Create' : 'Save'),
      ),
    ],
  );
}
