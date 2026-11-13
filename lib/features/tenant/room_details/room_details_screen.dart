import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/widgets/error_box.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../data/dto/tenant/tenant_dtos.dart';
import '../../../navigation/routes.dart';
import '../../owner/property_details/components/property_about.dart';
import '../../owner/property_details/components/property_facilities.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import 'components/glass_icon_button.dart';
import 'components/header_section.dart';
import 'components/owner_info_card.dart';
import 'components/room_basic_info.dart';
import 'room_details_view_model.dart';

class RoomDetailsScreen extends StatelessWidget {
  const RoomDetailsScreen({super.key, required this.roomId});

  final int roomId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoomDetailsViewModel(roomId, locator(), locator(), locator()),
      child: const _RoomDetailsView(),
    );
  }
}

class _RoomDetailsView extends StatelessWidget {
  const _RoomDetailsView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RoomDetailsViewModel>();
    final state = vm.uiState;
    final room = state.room;

    if (state.isLoading) return const ShimmerList();

    if (state.error != null || room == null) {
      return ErrorBox(
        message: state.error ?? 'Something want wrong. Please try again.',
        onRetry: vm.loadRoom,
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: context.appColors.background,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HeaderSection(
                    images: room.images,
                    isSaved: state.isFavorite,
                    propertyType: room.propertyType,
                    gender: room.gender,
                    roomType: room.roomType,
                    rent: room.rent,
                    onFavorite: () => vm.updateFavoriteState(
                      (saved) => AppSnackbar.showWithAction(saved ? 'Save post' : 'Remove post'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(Space.screen),
                    child: _RoomBody(room: room, isChatOpening: state.isChatOpening),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: Space.xs,
          top: Space.xs,
          child: GlassIconButton(
            icon: Icons.keyboard_backspace_outlined,
            semanticLabel: 'Back',
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}

class _RoomBody extends StatelessWidget {
  const _RoomBody({required this.room, required this.isChatOpening});

  final RoomTenantResponse room;
  final bool isChatOpening;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RoomDetailsViewModel>();
    const cardRadius = BorderRadius.all(Radius.circular(16));

    return Column(
      spacing: Space.listGap,
      children: [
        RoomBasicInfo(
          title: room.title,
          roomNumber: room.roomNumber,
          location: room.address,
          institutionNearby: room.institutionNearby,
          roomSize: '${room.roomWidth} x ${room.roomHeight}',
          totalSeats: room.availableSeats,
        ),
        OwnerInfoCard(
          name: room.ownerName,
          avatarUrl: room.ownerAvatarUrl,
          isChatOpening: isChatOpening,
          onCall: () {},
          onChat: () => vm.openChat(
            onChat: (chatId) {
              if (context.mounted) context.push(Routes.conversation(chatId));
            },
            onError: AppSnackbar.showWithAction,
          ),
        ),
        PropertyFacilities(facilities: room.facilities, borderRadius: cardRadius),
        if (room.description.isNotEmpty)
          PropertyAbout(desc: room.description, borderRadius: cardRadius),
      ],
    );
  }
}
