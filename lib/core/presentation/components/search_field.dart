import 'package:flutter/material.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.placeholder = 'Search room number (e.g. 101, 204)...',
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.onClear,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final String value;
  final ValueChanged<String> onValueChange;
  final String placeholder;
  final BorderRadius borderRadius;
  final VoidCallback? onClear;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final focused = _focus.hasFocus;
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: Space.md, right: Space.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: widget.borderRadius,
        border: Border.all(color: focused ? colors.primary : context.appColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search_outlined, size: 20, color: colors.onSurface.withValues(alpha: 0.7)),
          const SizedBox(width: Space.sm),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              onChanged: widget.onValueChange,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              cursorColor: colors.primary,
              maxLines: 1,
              style: context.typos.bodyLarge?.copyWith(
                color: focused ? colors.onSurface : colors.onSurface.withValues(alpha: 0.7),
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: context.typos.labelMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          if (widget.onClear != null && widget.value.isNotEmpty)
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onClear,
                tooltip: 'Clear',
                icon: Icon(
                  Icons.clear_outlined,
                  size: 20,
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
