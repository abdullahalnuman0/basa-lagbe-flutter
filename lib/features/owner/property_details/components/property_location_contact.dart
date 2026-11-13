import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/components/snackbar.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class PropertyLocationContact extends StatelessWidget {
  const PropertyLocationContact({
    super.key,
    required this.address,
    required this.institution,
    required this.phone,
  });

  final String address;
  final String institution;
  final String phone;

  Future<void> _copyPhone() async {
    await Clipboard.setData(ClipboardData(text: phone));
    AppSnackbar.show('Phone number copied');
  }

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;

    return Material(
      color: context.colors.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(Space.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About this Property', style: typos.titleLarge),
            const SizedBox(height: Space.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.sm,
              children: [
                const Opacity(
                  opacity: 0.7,
                  child: Icon(Icons.location_on_outlined, semanticLabel: 'Address'),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: typos.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (institution.isNotEmpty) ...[
                        const SizedBox(height: Space.xs),
                        Opacity(
                          opacity: 0.7,
                          child: Text('Nearby: $institution', style: typos.labelSmall),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.sm),
            _PhoneCard(phone: phone, onCopy: _copyPhone),
          ],
        ),
      ),
    );
  }
}

class _PhoneCard extends StatelessWidget {
  const _PhoneCard({required this.phone, this.onCopy});

  static const label = 'Manager / Owner Contact';

  final String phone;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: Space.md,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
            child: Icon(
              Icons.call_outlined,
              color: context.appColors.background,
              semanticLabel: 'Call',
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typos.labelMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(phone, style: typos.titleMedium),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              tooltip: 'Copy',
              icon: const Icon(Icons.content_copy_outlined, size: 20),
            ),
        ],
      ),
    );
  }
}
