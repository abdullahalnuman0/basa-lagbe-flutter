import 'package:flutter/material.dart';

import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/components/messages.dart';
import '../../../../core/presentation/components/snackbar.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import '../property_editor_ui_state.dart';
import '../../../auth/signup/components/dashed_border.dart';

class Facility {
  const Facility(this.label, this.icon);

  final String label;
  final IconData icon;
}

const facilityList = [
  Facility('Wi-Fi', Icons.wifi),
  Facility('Parking', Icons.local_parking),
  Facility('Electricity', Icons.bolt),
  Facility('Water Supply', Icons.water_drop),
  Facility('Gas', Icons.local_fire_department),
  Facility('Air Conditioning', Icons.ac_unit),
  Facility('Heating', Icons.thermostat),
  Facility('Furnished', Icons.chair),
  Facility('Kitchen', Icons.kitchen),
  Facility('Attached Bathroom', Icons.bathtub),
  Facility('Balcony', Icons.balcony),
  Facility('Lift / Elevator', Icons.elevator),
  Facility('Security', Icons.security),
  Facility('CCTV', Icons.videocam),
  Facility('Generator', Icons.power),
  Facility('Laundry', Icons.local_laundry_service),
  Facility('Dining Area', Icons.table_restaurant),
  Facility('Common Room', Icons.groups),
  Facility('Rooftop', Icons.roofing),
  Facility('Garden', Icons.yard),
  Facility('Gym', Icons.fitness_center),
  Facility('Swimming Pool', Icons.pool),
  Facility('Study Room', Icons.menu_book),
  Facility('Storage', Icons.storage),
  Facility('24/7 Water Supply', Icons.water_drop),
];

final _facilityIcons = {
  for (final facility in facilityList) facility.label.trim().toLowerCase(): facility.icon,
};

extension FacilityIconX on String {
  IconData toFacilityIcon() => _facilityIcons[toLowerCase()] ?? Icons.help_outline;
}

class FacilitiesSection extends StatefulWidget {
  const FacilitiesSection({
    super.key,
    required this.state,
    required this.onAdd,
    required this.onRemove,
    required this.onAllRemove,
  });

  final PropertyEditorUiState state;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final VoidCallback onAllRemove;

  @override
  State<FacilitiesSection> createState() => _FacilitiesSectionState();
}

class _FacilitiesSectionState extends State<FacilitiesSection> {
  final _facilities = [...facilityList];

  Future<void> _showAddDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _AddCustomFacilityDialog(existingFacilities: _facilities),
    );
    if (name == null || !mounted) return;

    if (widget.state.facilities.contains(name)) {
      AppSnackbar.show('This facility already exists.');
    } else {
      setState(() => _facilities.add(Facility(name, Icons.add_circle)));
      widget.onAdd(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final selected = widget.state.facilities;
    final hasSelection = selected.isNotEmpty;

    // selected facilities float to the top, keeping their original order
    final sorted = [
      ..._facilities.where((it) => selected.contains(it.label)),
      ..._facilities.where((it) => !selected.contains(it.label)),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Space.md),
          PageHeader(
            title: 'Available facilities',
            subtitle: 'Select everything your place provides for tenants.',
            titleStyle: typos.headlineMedium,
            subtitleStyle: typos.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: Space.xxxl),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: widget.state.facilitiesError == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: Space.xl),
                    child: ErrorBoxMessage(error: widget.state.facilitiesError),
                  ),
          ),
          Row(
            children: [
              Material(
                color: colors.tertiary,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: hasSelection ? widget.onAllRemove : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasSelection ? Icons.check : Icons.radio_button_unchecked,
                          size: 14,
                          color: colors.onTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ' ${hasSelection ? selected.length : 'No'} facilities selected',
                          style: typos.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Space.md),
              AnimatedOpacity(
                opacity: hasSelection ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  'Tap to toggle',
                  style: typos.labelSmall?.copyWith(fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.xl),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in sorted)
                FacilityChip(
                  key: ValueKey(item.label),
                  label: item.label,
                  icon: item.icon,
                  isSelected: selected.contains(item.label),
                  onClick: () => selected.contains(item.label)
                      ? widget.onRemove(item.label)
                      : widget.onAdd(item.label),
                ),
            ],
          ),
          const SizedBox(height: Space.xl),
          DashedBorder(
            color: colors.outline,
            child: OutlinedButton(
              onPressed: _showAddDialog,
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: colors.primary, semanticLabel: 'add'),
                    const SizedBox(width: Space.md),
                    Text('Add custom facility', style: TextStyle(color: colors.primary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.xxxl),
        ],
      ),
    );
  }
}

class _AddCustomFacilityDialog extends StatefulWidget {
  const _AddCustomFacilityDialog({required this.existingFacilities});

  final List<Facility> existingFacilities;

  @override
  State<_AddCustomFacilityDialog> createState() => _AddCustomFacilityDialogState();
}

class _AddCustomFacilityDialogState extends State<_AddCustomFacilityDialog> {
  String _name = '';

  @override
  Widget build(BuildContext context) {
    final trimmed = _name.trim();
    final alreadyExists = widget.existingFacilities.any(
      (it) => it.label.toLowerCase() == trimmed.toLowerCase(),
    );
    final isValid = trimmed.isNotEmpty && !alreadyExists;

    return AlertDialog(
      backgroundColor: context.colors.surface,
      title: const Text('Add custom facility'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add a facility that isn\'t listed above.', style: context.typos.bodyMedium),
          const SizedBox(height: 12),
          AuthInputTextField(
            value: _name,
            error: alreadyExists ? 'This facility already exists.' : null,
            onValueChange: (value) => setState(() => _name = value),
            placeholder: 'e.g. Rooftop',
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: isValid ? () => Navigator.of(context).pop(trimmed) : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class FacilityChip extends StatelessWidget {
  const FacilityChip({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onClick,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const duration = Duration(milliseconds: 250);
    final radius = BorderRadius.circular(10);

    return AnimatedScale(
      scale: isSelected ? 1.04 : 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer : colors.surface,
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onClick,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    semanticLabel: label,
                    color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      style: context.typos.labelSmall!.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? colors.primary : colors.onSurface,
                      ),
                      child: Text(label),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
