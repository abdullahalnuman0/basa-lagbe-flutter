# DormEasy

Find and list rooms, mess seats, hostels, flats and sublets.

Tenants search and filter rooms, save posts and chat with owners. Owners list properties
with rooms, track views and seat availability, and get notified in real time.

## Stack

- Flutter (Material 3), `provider` for state, `get_it` for dependencies
- `go_router` – separate graphs for auth, owner and tenant
- `dio` with token refresh, STOMP over WebSocket for live chat and notifications
- `shared_preferences` for session, theme and notification settings
- Firebase Cloud Messaging (optional)

## Project layout

```
lib/
  core/        config, storage, networking, DI, shared widgets
  data/        api clients, dtos, repositories
  domain/      enums and models used by the UI
  features/    auth, owner, tenant and shared screens (screen + view model + components)
  navigation/  routes, routers, bottom bar
  ui/theme/    colours, typography, spacing
```

## Running

```
flutter pub get
flutter run
```

The API base url defaults to the hosted backend. Point it somewhere else with

```
flutter run --dart-define=BASE_URL=http://192.168.0.132:8081/api/v1/
```

### Push notifications

Push is disabled until `android/app/google-services.json` is added; the Gradle build applies
the Google Services plugin only when that file exists.

## Tests

```
flutter test
```
