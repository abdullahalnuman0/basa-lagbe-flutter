import 'package:intl/intl.dart';

import '../config.dart';

final _money = NumberFormat('#,##0', 'en');

extension ImageUrlX on String {
  String toImageUrl() => '${AppConfig.baseUrl}files/$this';
}

extension MoneyX on int {
  String toMoney() => '৳${_money.format(this)}';
}

String greeting(String? name, {DateTime? now}) {
  final hour = (now ?? DateTime.now()).hour;
  final greeting = switch (hour) {
    < 5 => 'Still up?',
    < 12 => 'Good morning',
    < 17 => 'Good afternoon',
    < 22 => 'Good evening',
    _ => 'Wind down',
  };
  final firstName = (name ?? '').trim().split(RegExp(r'\s+')).first;
  return firstName.isNotEmpty ? '$greeting, $firstName' : greeting;
}
