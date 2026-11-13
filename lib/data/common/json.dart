typedef Json = Map<String, dynamic>;

int asInt(Object? v, [int fallback = 0]) => switch (v) {
  final int i => i,
  final num n => n.toInt(),
  final String s => int.tryParse(s) ?? fallback,
  _ => fallback,
};

String asString(Object? v, [String fallback = '']) => v == null ? fallback : v.toString();

String? asStringOrNull(Object? v) => v?.toString();

bool asBool(Object? v, [bool fallback = false]) => switch (v) {
  final bool b => b,
  final String s => s == 'true',
  _ => fallback,
};

List<String> asStringList(Object? v) => v is List ? v.map((e) => e.toString()).toList() : const [];

List<T> asList<T>(Object? v, T Function(Json) fromJson) =>
    v is List ? v.whereType<Map>().map((e) => fromJson(Json.from(e))).toList() : <T>[];

DateTime parseInstant(Object? v) {
  if (v is String) {
    final parsed = DateTime.tryParse(v);
    if (parsed != null) return parsed;
  }
  return DateTime.now();
}

String instantToString(DateTime v) => v.toUtc().toIso8601String();
