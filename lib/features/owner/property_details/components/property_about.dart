import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class PropertyAbout extends StatefulWidget {
  const PropertyAbout({
    super.key,
    required this.desc,
    this.charLimit = 180,
    this.borderRadius = BorderRadius.zero,
  });

  final String desc;
  final int charLimit;
  final BorderRadius borderRadius;

  @override
  State<PropertyAbout> createState() => _PropertyAboutState();
}

class _PropertyAboutState extends State<PropertyAbout> {
  bool _isExpanded = false;
  late final _readMore = TapGestureRecognizer()..onTap = _toggle;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  void dispose() {
    _readMore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final desc = widget.desc;
    final isTruncated = desc.length > widget.charLimit;
    final text = _isExpanded || !isTruncated ? desc : '${desc.substring(0, widget.charLimit)}...';

    return Material(
      color: colors.surface,
      elevation: 1,
      borderRadius: widget.borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.all(Space.screen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About this Property', style: context.typos.titleLarge),
              const SizedBox(height: Space.sm),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: text,
                          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
                        ),
                        // only offer the toggle when the text actually needs expanding
                        if (isTruncated) ...[
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: _isExpanded ? 'Read less' : 'Read more',
                            recognizer: _readMore,
                            style: TextStyle(color: colors.primary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                    style: context.typos.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
