import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/notification/notification_response.dart';
import 'package:messseat/features/shared/notification/notification_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockNotificationRepository notyRepo;
  late MockUnreadCountRepository unread;

  setUp(() {
    notyRepo = MockNotificationRepository();
    unread = MockUnreadCountRepository();

    when(() => notyRepo.notifications(0)).thenAnswer(
      (_) async => const ApiSuccess(
        PageResponse(
          content: [
            NotificationResponse(id: 1, title: 'New message'),
            NotificationResponse(id: 2, title: 'Room approved'),
            NotificationResponse(id: 3, title: 'Old news', read: true),
          ],
        ),
      ),
    );
    when(() => notyRepo.markNotificationRead(any())).thenAnswer((_) async {});
    when(() => unread.updateNotificationCount()).thenAnswer((_) async {});
  });

  Future<NotificationViewModel> create() async {
    final vm = NotificationViewModel(notyRepo, unread);
    await settle();
    return vm;
  }

  List<bool> readFlags(NotificationViewModel vm) => vm.loader.items.map((n) => n.read).toList();

  test('markRead marks a single notification and lowers the badge', () async {
    final vm = await create();

    await vm.markRead(2);

    expect(readFlags(vm), [false, true, true]);
    verify(() => notyRepo.markNotificationRead(2)).called(1);
    verify(() => unread.decrementUnreadNotyCount()).called(1);
    vm.dispose();
  });

  test('markAll marks everything read and refreshes the count', () async {
    when(() => notyRepo.markAllNotificationsRead()).thenAnswer((_) async => const ApiSuccess(null));
    final vm = await create();
    final messages = <String>[];

    await vm.markAll(onResult: messages.add);

    expect(readFlags(vm), [true, true, true]);
    expect(messages, ['Marked all as read.']);
    verify(() => unread.updateNotificationCount()).called(1);
    vm.dispose();
  });

  test('markAll reports the error and leaves the list untouched', () async {
    when(() => notyRepo.markAllNotificationsRead())
        .thenAnswer((_) async => const ApiError('Server is busy'));
    final vm = await create();
    final messages = <String>[];

    await vm.markAll(onResult: messages.add);

    expect(readFlags(vm), [false, false, true]);
    expect(messages, ['Server is busy']);
    verifyNever(() => unread.updateNotificationCount());
    vm.dispose();
  });
}
