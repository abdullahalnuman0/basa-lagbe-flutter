import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import 'app_icons.dart';

class AuthInputTextField extends StatefulWidget {
  const AuthInputTextField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.labelAlpha = 1,
    this.label,
    this.placeholder = 'Enter your full name',
    this.error,
    this.wordCount,
    this.icon = const SvgIcon(AppIcons.user),
    this.singleLine = true,
    this.minLines = 1,
    this.maxLines = 4,
    this.shape = 35,
    this.isPassword = false,
    this.isPhone = false,
    this.readOnly = false,
    this.isDropDown = false,
    this.dropDownState = false,
    this.isEnable = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.onTap,
    this.onSubmitted,
  });

  final String value;
  final ValueChanged<String> onValueChange;
  final double labelAlpha;
  final String? label;
  final String placeholder;
  final String? error;
  final String? wordCount;

  /// Leading icon; pass null to drop it.
  final Widget? icon;
  final bool singleLine;
  final int minLines;
  final int maxLines;

  /// Corner radius as a percentage of the field height, like the design spec.
  final int shape;
  final bool isPassword;
  final bool isPhone;
  final bool readOnly;
  final bool isDropDown;
  final bool dropDownState;
  final bool isEnable;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthInputTextField> createState() => _AuthInputTextFieldState();
}

class _AuthInputTextFieldState extends State<AuthInputTextField> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  bool _eyeClosed = true;

  @override
  void didUpdateWidget(covariant AuthInputTextField oldWidget) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final unfocusedColor = colors.onSurface.withValues(alpha: 0.3);
    final radius = BorderRadius.circular(56 * widget.shape / 100);

    Widget? leading;
    if (widget.icon != null) {
      leading = IconTheme.merge(
        data: IconThemeData(color: unfocusedColor, size: 22),
        child: widget.isPhone
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 20, height: 20, child: widget.icon),
                    const SizedBox(width: 6),
                    Text(
                      '+880',
                      style: typos.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: unfocusedColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('|', style: typos.bodyMedium?.copyWith(color: unfocusedColor)),
                  ],
                ),
              )
            : widget.icon!,
      );
    }

    Widget? trailing;
    if (widget.isPassword) {
      trailing = IconButton(
        onPressed: () => setState(() => _eyeClosed = !_eyeClosed),
        tooltip: _eyeClosed ? 'Show password' : 'Hide password',
        icon: _eyeClosed
            ? SvgIcon(AppIcons.eyeClosed, color: unfocusedColor)
            : Icon(Icons.remove_red_eye, color: unfocusedColor),
      );
    } else if (widget.isDropDown) {
      trailing = Icon(
        widget.dropDownState ? Icons.arrow_drop_up : Icons.arrow_drop_down,
        color: unfocusedColor,
      );
    }

    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: typos.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.isEnable
                  ? colors.onSurface.withValues(alpha: widget.labelAlpha)
                  : colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: _controller,
          onChanged: widget.onValueChange,
          onTap: widget.onTap,
          onSubmitted: widget.onSubmitted,
          readOnly: widget.readOnly,
          enabled: widget.isEnable,
          obscureText: widget.isPassword && _eyeClosed,
          keyboardType: widget.singleLine ? widget.keyboardType : TextInputType.multiline,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          minLines: widget.singleLine ? 1 : widget.minLines,
          maxLines: widget.singleLine ? 1 : widget.maxLines,
          style: typos.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: typos.bodyLarge?.copyWith(color: unfocusedColor),
            prefixIcon: leading,
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: trailing,
            errorText: widget.error,
            errorMaxLines: 3,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: border(unfocusedColor),
            disabledBorder: border(unfocusedColor.withValues(alpha: 0.12)),
            focusedBorder: border(colors.primary.withValues(alpha: 0.6), 2),
            errorBorder: border(colors.error),
            focusedErrorBorder: border(colors.error, 2),
          ),
        ),
        if (widget.wordCount != null)
          Padding(
            padding: const EdgeInsets.only(right: Space.sm, top: 4),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                widget.wordCount!,
                textAlign: TextAlign.end,
                style: typos.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
