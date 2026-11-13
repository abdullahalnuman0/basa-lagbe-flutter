import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/features/tenant/search/room_search_filter.dart';
import 'package:messseat/features/tenant/search/search_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures.dart';

void main() {
  late MockTenantRepository repo;
  late SessionManager session;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    session = SessionManager(await SharedPreferences.getInstance());
    repo = MockTenantRepository();
    when(() => repo.findRooms(any())).thenAnswer((_) async => ApiSuccess(page([room()])));
  });

  Future<SearchViewModel> createVm({String? division, String? district}) async {
    await session.updateUser(UserResponse(id: 1, division: division, district: district));
    final vm = SearchViewModel(repo, session);
    await pumpEventQueue();
    return vm;
  }

  Map<String, String?> lastParams() =>
      verify(() => repo.findRooms(captureAny())).captured.last as Map<String, String?>;

  group('initial load', () {
    test('uses the user location as the starting filter', () async {
      final vm = await createVm(division: 'Khulna', district: 'Jessore');

      expect(vm.filter.division, 'Khulna');
      expect(vm.filter.district, 'Jessore');
      expect(lastParams(), {
        'page': '0',
        'size': '10',
        'division': 'Khulna',
        'district': 'Jessore',
        'sort': 'createdAt,desc',
      });
      vm.dispose();
    });

    test('falls back to the first division and district', () async {
      final vm = await createVm();

      expect(vm.filter.division, 'Dhaka');
      expect(vm.filter.district, 'Dhaka');
      vm.dispose();
    });

    test('does nothing until a user is signed in', () async {
      final vm = SearchViewModel(repo, session);
      await pumpEventQueue();
      verifyNever(() => repo.findRooms(any()));

      await session.updateUser(const UserResponse(id: 1, division: 'Sylhet'));
      await pumpEventQueue();

      expect(vm.filter.district, 'Sylhet');
      verify(() => repo.findRooms(any())).called(1);
      vm.dispose();
    });
  });

  test('applied filters are turned into query params', () async {
    final vm = await createVm(division: 'Dhaka', district: 'Dhaka');

    vm
      ..updateKeyword('  balcony  ')
      ..openFilterSheet()
      ..updateFilter(
        (old) => old.copyWith(
          area: 'Mirpur',
          roomType: RoomType.SINGLE,
          minRent: '3000',
          maxRent: '8000',
          minAvailableSeats: '1',
          maxAvailableSeats: '4',
          minRoomWidth: '10',
          minRoomHeight: '12',
          sortBy: SortOption.RENT,
          sortOrder: SortOrder.ASC,
        ),
      );
    expect(vm.filterSheetVisible, isTrue);

    vm.applyFilters();
    await pumpEventQueue();

    expect(vm.filterSheetVisible, isFalse);
    expect(lastParams(), {
      'page': '0',
      'size': '10',
      'keyword': 'balcony',
      'division': 'Dhaka',
      'district': 'Dhaka',
      'area': 'Mirpur',
      'roomType': 'SINGLE',
      'minRent': '3000',
      'maxRent': '8000',
      'minAvailableSeats': '1',
      'maxAvailableSeats': '4',
      'minRoomSize': '120',
      'sort': 'rent,asc',
    });
    vm.dispose();
  });

  test('room size is only sent when both sides are given', () async {
    final vm = await createVm(division: 'Dhaka', district: 'Dhaka');

    vm
      ..updateFilter((old) => old.copyWith(minRoomWidth: '10'))
      ..applyFilters();
    await pumpEventQueue();

    expect(lastParams().containsKey('minRoomSize'), isFalse);
    vm.dispose();
  });

  test('clearing resets everything and reloads', () async {
    final vm = await createVm(division: 'Dhaka', district: 'Dhaka');

    vm
      ..updateFilter((old) => old.copyWith(roomType: RoomType.FAMILY, maxRent: '9000'))
      ..openFilterSheet()
      ..clearFilters();
    await pumpEventQueue();

    expect(vm.filterSheetVisible, isFalse);
    expect(vm.filter.activeFilterCount(), 0);
    expect(lastParams(), {'page': '0', 'size': '10', 'sort': 'createdAt,desc'});
    vm.dispose();
  });

  group('RoomSearchFilter', () {
    test('counts every active filter and a non default sort', () {
      const filter = RoomSearchFilter(
        division: 'Dhaka',
        district: 'Dhaka',
        roomType: RoomType.SUITE,
        minRent: '100',
        sortOrder: SortOrder.ASC,
      );

      expect(filter.activeFilterCount(), 5);
      expect(const RoomSearchFilter(area: '   ').activeFilterCount(), 0);
    });

    test('copyWith can clear the room type', () {
      const filter = RoomSearchFilter(roomType: RoomType.DOUBLE);

      expect(filter.copyWith(minRent: '5').roomType, RoomType.DOUBLE);
      expect(filter.copyWith(roomType: null).roomType, isNull);
    });
  });
}
