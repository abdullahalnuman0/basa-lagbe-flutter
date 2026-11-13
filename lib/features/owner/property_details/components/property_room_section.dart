import 'package:flutter/material.dart';

import '../../../../core/di/locator.dart';
import '../../../../data/dto/room/room_dtos.dart';
import '../../../../domain/model/room.dart';
import '../../../../ui/theme/space.dart';
import '../../property_add_edit/room_section/components/add_room_bottom_sheet.dart';
import '../../property_add_edit/room_section/room_editor_view_model.dart';
import '../property_details_ui_state.dart';
import 'room/availability_dialog.dart';
import 'room/room_details_list.dart';
import 'room/room_header.dart';

class PropertyRoomSection extends StatefulWidget {
  const PropertyRoomSection({
    super.key,
    required this.state,
    required this.onSearchTextChange,
    required this.onSearchTextClear,
    required this.onUpdateRoom,
    required this.onAddRoom,
    required this.onAvailability,
  });

  final PropertyDetailsUiState state;
  final ValueChanged<String> onSearchTextChange;
  final VoidCallback onSearchTextClear;
  final void Function(int index, RoomResponse room) onUpdateRoom;
  final ValueChanged<Room> onAddRoom;
  final void Function(int roomIndex, int newAvailability) onAvailability;

  @override
  State<PropertyRoomSection> createState() => _PropertyRoomSectionState();
}

class _PropertyRoomSectionState extends State<PropertyRoomSection> {
  late final _roomVm = RoomEditorViewModel(locator());

  @override
  void dispose() {
    _roomVm.dispose();
    super.dispose();
  }

  void _openSheet({int? editingIndex}) {
    final rooms = widget.state.property?.rooms ?? const [];
    if (editingIndex != null) _roomVm.initialRoom(rooms[editingIndex].toRoom());

    showAddRoomBottomSheet(
      context,
      vm: _roomVm,
      isEdit: editingIndex != null,
      onSave: (room) {
        if (editingIndex != null) {
          widget.onUpdateRoom(editingIndex, room.toRoomResponse());
        } else {
          widget.onAddRoom(room);
        }
      },
    );
  }

  void _openAvailability(int index) {
    final room = widget.state.property!.rooms[index];
    showAvailabilityDialog(
      context,
      roomNumber: room.roomNumber,
      availableSeats: room.availableSeats,
      onSave: (value) => widget.onAvailability(index, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.state.property;
    if (property == null) return const SizedBox.shrink();

    final query = widget.state.searchText.trim().toLowerCase();
    final filteredRooms = [
      for (final (index, room) in property.rooms.indexed)
        if (query.isEmpty || room.roomNumber.toLowerCase().contains(query)) (index, room),
    ];

    return Padding(
      padding: const EdgeInsets.all(Space.screen),
      child: Column(
        spacing: Space.listGap,
        children: [
          RoomHeader(
            totalRoom: property.rooms.length,
            searchText: widget.state.searchText,
            onAdd: _openSheet,
            onSearchChange: widget.onSearchTextChange,
            onSearchClear: widget.onSearchTextClear,
          ),
          RoomDetailsList(
            searchText: widget.state.searchText,
            rooms: filteredRooms,
            onEdit: (index) => _openSheet(editingIndex: index),
            onAvailability: _openAvailability,
          ),
        ],
      ),
    );
  }
}
