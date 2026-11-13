import 'package:flutter/material.dart';

import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import '../../../auth/signup/location_data.dart';
import '../property_editor_ui_state.dart';
import '../../../auth/signup/components/custom_dropdown_menu.dart';

const _fallbackAreas = ['Center Area', 'Station Road', 'College Mor', 'Main Road', 'Sadar'];

class LocationSection extends StatefulWidget {
  const LocationSection({
    super.key,
    required this.state,
    required this.onDivisionSelect,
    required this.onDistrictSelect,
    required this.onAreaChange,
    required this.onAddressChange,
    required this.onInstitutionChange,
  });

  final PropertyEditorUiState state;
  final ValueChanged<String> onDivisionSelect;
  final ValueChanged<String> onDistrictSelect;
  final ValueChanged<String> onAreaChange;
  final ValueChanged<String> onAddressChange;
  final ValueChanged<String> onInstitutionChange;

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  bool _institutionExpanded = false;
  bool _areaExpanded = false;

  List<String> get _filteredInstitutes {
    final query = widget.state.institutionNearby;
    final all = LocationData.popularInstitutions;
    if (query.trim().isEmpty) return all.take(5).toList();
    return all.where((it) => it.toLowerCase().contains(query.toLowerCase())).take(5).toList();
  }

  List<String> get _suggestedAreas {
    final district = widget.state.district;
    if (district.isEmpty) return const [];
    return LocationData.popularAreasByDistrict[district] ?? _fallbackAreas;
  }

  List<String> get _availableAreas {
    final area = widget.state.area;
    final suggested = _suggestedAreas;
    if (area.isEmpty || suggested.isEmpty) return const [];
    return suggested.where((it) => it.toLowerCase().contains(area.toLowerCase())).take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final availableAreas = _availableAreas;
    final filteredInstitutes = _filteredInstitutes;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Space.md),
          PageHeader(
            title: 'Tell us about your place',
            subtitle: 'Add the location so tenants can easily find properties near them.',
            titleStyle: context.typos.headlineMedium,
            subtitleStyle: context.typos.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: Space.xxxl),
          Row(
            children: [
              Expanded(
                child: LocationCard(
                  label: 'Division',
                  value: state.division,
                  items: LocationData.divisions,
                  onSelect: widget.onDivisionSelect,
                ),
              ),
              const SizedBox(width: Space.lg),
              Expanded(
                child: LocationCard(
                  label: 'District',
                  value: state.district,
                  items: LocationData.districtByDivision[state.division] ?? const [],
                  onSelect: widget.onDistrictSelect,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.xxl),
          CustomDropdownMenu(
            label: 'Area / Neighborhood',
            value: state.area,
            error: state.areaError,
            placeholder: 'Search or enter your area',
            icon: const Icon(Icons.location_on_outlined),
            isExpanded: _areaExpanded && availableAreas.isNotEmpty,
            values: availableAreas,
            isEnable: state.district.isNotEmpty,
            onValueChange: (value) {
              widget.onAreaChange(value);
              setState(() => _areaExpanded = value.isNotEmpty);
            },
            onItemSelected: (value) {
              widget.onAreaChange(value);
              setState(() => _areaExpanded = false);
            },
            onExpandedChange: (expanded) =>
                setState(() => _areaExpanded = availableAreas.isNotEmpty && expanded),
            onDismissRequest: () => setState(() => _areaExpanded = false),
          ),
          const SizedBox(height: Space.xxl),
          AuthInputTextField(
            value: state.address,
            error: state.addressError,
            onValueChange: widget.onAddressChange,
            label: 'Full Address',
            placeholder: 'House/Road, Area, City, District',
            icon: null,
            singleLine: false,
            minLines: 2,
            maxLines: 2,
            shape: 20,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: Space.xxl),
          CustomDropdownMenu(
            label: 'Nearby Institution',
            subLabel: 'University / College / Workplace',
            value: state.institutionNearby,
            placeholder: 'Enter your institution name',
            icon: const Icon(Icons.school_outlined),
            isExpanded: _institutionExpanded && filteredInstitutes.isNotEmpty,
            values: filteredInstitutes,
            onValueChange: (value) {
              widget.onInstitutionChange(value);
              if (!_institutionExpanded) setState(() => _institutionExpanded = true);
            },
            onItemSelected: (value) {
              widget.onInstitutionChange(value);
              setState(() => _institutionExpanded = false);
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onExpandedChange: (expanded) => setState(() => _institutionExpanded = expanded),
            onDismissRequest: () => setState(() => _institutionExpanded = false),
          ),
        ],
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onSelect,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.surface),
          minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 0)),
          maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 360)),
        ),
        menuChildren: [
          for (final item in items)
            MenuItemButton(
              onPressed: () => onSelect(item),
              child: Text(
                item,
                style: typos.bodyMedium?.copyWith(
                  fontWeight: value == item ? FontWeight.bold : FontWeight.normal,
                  color: value == item ? colors.primary : colors.onSurface,
                ),
              ),
            ),
        ],
        builder: (context, controller, _) => Card(
          margin: EdgeInsets.zero,
          color: colors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colors.onSurface.withValues(alpha: 0.3)),
          ),
          child: InkWell(
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            child: Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: typos.labelMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typos.bodyLarge?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                      Icon(controller.isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                    ],
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
