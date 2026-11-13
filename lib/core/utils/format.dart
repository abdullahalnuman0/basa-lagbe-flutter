import 'package:intl/intl.dart';

final _dateFmt = DateFormat('d MMM yyyy', 'en_US');
final _dateTimeFmt = DateFormat('d MMM yyyy, h:mm a', 'en_US');

DateTime? _parse(String? iso) => iso == null ? null : DateTime.tryParse(iso)?.toLocal();

String formatDate(String? iso) {
  final d = _parse(iso);
  return d == null ? '—' : _dateFmt.format(d);
}

String formatDateTime(String? iso) {
  final d = _parse(iso);
  return d == null ? '—' : _dateTimeFmt.format(d);
}

String timeAgo(String? iso, {DateTime? now}) {
  final instant = _parse(iso);
  if (instant == null) return '—';
  final d = (now ?? DateTime.now()).difference(instant);
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  if (d.inDays < 7) return '${d.inDays}d';
  return formatDate(iso);
}
