import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/favorites_manager.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/tenant/tenant_dtos.dart';
import 'package:messseat/features/tenant/saved_post/save_post_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures.dart';

void main() {
  late MockTenantRepository repo;
  late FavoritesManager favorites;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    favorites = FavoritesManager(await SharedPreferences.getInstance());
    repo = MockTenantRepository();
    when(() => repo.getSavedRooms(any())).thenAnswer((inv) async {
      final ids = inv.positionalArguments.first as List<int>;
      return ApiSuccess([for (final id in ids) room(id: id)]);
    });
  });

  test('nothing saved means an empty list without a request', () async {
    final vm = SavePostViewModel(repo, favorites);
    await pumpEventQueue();

    expect(vm.uiState.isLoading, isFalse);
    expect(vm.uiState.rooms, isEmpty);
    verifyNever(() => repo.getSavedRooms(any()));
    vm.dispose();
  });

  test('loads the saved rooms by id', () async {
    await favorites.addFavorite(3);
    await favorites.addFavorite(8);

    final vm = SavePostViewModel(repo, favorites);
    await pumpEventQueue();

    final ids = verify(() => repo.getSavedRooms(captureAny())).captured.single as List<int>;
    expect(ids, unorderedEquals([3, 8]));
    expect(vm.uiState.rooms.map((r) => r.roomId), unorderedEquals([3, 8]));
    expect(vm.uiState.isLoading, isFalse);
    vm.dispose();
  });

  test('reloads when a room is unsaved', () async {
    await favorites.addFavorite(3);
    await favorites.addFavorite(8);
    final vm = SavePostViewModel(repo, favorites);
    await pumpEventQueue();

    await favorites.removeFavorite(8);
    await pumpEventQueue();

    expect(vm.roomIds, {'3'});
    expect(vm.uiState.rooms.single.roomId, 3);

    await favorites.removeFavorite(3);
    await pumpEventQueue();

    expect(vm.uiState.rooms, isEmpty);
    verify(() => repo.getSavedRooms(any())).called(2);
    vm.dispose();
  });

  test('surfaces the error and recovers on retry', () async {
    await favorites.addFavorite(5);
    when(() => repo.getSavedRooms(any()))
        .thenAnswer((_) async => const ApiError<List<RoomTenantResponse>>('Server down'));

    final vm = SavePostViewModel(repo, favorites);
    await pumpEventQueue();

    expect(vm.uiState.error, 'Server down');
    expect(vm.uiState.isLoading, isFalse);

    when(() => repo.getSavedRooms(any())).thenAnswer((_) async => ApiSuccess([room(id: 5)]));
    await vm.loadSaveRooms();

    expect(vm.uiState.error, isNull);
    expect(vm.uiState.rooms.single.roomId, 5);
    vm.dispose();
  });
}
