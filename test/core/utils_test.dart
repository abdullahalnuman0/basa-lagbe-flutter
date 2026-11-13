import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/config.dart';
import 'package:messseat/core/presentation/components/user_avatar.dart';
import 'package:messseat/core/utils/format.dart';
import 'package:messseat/core/utils/functions.dart';
import 'package:messseat/data/dto/notification/notification_response.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/navigation/routes.dart';

void main() {
  group('format', () {
    test('formatDate and formatDateTime handle bad input', () {
      expect(formatDate(null), '—');
      expect(formatDate('nope'), '—');
      expect(formatDateTime(null), '—');
    });

    test('formatDate uses day month year', () {
      final local = DateTime.utc(2026, 3, 9, 12).toLocal();
      expect(formatDate('2026-03-09T12:00:00Z'), '${local.day} Mar 2026');
    });

    test('timeAgo buckets', () {
      final now = DateTime.utc(2026, 5, 10, 12);
      String ago(Duration d) => timeAgo(now.subtract(d).toIso8601String(), now: now);

      expect(ago(const Duration(seconds: 20)), 'just now');
      expect(ago(const Duration(minutes: 5)), '5m');
      expect(ago(const Duration(hours: 3)), '3h');
      expect(ago(const Duration(days: 2)), '2d');
      expect(ago(const Duration(days: 30)), contains('2026'));
      expect(timeAgo(null), '—');
    });
  });

  group('functions', () {
    test('toMoney adds the taka sign and grouping', () {
      expect(4500.toMoney(), '৳4,500');
      expect(1250000.toMoney(), '৳1,250,000');
      expect(0.toMoney(), '৳0');
    });

    test('toImageUrl points at the files endpoint', () {
      expect('rooms/a.jpg'.toImageUrl(), '${AppConfig.baseUrl}files/rooms/a.jpg');
    });

    test('greeting depends on the hour and uses the first name', () {
      DateTime at(int h) => DateTime(2026, 1, 1, h);
      expect(greeting('Rahim Uddin', now: at(3)), 'Still up?, Rahim');
      expect(greeting('Rahim', now: at(9)), 'Good morning, Rahim');
      expect(greeting('  Sadia  Islam ', now: at(14)), 'Good afternoon, Sadia');
      expect(greeting(null, now: at(19)), 'Good evening');
      expect(greeting('', now: at(23)), 'Wind down');
    });

    test('initials', () {
      expect(initials(null), '?');
      expect(initials('  '), '?');
      expect(initials('rahim'), 'RA');
      expect(initials('Rahim Uddin Khan'), 'RK');
      expect(initials('A'), 'A');
    });
  });

  group('notificationTarget', () {
    NotificationResponse noty(NotyRefType? type, [int? id = 5]) =>
        NotificationResponse(id: 1, refType: type, refId: id);

    test('chat notifications open the conversation for everyone', () {
      expect(notificationTarget(noty(NotyRefType.CHAT), isOwner: true), '/conversation/5');
      expect(notificationTarget(noty(NotyRefType.CHAT), isOwner: false), '/conversation/5');
    });

    test('post notifications only resolve inside the matching graph', () {
      expect(notificationTarget(noty(NotyRefType.OWNER_POST), isOwner: true), '/property/5');
      expect(notificationTarget(noty(NotyRefType.OWNER_POST), isOwner: false), isNull);
      expect(notificationTarget(noty(NotyRefType.TENANT_POST), isOwner: false), '/room/5');
      expect(notificationTarget(noty(NotyRefType.TENANT_POST), isOwner: true), isNull);
    });

    test('missing reference means no destination', () {
      expect(notificationTarget(noty(NotyRefType.CHAT, null), isOwner: true), isNull);
      expect(notificationTarget(noty(null), isOwner: true), isNull);
    });
  });
}
