import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/widgets/page_loader.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:messseat/features/tenant/home/home_view_model.dart';
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

  Future<void> signIn() => session.updateUser(
    const UserResponse(id: 1, fullName: 'Rafi', division: 'Dhaka', district: 'Gazipur'),
  );

  test('loads nearby rooms for the user location', () async {
    await signIn();

    final vm = HomeViewModel(repo, session);
    await pumpEventQueue();

    final params = verify(() => repo.findRooms(captureAny())).captured.single;
    expect(params, {'page': '0', 'size': '10', 'division': 'Dhaka', 'district': 'Gazipur'});
    expect(vm.loader.state, isA<UiSuccess<dynamic>>());
    expect(vm.loader.items.single.roomId, 1);

    vm.dispose();
  });

  test('waits for the session user before the first load', () async {
    final vm = HomeViewModel(repo, session);
    await pumpEventQueue();

    verifyNever(() => repo.findRooms(any()));
    expect(vm.loader.state, isA<UiLoading<dynamic>>());

    await signIn();
    await pumpEventQueue();

    verify(() => repo.findRooms(any())).called(1);
    expect(vm.loader.items, hasLength(1));

    vm.dispose();
  });

  test('shows the error when the request fails', () async {
    when(() => repo.findRooms(any())).thenAnswer((_) async => const ApiError('No internet'));
    await signIn();

    final vm = HomeViewModel(repo, session);
    await pumpEventQueue();

    expect((vm.loader.state as UiError).message, 'No internet');

    vm.dispose();
  });
}
