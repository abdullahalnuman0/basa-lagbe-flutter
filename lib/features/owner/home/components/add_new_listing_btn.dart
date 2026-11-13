import 'package:flutter/material.dart';

import '../../../../core/presentation/components/section_card.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';

class AddNewListingBtn extends StatelessWidget {
  const AddNewListingBtn({super.key, required this.onClick});

  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return SectionCard(
      onClick: onClick,
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: colors.primary,
                  semanticLabel: 'Add new listing',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        'Add New Listing',
                        style: typos.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Post a new hostel or mess',
                        style: typos.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_ios, size: 14, color: colors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
