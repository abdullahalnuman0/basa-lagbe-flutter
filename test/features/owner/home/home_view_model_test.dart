import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/dto/property/property_dtos.dart';
import 'package:messseat/data/repository/property_repository.dart';
import 'package:messseat/features/owner/home/home_view_model.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

void main() {
  late MockPropertyRepository repo;

  setUp(() => repo = MockPropertyRepository());

  final listings = [
    property(id: 1, rooms: [room(id: 1, seats: 2), room(id: 2, seats: 3)]),
    property(id: 2, approved: false, rooms: [room(id: 3, seats: 1)]),
    property(id: 3),
  ];

  test('builds the dashboard summary from the owner properties', () async {
    when(() => repo.findAll()).thenAnswer((_) async => ApiSuccess(listings));

    final vm = HomeViewModel(repo);
    expect(vm.state.isLoading, isTrue);
    await pumpEventQueue();

    final summary = vm.state.dashboardSummary!;
    expect(vm.state.isLoading, isFalse);
    expect(vm.state.properties, hasLength(3));
    expect(summary.activeListings, 2);
    expect(summary.pendingApproval, 1);
    expect(summary.availableSeats, 6);
    expect(summary.totalRoom, 3);
    expect(summary.approvedRoom, 2);
    expect(summary.pendingRoom, 1);
  });

  test('keeps the error when the first load fails', () async {
    when(() => repo.findAll()).thenAnswer((_) async => const ApiError('No internet'));

    final vm = HomeViewModel(repo);
    await pumpEventQueue();

    expect(vm.state.error, 'No internet');
    expect(vm.state.properties, isNull);
    expect(vm.state.isLoading, isFalse);
  });

  test('refresh marks refreshing and reports failures through onError', () async {
    when(() => repo.findAll()).thenAnswer((_) async => ApiSuccess(listings));
    final vm = HomeViewModel(repo);
    await pumpEventQueue();

    final pending = Completer<ApiResult<List<PropertyResponse>>>();
    when(() => repo.findAll()).thenAnswer((_) => pending.future);

    var errors = 0;
    final refresh = vm.loadData(onError: () => errors++);
    expect(vm.state.isRefreshing, isTrue);
    expect(vm.state.isLoading, isFalse);

    pending.complete(const ApiError('Timeout'));
    await refresh;

    expect(errors, 1);
    expect(vm.state.isRefreshing, isFalse);
    expect(vm.state.error, 'Timeout');
    expect(vm.state.properties, hasLength(3));
  });

  test('ignores a load while another one is running', () async {
    final pending = Completer<ApiResult<List<PropertyResponse>>>();
    when(() => repo.findAll()).thenAnswer((_) => pending.future);

    final vm = HomeViewModel(repo);
    await vm.loadData();
    pending.complete(ApiSuccess(listings));
    await pumpEventQueue();

    verify(() => repo.findAll()).called(1);
  });

  test('sortPositionChange updates the selected tab', () async {
    when(() => repo.findAll()).thenAnswer((_) async => ApiSuccess(listings));
    final vm = HomeViewModel(repo);
    await pumpEventQueue();

    vm.sortPositionChange(2);

    expect(vm.state.sortPosition, 2);
  });
}
