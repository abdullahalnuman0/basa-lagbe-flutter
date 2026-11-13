import 'package:flutter/material.dart';

import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import '../../property_add_edit/components/facilities_section.dart';

class PropertyFacilities extends StatefulWidget {
  const PropertyFacilities({
    super.key,
    required this.facilities,
    this.facilityLimit = 8,
    this.borderRadius = BorderRadius.zero,
  });

  final List<String> facilities;
  final int facilityLimit;
  final BorderRadius borderRadius;

  @override
  State<PropertyFacilities> createState() => _PropertyFacilitiesState();
}

class _PropertyFacilitiesState extends State<PropertyFacilities> {
  bool _isExpanded = false;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final facilities = widget.facilities;
    final isTruncated = facilities.length > widget.facilityLimit;
    final visible = _isExpanded ? facilities : facilities.take(widget.facilityLimit).toList();

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
              Text('Facilities & Amenities', style: context.typos.titleLarge),
              const SizedBox(height: Space.sm),
              Column(
                spacing: Space.listGap,
                children: [
                  for (var i = 0; i < visible.length; i += 2)
                    Row(
                      spacing: Space.listGap,
                      children: [
                        for (final facility in visible.skip(i).take(2))
                          Expanded(
                            child: FacilityChip(label: facility, icon: facility.toFacilityIcon()),
                          ),
                        if (i + 1 >= visible.length) const Spacer(),
                      ],
                    ),
                ],
              ),
              if (isTruncated) ...[
                const SizedBox(height: Space.sm),
                GestureDetector(
                  onTap: _toggle,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      _isExpanded
                          ? 'Show less'
                          : '+${facilities.length - widget.facilityLimit} more amenities',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
