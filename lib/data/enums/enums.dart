enum MessageType { TEXT, IMAGE }

enum NotyRefType { CHAT, OWNER_POST, TENANT_POST }

enum Role { OWNER, TENANT, MODERATOR, ADMIN }

enum RoomType { SINGLE, DOUBLE, TRIPLE, DELUXE, SUITE, FAMILY }

enum UserStatus { ACTIVE, SUSPENDED, BANNED, PENDING_DELETION }

T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  if (name is! String) return fallback;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

T? enumByNameOrNull<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
