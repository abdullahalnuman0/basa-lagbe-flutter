import 'package:flutter/material.dart';

import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../ui/theme/theme.dart';

/// Text field with a suggestion popup anchored underneath it.
///
/// The popup lives in an overlay, so typing keeps the focus in the field.
class CustomDropdownMenu extends StatefulWidget {
  const CustomDropdownMenu({
    super.key,
    this.label,
    this.subLabel,
    required this.value,
    this.error,
    required this.placeholder,
    required this.icon,
    required this.isExpanded,
    required this.values,
    this.readOnly = false,
    this.isEnable = true,
    this.onValueChange,
    required this.onItemSelected,
    required this.onExpandedChange,
    required this.onDismissRequest,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  final String? label;
  final String? subLabel;
  final String value;
  final String? error;
  final String placeholder;
  final Widget icon;
  final bool isExpanded;
  final List<String> values;
  final bool readOnly;
  final bool isEnable;
  final ValueChanged<String>? onValueChange;
  final ValueChanged<String> onItemSelected;
  final ValueChanged<bool> onExpandedChange;
  final VoidCallback onDismissRequest;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  final _tapGroup = Object();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.label != null)
              Text(
                widget.label!,
                style: typos.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.value.isNotEmpty || widget.isEnable
                      ? colors.onSurface
                      : colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            if (widget.value.isEmpty && widget.subLabel != null)
              Text(
                widget.subLabel!,
                style: typos.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) => CompositedTransformTarget(
            link: _link,
            child: OverlayPortal(
              controller: _portal,
              overlayChildBuilder: (_) => _buildPopup(constraints.maxWidth),
              child: TapRegion(
                groupId: _tapGroup,
                child: AuthInputTextField(
                  value: widget.value,
                  error: widget.error,
                  onValueChange: widget.onValueChange ?? (_) {},
                  placeholder: widget.placeholder,
                  icon: widget.icon,
                  readOnly: widget.readOnly,
                  isDropDown: widget.readOnly && widget.isEnable,
                  dropDownState: widget.isExpanded,
                  isEnable: widget.isEnable,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onTap: () => widget.onExpandedChange(!widget.isExpanded),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopup(double width) {
    if (!widget.isExpanded) return const SizedBox.shrink();

    final colors = context.colors;
    final typos = context.typos;

    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: Alignment.bottomLeft,
      offset: const Offset(0, 4),
      child: Align(
        alignment: Alignment.topLeft,
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => widget.onDismissRequest(),
          child: SizedBox(
            width: width,
            child: Material(
              color: colors.surface,
              elevation: 3,
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final item in widget.values)
                      InkWell(
                        onTap: () => widget.onItemSelected(item),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            item,
                            style: typos.bodyMedium?.copyWith(
                              fontWeight: widget.value == item
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: widget.value == item ? colors.primary : colors.onSurface,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows [values] in a menu below [child] while [expanded] is true.
class DropdownAnchor extends StatefulWidget {
  const DropdownAnchor({
    super.key,
    required this.expanded,
    required this.values,
    required this.onSelected,
    required this.onDismiss,
    this.selected,
    required this.child,
  });

  final bool expanded;
  final List<String> values;
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<DropdownAnchor> createState() => _DropdownAnchorState();
}

class _DropdownAnchorState extends State<DropdownAnchor> {
  final _controller = MenuController();

  bool get _shouldShow => widget.expanded && widget.values.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant DropdownAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_shouldShow && !_controller.isOpen) {
        _controller.open();
      } else if (!_shouldShow && _controller.isOpen) {
        _controller.close();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: _controller,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.surface),
          minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 0)),
          maximumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 320)),
        ),
        onClose: () {
          if (widget.expanded) widget.onDismiss();
        },
        menuChildren: [
          for (final item in widget.values)
            MenuItemButton(
              onPressed: () => widget.onSelected(item),
              child: Text(
                item,
                style: typos.bodyMedium?.copyWith(
                  fontWeight: item == widget.selected ? FontWeight.bold : FontWeight.normal,
                  color: item == widget.selected ? colors.primary : colors.onSurface,
                ),
              ),
            ),
        ],
        child: widget.child,
      ),
    );
  }
}
