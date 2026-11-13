import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/presentation/components/auth_input_text_field.dart';
import '../../../../../core/presentation/components/messages.dart';
import '../../../../../core/presentation/components/room_image.dart';
import '../../../../../core/utils/app_properties.dart';
import '../../../../../data/enums/enums.dart';
import '../../../../../domain/model/room.dart';
import '../../../../../ui/theme/space.dart';
import '../../../../../ui/theme/theme.dart';
import '../room_editor_ui_state.dart';
import '../room_editor_view_model.dart';

/// Opens the room form for [vm]. The form is reset once the sheet closes; photos uploaded
/// during a cancelled session are removed from the server.
Future<void> showAddRoomBottomSheet(
  BuildContext context, {
  required RoomEditorViewModel vm,
  bool isEdit = false,
  required ValueChanged<Room> onSave,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: context.colors.surface,
    builder: (_) => AddRoomBottomSheet(vm: vm, isEdit: isEdit, onSave: onSave),
  );
  vm.closeInitial(saved != true);
}

class AddRoomBottomSheet extends StatelessWidget {
  const AddRoomBottomSheet({
    super.key,
    required this.vm,
    this.isEdit = false,
    required this.onSave,
  });

  final RoomEditorViewModel vm;
  final bool isEdit;
  final ValueChanged<Room> onSave;

  static const _labelAlpha = 0.7;

  Future<void> _pickImages() async {
    final List<XFile> files;
    try {
      files = await ImagePicker().pickMultiImage(limit: AppProperties.propertyMaxFile);
    } catch (_) {
      return;
    }
    if (files.isNotEmpty) vm.onUploadImages(files);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => _buildContent(context, vm.state),
      ),
    );
  }

  Widget _buildContent(BuildContext context, RoomEditorUiState state) {
    final colors = context.colors;
    final typos = context.typos;
    final busy = state.isBusy;

    void dismiss() => Navigator.of(context).pop(false);

    void save() => vm.onAddRoom((room) {
      onSave(room);
      Navigator.of(context).pop(true);
    });

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- drag handle & close ---
          SizedBox(
            height: 56,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 22),
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  top: Space.xs,
                  right: Space.xs,
                  child: IconButton(
                    onPressed: busy ? null : dismiss,
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Edit room' : 'Add new room',
                    style: typos.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Provide all necessary information about the room.',
                    style: typos.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: Space.xl),

                  // --- room number ---
                  AuthInputTextField(
                    value: state.roomNumber,
                    error: state.roomNumberError,
                    onValueChange: vm.onRoomNumberChange,
                    label: 'Room number *',
                    labelAlpha: _labelAlpha,
                    placeholder: 'e.g. Room-102',
                    icon: const Icon(Icons.meeting_room),
                  ),
                  const SizedBox(height: Space.lg),

                  // --- room type & seat count ---
                  _FieldRow(
                    first: _RoomTypeDropdown(
                      selected: state.type,
                      error: state.typeError,
                      onSelected: vm.onTypeSelected,
                    ),
                    second: AuthInputTextField(
                      value: state.availableSeats,
                      error: state.availableSeatsError,
                      onValueChange: vm.onSeatChange,
                      label: 'Available seats *',
                      labelAlpha: _labelAlpha,
                      placeholder: 'e.g. 2',
                      icon: const Icon(Icons.event_seat),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: Space.lg),

                  // --- rent & deposit ---
                  _FieldRow(
                    first: AuthInputTextField(
                      value: state.rent,
                      error: state.rentError,
                      onValueChange: vm.onRentChange,
                      label: 'Monthly rent *',
                      labelAlpha: _labelAlpha,
                      placeholder: 'e.g. 1000৳',
                      icon: const Icon(Icons.payments),
                      keyboardType: TextInputType.number,
                    ),
                    second: AuthInputTextField(
                      value: state.deposit,
                      onValueChange: vm.onDepositChange,
                      label: 'Deposit',
                      labelAlpha: _labelAlpha,
                      placeholder: 'e.g. 500৳',
                      icon: const Icon(Icons.account_balance_wallet),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: Space.lg),

                  // --- width & height ---
                  _FieldRow(
                    first: AuthInputTextField(
                      value: state.roomWidth,
                      error: state.roomWidthError,
                      onValueChange: vm.onWidthChange,
                      label: 'Room width (ft)*',
                      labelAlpha: _labelAlpha,
                      placeholder: 'e.g. 3',
                      icon: const Icon(Icons.straighten),
                      keyboardType: TextInputType.number,
                    ),
                    second: AuthInputTextField(
                      value: state.roomHeight,
                      error: state.roomHeightError,
                      onValueChange: vm.onHeightChange,
                      label: 'Room height (ft)*',
                      labelAlpha: _labelAlpha,
                      placeholder: 'e.g. 5',
                      icon: const Icon(Icons.height),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(height: Space.lg),

                  _ImagePickerSection(
                    images: state.images,
                    error: state.imageError,
                    isLoading: state.isLoading,
                    onAddClick: _pickImages,
                    onRemove: vm.onRemoveImage,
                    onRetry: vm.onRetry,
                  ),
                  const SizedBox(height: 24),

                  // --- cancel & save ---
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: busy ? null : dismiss,
                            style: TextButton.styleFrom(
                              foregroundColor: colors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ),
                      const SizedBox(width: Space.md),
                      Expanded(
                        flex: 7,
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: busy ? null : save,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.check),
                            label: Text(
                              isEdit ? 'Update room' : 'Save room',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: Space.md),
        Expanded(child: second),
      ],
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({
    required this.images,
    required this.error,
    required this.isLoading,
    required this.onAddClick,
    required this.onRemove,
    required this.onRetry,
  });

  final List<ImageStash> images;
  final String? error;
  final bool isLoading;
  final VoidCallback onAddClick;
  final ValueChanged<ImageStash> onRemove;
  final void Function(int index, ImageStash stash) onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;
    final canAdd = images.length < AppProperties.propertyMaxFile;
    final uploaded = images.where((it) => it.error == null && it.fileKey != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Room photos *', style: typos.labelLarge?.copyWith(fontWeight: FontWeight.w500)),
        if (error != null) ...[
          const SizedBox(height: Space.xs),
          Text(
            error!,
            style: typos.labelSmall?.copyWith(fontWeight: FontWeight.w500, color: colors.error),
          ),
        ],
        const SizedBox(height: Space.sm),
        SizedBox(
          height: 90,
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colors.outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: canAdd && !isLoading ? onAddClick : null,
                  child: SizedBox.square(
                    dimension: 90,
                    child: Icon(
                      canAdd ? Icons.add_to_photos : Icons.done_all,
                      semanticLabel: 'Add photo',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Space.md),
                  itemBuilder: (context, index) => _ImageTile(
                    stash: images[index],
                    onRetry: () => onRetry(index, images[index]),
                    onRemove: () => onRemove(images[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.xs),
        InlineMessage(
          message: '$uploaded / 5 photos ` max ${AppProperties.maxFileUploadSize} MB each',
        ),
        const SizedBox(height: Space.xs),
        for (var i = 0; i < images.length; i++)
          if (images[i].error != null) ...[
            Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: InlineMessage(message: '${i + 1}) ${images[i].error}', isError: true),
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
          ],
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.stash, required this.onRetry, required this.onRemove});

  final ImageStash stash;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final file = stash.file;

    final Widget preview = stash.fileKey != null || file == null
        ? RoomImage(fileKey: stash.fileKey)
        : Opacity(opacity: 0.5, child: Image.file(File(file.path), fit: BoxFit.cover));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 120,
        height: 90,
        child: Stack(
          fit: StackFit.expand,
          children: [
            preview,
            if (stash.isUploading)
              const Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (stash.error != null)
              Center(
                child: IconButton.filled(
                  onPressed: onRetry,
                  tooltip: 'Retry upload',
                  style: IconButton.styleFrom(
                    backgroundColor: colors.errorContainer,
                    foregroundColor: colors.onErrorContainer,
                  ),
                  icon: const Icon(Icons.replay, size: 20),
                ),
              ),
            Positioned(
              top: Space.xs,
              right: Space.xs,
              child: SizedBox.square(
                dimension: 24,
                child: IconButton(
                  onPressed: onRemove,
                  tooltip: 'Remove',
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.55),
                  ),
                  icon: const Icon(Icons.close, color: Colors.white, size: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomTypeDropdown extends StatelessWidget {
  const _RoomTypeDropdown({required this.selected, required this.error, required this.onSelected});

  final RoomType? selected;
  final String? error;
  final ValueChanged<RoomType> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(context.appColors.background),
          minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 0)),
        ),
        menuChildren: [
          for (final type in RoomType.values)
            MenuItemButton(
              onPressed: () => onSelected(type),
              child: Text(
                type.name,
                style: typos.bodyMedium?.copyWith(
                  fontWeight: selected == type ? FontWeight.bold : FontWeight.normal,
                  color: selected == type ? colors.primary : colors.onSurface,
                ),
              ),
            ),
        ],
        builder: (context, controller, _) => AuthInputTextField(
          value: selected?.name ?? '',
          error: error,
          onValueChange: (_) {},
          label: 'Room type *',
          labelAlpha: 0.7,
          placeholder: 'e.g. family',
          icon: const Icon(Icons.category),
          readOnly: true,
          isDropDown: true,
          dropDownState: controller.isOpen,
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
        ),
      ),
    );
  }
}
