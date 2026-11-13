import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/room/room_dtos.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/data/repository/property_repository.dart';
import 'package:messseat/domain/model/room.dart';
import 'package:messseat/features/owner/property_details/property_details_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../home/fixtures.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  late MockPropertyRepository repo;
  late PropertyDetailsViewModel vm;

  final listing = property(
    id: 7,
    rooms: [
      room(id: 11, number: '101', seats: 2),
      room(id: 12, number: '102', seats: 0),
    ],
  );

  setUpAll(() {
    registerFallbackValue(const RoomAvailabilityRequest(roomId: 0, availableSeats: 0));
    registerFallbackValue(
      const RoomRequest(
        availableSeats: 0,
        images: [],
        rent: 0,
        roomHeight: 0,
        roomNumber: '',
        roomWidth: 0,
        type: RoomType.SINGLE,
      ),
    );
  });

  setUp(() {
    repo = MockPropertyRepository();
    vm = PropertyDetailsViewModel(repo);
  });

  Future<void> loaded() async {
    when(() => repo.findOne(7)).thenAnswer((_) async => ApiSuccess(listing));
    await vm.loadProperty(7);
  }

  group('loadProperty', () {
    test('stores the property and its id', () async {
      await loaded();

      expect(vm.state.property, same(listing));
      expect(vm.state.propertyId, 7);
      expect(vm.state.isLoading, isFalse);
      expect(vm.state.error, isNull);
    });

    test('reloads with the remembered id', () async {
      await loaded();
      await vm.loadProperty();

      verify(() => repo.findOne(7)).called(2);
    });

    test('complains when there is no id to load', () async {
      await vm.loadProperty();

      expect(vm.state.error, "Don't have any ID.");
      expect(vm.state.isLoading, isFalse);
      verifyNever(() => repo.findOne(any()));
    });

    test('keeps the api error', () async {
      when(() => repo.findOne(7)).thenAnswer((_) async => const ApiError('Not found'));

      await vm.loadProperty(7);

      expect(vm.state.error, 'Not found');
      expect(vm.state.property, isNull);
    });
  });

  group('deleteProperty', () {
    test('calls onSuccess after deleting', () async {
      await loaded();
      when(() => repo.deleteProperty(7)).thenAnswer((_) async => const ApiSuccess(null));
      vm.toggleDeleteDialog();
      expect(vm.state.showDeleteAlert, isTrue);

      var deleted = false;
      await vm.deleteProperty(onSuccess: () => deleted = true, onError: (_) => fail('no error'));

      expect(deleted, isTrue);
      expect(vm.state.showDeleteAlert, isFalse);
      expect(vm.state.isLoading, isFalse);
    });

    test('passes the error message on failure', () async {
      await loaded();
      when(() => repo.deleteProperty(7)).thenAnswer((_) async => const ApiError('Forbidden'));

      String? error;
      await vm.deleteProperty(onSuccess: () => fail('should fail'), onError: (e) => error = e);

      expect(error, 'Forbidden');
      expect(vm.state.error, 'Forbidden');
    });
  });

  test('search text can be changed and cleared', () {
    vm.onSearchValueChange('10');
    expect(vm.state.searchText, '10');

    vm.onSearchValueClear();
    expect(vm.state.searchText, '');
  });

  test('onUpdateRoom replaces the room returned by the server', () async {
    await loaded();
    final updated = room(id: 12, number: '102', seats: 4, rent: 5000);
    when(() => repo.updateRoom(12, any())).thenAnswer((_) async => ApiSuccess(updated));

    var done = false;
    await vm.onUpdateRoom(1, updated, onSuccess: () => done = true, onError: (_) {});

    expect(done, isTrue);
    expect(vm.state.isForceLoading, isFalse);
    expect(vm.state.property!.rooms[1].rent, 5000);
    final body = verify(() => repo.updateRoom(12, captureAny())).captured.single as RoomRequest;
    expect(body.availableSeats, 4);
  });

  test('onAddRoom appends the created room', () async {
    await loaded();
    final created = room(id: 13, number: '103');
    when(() => repo.createRoom(7, any())).thenAnswer((_) async => ApiSuccess(created));

    await vm.onAddRoom(
      Room(roomNumber: '103', rent: 3000, availableSeats: 2, type: RoomType.DOUBLE),
      onSuccess: () {},
      onError: (_) {},
    );

    expect(vm.state.property!.rooms.map((r) => r.id), [11, 12, 13]);
  });

  test('onAddRoom leaves the rooms untouched on failure', () async {
    await loaded();
    when(() => repo.createRoom(7, any())).thenAnswer((_) async => const ApiError('Invalid'));

    String? error;
    await vm.onAddRoom(
      Room(roomNumber: '103', type: RoomType.SINGLE),
      onSuccess: () {},
      onError: (e) => error = e,
    );

    expect(error, 'Invalid');
    expect(vm.state.property!.rooms, hasLength(2));
    expect(vm.state.isForceLoading, isFalse);
  });

  test('onAvailability clamps negative values to zero', () async {
    await loaded();
    when(() => repo.roomAvailability(any())).thenAnswer((_) async => const ApiSuccess(null));

    await vm.onAvailability(0, -3, onSuccess: () {}, onError: (_) {});

    final request =
        verify(() => repo.roomAvailability(captureAny())).captured.single
            as RoomAvailabilityRequest;
    expect(request.roomId, 11);
    expect(request.availableSeats, 0);
    expect(vm.state.property!.rooms[0].availableSeats, 0);
  });
}
