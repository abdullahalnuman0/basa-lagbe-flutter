import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../ui/theme/theme.dart';
import '../location_data.dart';
import '../signup_ui_state.dart';
import 'custom_dropdown_menu.dart';

const _fallbackAreas = ['Center Area', 'Station Road', 'College Mor', 'Main Road', 'Sadar'];

class LocationSection extends StatefulWidget {
  const LocationSection({
    super.key,
    required this.state,
    required this.onDivisionSelected,
    required this.onDistrictSelected,
    required this.onAreaSelected,
  });

  final SignupUiState state;
  final ValueChanged<String> onDivisionSelected;
  final ValueChanged<String> onDistrictSelected;
  final ValueChanged<String> onAreaSelected;

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  bool _divisionExpanded = false;
  bool _districtExpanded = false;
  bool _areaExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colors = context.colors;

    final availableDistricts = state.division.isNotEmpty
        ? LocationData.districtByDivision[state.division] ?? const <String>[]
        : const <String>[];

    final suggestedAreas = state.district.isNotEmpty
        ? LocationData.popularAreasByDistrict[state.district] ?? _fallbackAreas
        : const <String>[];

    final availableArea = state.area.isNotEmpty && suggestedAreas.isNotEmpty
        ? suggestedAreas.take(5).toList()
        : const <String>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const PageHeader(
            title: 'Where are you located?',
            subtitle: 'Choose your location to discover relevant homes and messes.',
          ),
          const SizedBox(height: 24),
          CustomDropdownMenu(
            label: 'Division',
            value: state.division,
            error: state.divisionError,
            placeholder: 'Select division',
            icon: const Icon(Icons.map_outlined),
            isExpanded: _divisionExpanded,
            values: LocationData.divisions,
            readOnly: true,
            onItemSelected: (value) {
              widget.onDivisionSelected(value);
              setState(() => _divisionExpanded = false);
            },
            onExpandedChange: (value) => setState(() => _divisionExpanded = value),
            onDismissRequest: () => setState(() => _divisionExpanded = false),
          ),
          const SizedBox(height: 16),
          CustomDropdownMenu(
            label: 'District',
            subLabel: 'Select division first',
            value: state.district,
            error: state.districtError,
            placeholder: state.division.trim().isEmpty
                ? 'Select division first'
                : 'Select district',
            icon: const Icon(Icons.location_city_outlined),
            isExpanded: _districtExpanded,
            values: availableDistricts,
            readOnly: true,
            isEnable: state.division.isNotEmpty,
            onItemSelected: (value) {
              widget.onDistrictSelected(value);
              setState(() => _districtExpanded = false);
            },
            onExpandedChange: (value) {
              if (state.division.isNotEmpty) setState(() => _districtExpanded = value);
            },
            onDismissRequest: () => setState(() => _districtExpanded = false),
          ),
          const SizedBox(height: 16),
          CustomDropdownMenu(
            label: 'Area / Thana / Neighborhood',
            value: state.area,
            error: state.areaError,
            placeholder: 'Search or enter your area',
            icon: const Icon(Icons.location_on_outlined),
            isExpanded: _areaExpanded && availableArea.isNotEmpty,
            values: availableArea,
            onValueChange: (value) {
              widget.onAreaSelected(value);
              setState(() => _areaExpanded = true);
            },
            isEnable: state.district.isNotEmpty,
            onItemSelected: (value) {
              widget.onAreaSelected(value);
              setState(() => _areaExpanded = false);
              FocusScope.of(context).unfocus();
            },
            onExpandedChange: (value) {
              if (state.district.isNotEmpty) setState(() => _areaExpanded = value);
            },
            onDismissRequest: () => setState(() => _areaExpanded = false),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),

          // --- popular area chips for quick select ---
          if (state.district.isNotEmpty) ...[
            Text(
              'Popular areas in ${state.district}:',
              style: context.typos.labelSmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final areaName in suggestedAreas)
                  _AreaChip(
                    label: areaName,
                    isSelected: state.area.toLowerCase() == areaName.toLowerCase(),
                    onClick: () {
                      widget.onAreaSelected(areaName);
                      setState(() => _areaExpanded = false);
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({required this.label, required this.isSelected, required this.onClick});

  final String label;
  final bool isSelected;
  final VoidCallback onClick;

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
          ),
        ),
      ),
    );
  }
}
