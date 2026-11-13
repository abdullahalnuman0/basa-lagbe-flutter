import 'package:flutter/material.dart';

import '../../../../core/presentation/components/app_card.dart';
import '../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import '../property_editor_ui_state.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.state,
    required this.onTitleChange,
    required this.onDescChange,
    required this.onPhoneChange,
  });

  final PropertyEditorUiState state;
  final ValueChanged<String> onTitleChange;
  final ValueChanged<String> onDescChange;
  final ValueChanged<String> onPhoneChange;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Space.md),
          PageHeader(
            title: 'Tell us about your place',
            subtitle: 'Start with the basic information should know.',
            titleStyle: context.typos.headlineMedium,
            subtitleStyle: context.typos.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: Space.xxxl),
          AuthInputTextField(
            value: state.contactNumber,
            error: state.contactNumberError,
            onValueChange: onPhoneChange,
            label: 'Contact Number',
            placeholder: '017XXXXXXXX',
            isPhone: true,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: Space.lg),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Space.md),
            child: AppDivider(),
          ),
          const SizedBox(height: Space.lg),
          AuthInputTextField(
            value: state.title,
            error: state.titleError,
            onValueChange: onTitleChange,
            label: 'Listing Title',
            placeholder: 'Use a short and clear name',
            icon: null,
          ),
          const SizedBox(height: Space.lg),
          AuthInputTextField(
            value: state.description,
            onValueChange: onDescChange,
            label: 'Property Description',
            placeholder: 'Highlight special amenities and nearby landmarks',
            wordCount: '${state.description.length} / 500',
            icon: null,
            singleLine: false,
            minLines: 3,
            shape: 20,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }
}
