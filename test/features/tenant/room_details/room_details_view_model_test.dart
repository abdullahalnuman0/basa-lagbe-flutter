import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/favorites_manager.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/chat/chat_dtos.dart';
import 'package:messseat/features/tenant/room_details/room_details_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures.dart';

void main() {
  late MockTenantRepository tenantRepo;
  late MockChatRepository chatRepo;
  late FavoritesManager favorites;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    favorites = FavoritesManager(await SharedPreferences.getInstance());
    tenantRepo = MockTenantRepository();
    chatRepo = MockChatRepository();
    when(() => tenantRepo.findRoom(any())).thenAnswer((_) async => ApiSuccess(room(id: 42)));
  });

  Future<RoomDetailsViewModel> createVm() async {
    final vm = RoomDetailsViewModel(42, tenantRepo, chatRepo, favorites);
    await pumpEventQueue();
    return vm;
  }

  group('loadRoom', () {
    test('shows the room and whether it is saved', () async {
      await favorites.addFavorite(42);

      final vm = await createVm();

      verify(() => tenantRepo.findRoom(42)).called(1);
      expect(vm.uiState.isLoading, isFalse);
      expect(vm.uiState.room?.roomId, 42);
      expect(vm.uiState.isFavorite, isTrue);
      expect(vm.uiState.error, isNull);
    });

    test('keeps the error message on failure', () async {
      when(() => tenantRepo.findRoom(any())).thenAnswer((_) async => const ApiError('Not found'));

      final vm = await createVm();

      expect(vm.uiState.isLoading, isFalse);
      expect(vm.uiState.room, isNull);
      expect(vm.uiState.error, 'Not found');
    });
  });

  test('favourite toggles between saved and removed', () async {
    final vm = await createVm();
    final results = <bool>[];

    await vm.updateFavoriteState(results.add);
    expect(vm.uiState.isFavorite, isTrue);
    expect(favorites.favoritePostIds, {'42'});

    await vm.updateFavoriteState(results.add);
    expect(vm.uiState.isFavorite, isFalse);
    expect(favorites.favoritePostIds, isEmpty);

    expect(results, [true, false]);
  });

  group('openChat', () {
    test('opens the chat for this room', () async {
      when(() => chatRepo.open(any()))
          .thenAnswer((_) async => const ApiSuccess(ChatResponse(id: 7)));
      final vm = await createVm();
      int? openedChat;

      final pending = vm.openChat(onChat: (id) => openedChat = id, onError: fail);
      expect(vm.uiState.isChatOpening, isTrue);
      await pending;

      verify(() => chatRepo.open(42)).called(1);
      expect(openedChat, 7);
      expect(vm.uiState.isChatOpening, isFalse);
    });

    test('reports the failure', () async {
      when(() => chatRepo.open(any())).thenAnswer((_) async => const ApiError('Chat unavailable'));
      final vm = await createVm();
      String? error;

      await vm.openChat(onChat: (_) => fail('should not open'), onError: (msg) => error = msg);

      expect(error, 'Chat unavailable');
      expect(vm.uiState.isChatOpening, isFalse);
    });
  });
}
