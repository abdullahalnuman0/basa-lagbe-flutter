import 'package:flutter/material.dart';

import '../../../../core/presentation/components/messages.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../domain/enums/property_gender.dart';
import '../../../../domain/enums/property_type.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import '../property_editor_ui_state.dart';

class PropertyDetailsSection extends StatelessWidget {
  const PropertyDetailsSection({
    super.key,
    required this.state,
    required this.onTypeSelect,
    required this.onGenderSelect,
  });

  final PropertyEditorUiState state;
  final ValueChanged<PropertyType> onTypeSelect;
  final ValueChanged<PropertyGender> onGenderSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Space.md),
          PageHeader(
            title: 'Property details',
            subtitle: 'Provide some details about the type and preferred gender.',
            titleStyle: context.typos.headlineMedium,
            subtitleStyle: context.typos.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: Space.xxxl),
          if (state.propertyDetailsError != null) ...[
            ErrorBoxMessage(error: state.propertyDetailsError),
            const SizedBox(height: Space.xxxl),
          ],
          const _PartLabel(label: 'Property Type', info: 'Required'),
          const SizedBox(height: Space.md),
          _Grid(
            columns: 2,
            children: [
              for (final item in PropertyType.values)
                _SelectedCard(
                  label: item.title,
                  icon: item.icon,
                  isSelected: state.type == item,
                  onClick: () => onTypeSelect(item),
                ),
            ],
          ),
          const SizedBox(height: Space.xxl),
          const _PartLabel(label: 'Suitable For', info: 'Target Occupants'),
          const SizedBox(height: Space.md),
          _Grid(
            columns: 3,
            children: [
              for (final item in PropertyGender.values)
                _SelectedCard(
                  label: item.title,
                  icon: item.icon,
                  circle: true,
                  isSelected: state.gender == item,
                  onClick: () => onGenderSelect(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final rowItems = children.skip(i).take(columns).toList();
      if (rows.isNotEmpty) rows.add(const SizedBox(height: Space.listGap));
      rows.add(
        Row(
          children: [
            for (var j = 0; j < rowItems.length; j++) ...[
              if (j > 0) const SizedBox(width: Space.listGap),
              Expanded(child: rowItems[j]),
            ],
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _PartLabel extends StatelessWidget {
  const _PartLabel({required this.label, required this.info});

  final String label;
  final String info;

  @override
  Widget build(BuildContext context) {
    final typos = context.typos;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label, style: typos.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ),
        Text(
          info,
          style: typos.bodySmall?.copyWith(
            color: DefaultTextStyle.of(context).style.color?.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SelectedCard extends StatelessWidget {
  const _SelectedCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onClick,
    this.circle = false,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool circle;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? BorderSide(color: colors.primary) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Space.xxl),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.secondary,
                  shape: circle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: circle ? null : BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  semanticLabel: label,
                  color: isSelected ? colors.onPrimary : colors.onSecondary,
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                label,
                style: context.typos.labelLarge?.copyWith(
                  color: isSelected ? colors.primary : colors.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
