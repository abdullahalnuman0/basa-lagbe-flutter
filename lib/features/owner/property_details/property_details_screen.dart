import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/messages.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/error_box.dart';
import '../../../core/utils/functions.dart';
import '../../../data/dto/property/property_dtos.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import 'components/property_about.dart';
import 'components/property_details_shimmer.dart';
import 'components/property_facilities.dart';
import 'components/property_header.dart';
import 'components/property_image_section.dart';
import 'components/property_location_contact.dart';
import 'components/property_room_section.dart';
import 'components/property_stats.dart';
import 'property_details_view_model.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key, required this.propertyId});

  final int propertyId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyDetailsViewModel(locator())..loadProperty(propertyId),
      child: const _PropertyDetailsView(),
    );
  }
}

class _PropertyDetailsView extends StatelessWidget {
  const _PropertyDetailsView();

  Future<void> _confirmDelete(BuildContext context, PropertyDetailsViewModel vm) {
    vm.toggleDeleteDialog(true);
    return showDeleteConfirmationDialog(
      context,
      onDismiss: () => vm.toggleDeleteDialog(false),
      onConfirm: () => vm.deleteProperty(
        onSuccess: () {
          AppSnackbar.show('Property deleted successfully.');
          if (context.mounted) context.pop();
        },
        onError: AppSnackbar.show,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PropertyDetailsViewModel>();
    final state = vm.state;
    final property = state.property;

    final Widget body;
    if (property == null && state.isLoading) {
      body = const PropertyDetailsShimmer();
    } else if (property == null && state.error != null) {
      body = ErrorBox(message: state.error ?? 'Something want wrong!', onRetry: vm.loadProperty);
    } else if (property != null) {
      body = PullToRefresh(
        onRefresh: vm.loadProperty,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _PropertyContent(property: property, vm: vm),
        ),
      );
    } else {
      body = const SizedBox.shrink();
    }

    return Stack(
      children: [
        Column(
          children: [
            AppTopBar(
              title: 'Property details',
              onBack: () => context.pop(),
              actions: [
                IconButton(
                  onPressed: state.isLoading || property == null
                      ? null
                      : () => context.pushReplacement(Routes.propertyEditor, extra: property),
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: state.isLoading ? null : () => _confirmDelete(context, vm),
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_outline, color: context.colors.error),
                ),
              ],
            ),
            Expanded(child: body),
          ],
        ),
        if (state.isForceLoading)
          const Positioned.fill(child: ModalBarrier(dismissible: false, color: Color(0x4D444444))),
        if (state.isForceLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _PropertyContent extends StatelessWidget {
  const _PropertyContent({required this.property, required this.vm});

  final PropertyResponse property;
  final PropertyDetailsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final rooms = property.rooms;
    final startingRent = rooms.isEmpty
        ? 0
        : rooms.map((r) => r.rent).reduce((a, b) => a < b ? a : b);
    final phone = property.contactNumber.startsWith('+88')
        ? property.contactNumber
        : '+88${property.contactNumber}';

    return Column(
      children: [
        PropertyImageSection(images: [for (final room in rooms) ...room.images]),
        PropertyHeader(
          title: property.title,
          approved: property.approved,
          location: '${property.area}, ${property.division}',
          type: property.type,
          gender: property.gender,
          error: vm.state.error,
        ),
        PropertyStats(
          stats: [
            (label: 'Total Rooms', value: '${rooms.length}', icon: Icons.meeting_room_outlined),
            (
              label: 'Available Seats',
              value: '${rooms.fold(0, (sum, r) => sum + r.availableSeats)}',
              icon: Icons.single_bed_outlined,
            ),
            (label: 'Starting Rent', value: startingRent.toMoney(), icon: Icons.payment_outlined),
            (
              label: 'Key Facilities',
              value: '${property.facilities.length}',
              icon: Icons.emoji_objects_outlined,
            ),
          ],
        ),
        if (property.description.isNotEmpty) PropertyAbout(desc: property.description),
        const SizedBox(height: Space.lg),
        PropertyFacilities(facilities: property.facilities),
        const SizedBox(height: Space.lg),
        PropertyLocationContact(
          address: property.address,
          institution: property.institutionNearby,
          phone: phone,
        ),
        PropertyRoomSection(
          state: vm.state,
          onSearchTextChange: vm.onSearchValueChange,
          onSearchTextClear: vm.onSearchValueClear,
          onUpdateRoom: (index, room) => vm.onUpdateRoom(
            index,
            room,
            onError: AppSnackbar.show,
            onSuccess: () => AppSnackbar.show('Room updated successfully.'),
          ),
          onAddRoom: (room) => vm.onAddRoom(
            room,
            onError: AppSnackbar.show,
            onSuccess: () => AppSnackbar.show('Room Added successfully.'),
          ),
          onAvailability: (index, availability) => vm.onAvailability(
            index,
            availability,
            onError: AppSnackbar.show,
            onSuccess: () => AppSnackbar.show('Successfully Availability updated'),
          ),
        ),
        const SizedBox(height: Space.listBottom),
      ],
    );
  }
}
