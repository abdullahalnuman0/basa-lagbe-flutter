import 'package:flutter/material.dart';

import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class InputSection extends StatefulWidget {
  const InputSection({
    super.key,
    required this.uploading,
    required this.sending,
    required this.onMessageSend,
    required this.onSelectImage,
  });

  final bool uploading;
  final bool sending;
  final ValueChanged<String> onMessageSend;
  final VoidCallback onSelectImage;

  @override
  State<InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<InputSection> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    widget.onMessageSend(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final blank = _controller.text.trim().isEmpty;
    final sendBackground = blank ? colors.surfaceContainerHighest : colors.primary;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.all(Space.sm),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Send an image',
            onPressed: widget.uploading ? null : widget.onSelectImage,
            icon: widget.uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.add_photo_alternate, color: colors.primary),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Write a message…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: Space.sm),
            child: IconButton(
              tooltip: 'Send message',
              onPressed: widget.sending || blank ? null : _send,
              style: IconButton.styleFrom(
                fixedSize: const Size(48, 48),
                backgroundColor: sendBackground,
                disabledBackgroundColor: sendBackground,
              ),
              icon: Icon(Icons.send, color: blank ? colors.onSurfaceVariant : colors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
