import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/messages.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/components/step_animated_content.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/step_bottom_action_bar.dart';
import '../../../core/presentation/widgets/step_progress_indicator.dart';
import '../../../data/dto/property/property_dtos.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import 'components/basic_info_section.dart';
import 'components/facilities_section.dart';
import 'components/location_section.dart';
import 'components/property_details_section.dart';
import 'property_editor_view_model.dart';
import 'property_step.dart';
import 'room_section/room_editor_section.dart';
import 'room_section/room_editor_view_model.dart';

class PropertyEditorScreen extends StatelessWidget {
  const PropertyEditorScreen({super.key, this.updateProperty});

  final PropertyResponse? updateProperty;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              PropertyEditorViewModel(locator(), locator())..initiateEditorState(updateProperty),
        ),
        ChangeNotifierProvider(create: (_) => RoomEditorViewModel(locator())),
      ],
      child: const _PropertyEditorView(),
    );
  }
}

class _PropertyEditorView extends StatelessWidget {
  const _PropertyEditorView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PropertyEditorViewModel>();
    final state = vm.state;
    final isFirstStep = state.currentStep == PropertyStep.propertyDetails;

    void onBack() {
      if (isFirstStep) {
        context.pop();
      } else {
        vm.onGoBack();
      }
    }

    void onClose() {
      if (state.type == null && state.gender == null) {
        context.pop();
        return;
      }
      final isNew = state.property == null;
      showDeleteConfirmationDialog(
        context,
        title: isNew ? 'Discard this listing?' : 'Discard your changes?',
        subtitle: isNew
            ? 'Your listing hasn’t been saved yet. Are you sure you want to leave?'
            : 'Your changes haven’t been saved. Are you sure you want to leave?',
        confirmBtn: 'Yes',
        onConfirm: () => context.pop(),
      );
    }

    return PopScope(
      canPop: isFirstStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) vm.onGoBack();
      },
      child: Scaffold(
        backgroundColor: context.appColors.background,
        body: Column(
          children: [
            AppTopBar(
              title: state.property != null ? 'Edit Listing' : 'Create Listing',
              onBack: onBack,
              actions: [
                IconButton(onPressed: onClose, tooltip: 'Close', icon: const Icon(Icons.close)),
              ],
              content: Padding(
                padding: const EdgeInsets.fromLTRB(Space.xl, 0, Space.xl, Space.md),
                child: StepProgressIndicator(
                  currentStep: state.currentStep,
                  steps: state.progressSteps,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm, horizontal: Space.lg),
                child: StepAnimatedContent(
                  targetState: state.currentStep,
                  forward: state.isNavigatingForward,
                  builder: (context, step) => switch (step) {
                    PropertyStep.propertyDetails => PropertyDetailsSection(
                      state: state,
                      onTypeSelect: vm.onTypeSelect,
                      onGenderSelect: vm.onGenderSelect,
                    ),
                    PropertyStep.basicInfo => BasicInfoSection(
                      state: state,
                      onTitleChange: vm.onTitleChange,
                      onDescChange: vm.onDescChange,
                      onPhoneChange: vm.onPhoneChange,
                    ),
                    PropertyStep.location => LocationSection(
                      state: state,
                      onDivisionSelect: vm.onDivisionSelect,
                      onDistrictSelect: vm.onDistrictSelect,
                      onAreaChange: vm.onAreaChange,
                      onAddressChange: vm.onAddressChange,
                      onInstitutionChange: vm.onInstitutionChange,
                    ),
                    PropertyStep.facilities => FacilitiesSection(
                      state: state,
                      onAdd: vm.onAddFacilities,
                      onRemove: vm.onRemoveFacilities,
                      onAllRemove: vm.onAllFacilitiesRemove,
                    ),
                    PropertyStep.rooms => RoomEditorSection(
                      state: state,
                      onAddRoom: vm.onAddRoom,
                      onRemoveRoom: vm.onRemoveRoom,
                      onUpdateRoom: vm.onUpdate,
                    ),
                  },
                ),
              ),
            ),
            StepBottomActionBar(
              primaryBtnText: state.currentStep == state.lastStep
                  ? (state.property == null ? 'Create property' : 'Update property')
                  : 'Continue',
              isLoading: state.isLoading,
              showBackButton: !isFirstStep,
              onPrimaryBtnClick: () => vm.onGoNext(
                onSuccess: (id) {
                  if (context.mounted) context.pushReplacement(Routes.propertyDetails(id));
                },
                onError: (msg) => AppSnackbar.show(
                  msg,
                  withDismissAction: true,
                  duration: const Duration(days: 1),
                ),
              ),
              onBackClick: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
