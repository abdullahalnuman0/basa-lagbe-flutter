import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/presentation/components/messages.dart';
import '../../../../core/presentation/widgets/page_header.dart';
import '../../../../domain/model/room.dart';
import '../../../../ui/theme/space.dart';
import '../../../../ui/theme/theme.dart';
import '../../../auth/signup/components/dashed_border.dart';
import '../property_editor_ui_state.dart';
import 'components/add_room_bottom_sheet.dart';
import 'components/room_viewer_card.dart';
import 'room_editor_view_model.dart';

class RoomEditorSection extends StatelessWidget {
  const RoomEditorSection({
    super.key,
    required this.state,
    required this.onAddRoom,
    required this.onRemoveRoom,
    required this.onUpdateRoom,
  });

  final PropertyEditorUiState state;
  final ValueChanged<Room> onAddRoom;
  final ValueChanged<Room> onRemoveRoom;
  final void Function(int index, Room room) onUpdateRoom;

  void _openSheet(BuildContext context, {(int, Room)? editing}) {
    final roomVm = context.read<RoomEditorViewModel>();
    roomVm.initialRoom(editing?.$2);

    showAddRoomBottomSheet(
      context,
      vm: roomVm,
      isEdit: editing != null,
      onSave: (room) {
        if (editing != null) {
          onUpdateRoom(editing.$1, room.copyWith(id: editing.$2.id));
        } else {
          onAddRoom(room);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = state.rooms;

    return ListView(
      children: [
        const SizedBox(height: Space.md),
        PageHeader(
          title: 'Available rooms',
          subtitle: 'Add the rooms available in your hostel, flat or mess. Configure pricing, deposit and upload room photos',
          titleStyle: context.typos.headlineMedium,
          subtitleStyle: context.typos.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: Space.xxxl),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: state.roomsError == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: Space.xxxl),
                  child: ErrorBoxMessage(error: state.roomsError),
                ),
        ),
        for (var i = 0; i < rooms.length; i++) ...[
          RoomViewerCard(
            room: rooms[i],
            onEdit: () => _openSheet(context, editing: (i, rooms[i])),
            onDelete: () => onRemoveRoom(rooms[i]),
          ),
          const SizedBox(height: Space.lg),
        ],
        _AddRoomButton(onClick: () => _openSheet(context)),
        const SizedBox(height: Space.xxxl),
      ],
    );
  }
}

class _AddRoomButton extends StatelessWidget {
  const _AddRoomButton({required this.onClick});

  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typos = context.typos;

    return DashedBorder(
      color: colors.outline,
      child: Card(
        margin: EdgeInsets.zero,
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onClick,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.xl),
            child: Column(
              spacing: Space.xs,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                  child: const Icon(Icons.add, semanticLabel: 'Add'),
                ),
                Text('Add Room', style: typos.headlineSmall?.copyWith(color: colors.primary)),
                Text('Tap to add another room', style: typos.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
