import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/widgets/page_loader.dart';
import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/chat/chat_dtos.dart';
import 'package:messseat/features/shared/chat/chat_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  late MockChatRepository repo;

  setUp(() => repo = MockChatRepository());

  test('loads the first page of chats on creation', () async {
    when(() => repo.list(0)).thenAnswer(
      (_) async => const ApiSuccess(
        PageResponse(
          content: [
            ChatResponse(id: 1, otherUserName: 'Rahim'),
            ChatResponse(id: 2, otherUserName: 'Karim'),
          ],
        ),
      ),
    );

    final vm = ChatViewModel(repo);
    expect(vm.loader.state, isA<UiLoading<List<ChatResponse>>>());

    await settle();

    expect(vm.loader.items.map((c) => c.otherUserName), ['Rahim', 'Karim']);
    verify(() => repo.list(0)).called(1);
    vm.dispose();
  });

  test('shows the error when the first load fails', () async {
    when(() => repo.list(0)).thenAnswer((_) async => const ApiError('No internet connection'));

    final vm = ChatViewModel(repo);
    await settle();

    final state = vm.loader.state;
    expect(state, isA<UiError<List<ChatResponse>>>());
    expect((state as UiError).message, 'No internet connection');
    vm.dispose();
  });
}
