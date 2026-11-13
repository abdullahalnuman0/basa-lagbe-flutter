import 'package:image_picker/image_picker.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/data/dto/chat/chat_dtos.dart';
import 'package:messseat/data/repository/chat_repository.dart';
import 'package:messseat/data/repository/file_repository.dart';
import 'package:messseat/data/repository/notification_repository.dart';
import 'package:messseat/data/repository/tenant_repository.dart';
import 'package:messseat/data/repository/unread_count_repository.dart';
import 'package:messseat/main_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockFileRepository extends Mock implements FileRepository {}

class MockTenantRepository extends Mock implements TenantRepository {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockUnreadCountRepository extends Mock implements UnreadCountRepository {}

class MockSessionManager extends Mock implements SessionManager {}

class MockMainViewModel extends Mock implements MainViewModel {}

void registerFallbacks() {
  registerFallbackValue(XFile(''));
  registerFallbackValue(const SendMessageRequest());
}

/// Lets pending futures and microtasks run.
Future<void> settle() => Future<void>.delayed(Duration.zero);
