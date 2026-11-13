import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/components/messages.dart';
import '../../../../core/presentation/components/section_card.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../domain/enums/gender.dart';
import '../../../../ui/theme/theme.dart';
import '../location_data.dart';
import '../signup_ui_state.dart';
import 'custom_dropdown_menu.dart';

const _quickSuggestions = {
  'DU': 'University of Dhaka (DU)',
  'BUET': 'Bangladesh University of Engineering and Technology (BUET)',
  'NSU': 'North South University (NSU)',
  'BRAC University': 'BRAC University',
  'AIUB': 'American International University-Bangladesh (AIUB)',
  'Job / Corporate': 'Working Professional / Corporate',
};

class AboutYouSection extends StatefulWidget {
  const AboutYouSection({
    super.key,
    required this.state,
    required this.onGenderSelected,
    required this.onInstitutionChange,
    required this.onInstitutionNotListedToggle,
  });

  final SignupUiState state;
  final ValueChanged<Gender> onGenderSelected;
  final ValueChanged<String> onInstitutionChange;
  final ValueChanged<bool> onInstitutionNotListedToggle;

  @override
  State<AboutYouSection> createState() => _AboutYouSectionState();
}

class _AboutYouSectionState extends State<AboutYouSection> {
  bool _isExpanded = false;

  List<String> get _filteredInstitutes {
    final query = widget.state.institution;
    final all = LocationData.popularInstitutions;
    final matches = query.trim().isEmpty
        ? all
        : all.where((i) => i.toLowerCase().contains(query.toLowerCase()));
    return matches.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colors = context.colors;
    final typos = context.typos;
    final custom = state.isCustomInstitution;
    final toggleColor = custom ? colors.primary : colors.tertiary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const PageHeader(
            title: 'Tell us about you',
            subtitle: 'This helps us provide a more relevant experience.',
          ),
          const SizedBox(height: 24),

          // --- gender ---
          Text('Gender', style: typos.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            spacing: 16,
            children: [
              for (final gender in Gender.values)
                Expanded(
                  child: _GenderSelectableCard(
                    gender: gender,
                    isSelected: state.gender == gender,
                    onClick: () => widget.onGenderSelected(gender),
                  ),
                ),
            ],
          ),
          InlineMessage(message: state.genderError, isError: true),
          const SizedBox(height: 24),

          // --- institute ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Institute', style: typos.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Opacity(
                opacity: 0.5,
                child: Text('University / College / Workplace', style: typos.labelSmall),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownAnchor(
            expanded: _isExpanded && !custom,
            values: _filteredInstitutes,
            onSelected: (inst) {
              widget.onInstitutionChange(inst);
              setState(() => _isExpanded = false);
              FocusScope.of(context).unfocus();
            },
            onDismiss: () => setState(() => _isExpanded = false),
            child: AuthInputTextField(
              value: state.institution,
              error: state.institutionError,
              onValueChange: (value) {
                widget.onInstitutionChange(value);
                if (!_isExpanded) setState(() => _isExpanded = true);
              },
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              placeholder: custom ? 'Enter your institution name' : 'Search your institution...',
              icon: Icon(custom ? Icons.apartment_outlined : Icons.school_outlined),
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: toggleColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => widget.onInstitutionNotListedToggle(!custom),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      custom ? Icons.check : Icons.radio_button_unchecked_outlined,
                      size: 14,
                      color: toggleColor,
                      semanticLabel: "institution isn't listed",
                    ),
                    const SizedBox(width: 8),
                    Text(
                      custom ? 'Institution name' : "My institution isn't listed",
                      style: typos.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: toggleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- quick select chips ---
          Opacity(
            opacity: 0.5,
            child: Text(
              'Popular Suggestions:',
              style: typos.labelSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final MapEntry(key: tag, value: fullTag) in _quickSuggestions.entries)
                _SuggestionChip(
                  label: tag,
                  isSelected: state.institution.toLowerCase().contains(tag.toLowerCase()),
                  onClick: () {
                    widget.onInstitutionChange(fullTag);
                    widget.onInstitutionNotListedToggle(false);
                    setState(() => _isExpanded = false);
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.isSelected, required this.onClick});

  final String label;
  final bool isSelected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: isSelected ? colors.primaryContainer : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: context.typos.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? colors.primary : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderSelectableCard extends StatelessWidget {
  const _GenderSelectableCard({
    required this.gender,
    required this.isSelected,
    required this.onClick,
  });

  final Gender gender;
  final bool isSelected;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: isSelected ? 1 : 0),
      duration: const Duration(milliseconds: 200),
      builder: (context, t, child) => SectionCard(
        contentPadding: EdgeInsets.zero,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        border: BorderSide(
          width: lerpDouble(1, 2, t)!,
          color: Color.lerp(context.appColors.cardBorder, colors.primary, t)!,
        ),
        onClick: onClick,
        children: [child!],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.5),
              ),
              child: Icon(
                gender.icon,
                size: 20,
                semanticLabel: gender.label,
                color: colors.onSurface.withValues(alpha: isSelected ? 1 : 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gender.label,
              style: context.typos.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? colors.primary : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
