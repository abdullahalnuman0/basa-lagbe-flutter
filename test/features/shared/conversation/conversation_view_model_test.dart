import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/chat/chat_dtos.dart';
import 'package:messseat/data/dto/tenant/tenant_dtos.dart';
import 'package:messseat/data/enums/enums.dart';
import 'package:messseat/domain/model/user.dart';
import 'package:messseat/features/shared/conversation/conversation_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

const chatId = 5;

ChatMessageResponse message(int id, {String content = 'hi', int senderId = 1}) =>
    ChatMessageResponse(id: id, chatId: chatId, senderId: senderId, content: content);

RoomTenantResponse room() => RoomTenantResponse.fromJson({
  'roomId': 3,
  'title': 'Quiet room near campus',
  'roomNumber': 'A-2',
  'rent': 4500,
  'images': ['rooms/a.jpg'],
});

void main() {
  late MockChatRepository chats;
  late MockFileRepository files;
  late MockTenantRepository tenant;
  late MockUnreadCountRepository unread;
  late MockSessionManager session;
  late StreamController<ChatMessageResponse> live;

  setUpAll(registerFallbacks);

  setUp(() {
    chats = MockChatRepository();
    files = MockFileRepository();
    tenant = MockTenantRepository();
    unread = MockUnreadCountRepository();
    session = MockSessionManager();
    live = StreamController<ChatMessageResponse>.broadcast();

    when(() => session.user).thenReturn(User(id: 1, fullName: 'Me'));
    when(() => chats.liveMessage(chatId)).thenAnswer((_) => live.stream);
    when(() => chats.markRead(chatId)).thenAnswer((_) async {});
    when(() => unread.updateChatCount()).thenAnswer((_) async {});
    when(() => chats.messages(chatId)).thenAnswer(
      (_) async => ApiSuccess(PageResponse(content: [message(3), message(2), message(1)])),
    );
    when(() => chats.list(0)).thenAnswer(
      (_) async =>
          const ApiSuccess(PageResponse(content: [ChatResponse(id: chatId, contextId: 3)])),
    );
    when(() => tenant.findRoom(3)).thenAnswer((_) async => ApiSuccess(room()));
  });

  tearDown(() => live.close());

  Future<ConversationViewModel> create() async {
    final vm = ConversationViewModel(
      chatId: chatId,
      repo: chats,
      files: files,
      tenant: tenant,
      unreadRepo: unread,
      session: session,
    );
    await settle();
    return vm;
  }

  List<int> ids(ConversationViewModel vm) => vm.loader.items.map((m) => m.id).toList();

  test('shows messages oldest first and marks the chat as read', () async {
    final vm = await create();

    expect(ids(vm), [1, 2, 3]);
    verify(() => chats.markRead(chatId)).called(1);
    verify(() => unread.updateChatCount()).called(1);
    expect(vm.me?.id, 1);
    vm.dispose();
  });

  test('loads the room bar from the chat context', () async {
    final vm = await create();

    expect(vm.roomBar?.title, 'Quiet room near campus');
    verify(() => tenant.findRoom(3)).called(1);
    vm.dispose();
  });

  test('skips the room bar when the chat is not in the first page', () async {
    when(() => chats.list(0)).thenAnswer((_) async => const ApiSuccess(PageResponse()));

    final vm = await create();

    expect(vm.roomBar, isNull);
    verifyNever(() => tenant.findRoom(any()));
    vm.dispose();
  });

  group('send', () {
    test('trims the text and appends the sent message', () async {
      when(() => chats.send(chatId, 'hello')).thenAnswer((_) async => ApiSuccess(message(4)));
      final vm = await create();

      final sending = vm.send('  hello  ', onError: (_) => fail('no error expected'));
      expect(vm.sending, isTrue);
      await sending;

      expect(vm.sending, isFalse);
      expect(ids(vm), [1, 2, 3, 4]);
      vm.dispose();
    });

    test('ignores blank text', () async {
      final vm = await create();

      await vm.send('   ', onError: (_) {});

      verifyNever(() => chats.send(any(), any()));
      vm.dispose();
    });

    test('reports the error and keeps the list as it was', () async {
      when(() => chats.send(chatId, 'hello'))
          .thenAnswer((_) async => const ApiError('Chat is closed'));
      final vm = await create();
      String? error;

      await vm.send('hello', onError: (msg) => error = msg);

      expect(error, 'Chat is closed');
      expect(ids(vm), [1, 2, 3]);
      expect(vm.sending, isFalse);
      vm.dispose();
    });
  });

  group('live messages', () {
    test('are appended once even if they arrive twice', () async {
      final vm = await create();

      live
        ..add(message(4, senderId: 2))
        ..add(message(4, senderId: 2));
      await settle();

      expect(ids(vm), [1, 2, 3, 4]);
      // once for the initial load, once per incoming event
      verify(() => chats.markRead(chatId)).called(3);
      vm.dispose();
    });

    test('do not duplicate a message we just sent', () async {
      when(() => chats.send(chatId, 'hello')).thenAnswer((_) async => ApiSuccess(message(4)));
      final vm = await create();

      await vm.send('hello', onError: (_) {});
      live.add(message(4));
      await settle();

      expect(ids(vm), [1, 2, 3, 4]);
      vm.dispose();
    });

    test('stop after dispose', () async {
      final vm = await create();
      expect(live.hasListener, isTrue);

      vm.dispose();

      expect(live.hasListener, isFalse);
    });
  });

  group('sendImage', () {
    final picked = XFile('photo.jpg');

    test('uploads to the chat folder and sends an image message', () async {
      when(() => files.upload(picked, 'chat'))
          .thenAnswer((_) async => const ApiSuccess('chat/p.jpg'));
      when(() => chats.sendBody(chatId, any())).thenAnswer(
        (_) async => const ApiSuccess(
          ChatMessageResponse(id: 9, type: MessageType.IMAGE, attachmentUrl: 'chat/p.jpg'),
        ),
      );
      final vm = await create();

      await vm.sendImage(picked, onError: (_) => fail('no error expected'));

      final body =
          verify(() => chats.sendBody(chatId, captureAny())).captured.single as SendMessageRequest;
      expect(body.type, MessageType.IMAGE);
      expect(body.attachmentUrl, 'chat/p.jpg');
      expect(ids(vm), [1, 2, 3, 9]);
      expect(vm.uploading, isFalse);
      vm.dispose();
    });

    test('reports a failed upload without sending anything', () async {
      when(() => files.upload(picked, 'chat'))
          .thenAnswer((_) async => const ApiError('Images must be under 5MB.'));
      final vm = await create();
      final errors = <String>[];

      final upload = vm.sendImage(picked, onError: errors.add);
      expect(vm.uploading, isTrue);
      await upload;

      expect(errors, ['Images must be under 5MB.']);
      expect(vm.uploading, isFalse);
      expect(ids(vm), [1, 2, 3]);
      verifyNever(() => chats.sendBody(any(), any()));
      vm.dispose();
    });

    test('reports a failed send after a successful upload', () async {
      when(() => files.upload(picked, 'chat'))
          .thenAnswer((_) async => const ApiSuccess('chat/p.jpg'));
      when(() => chats.sendBody(chatId, any()))
          .thenAnswer((_) async => const ApiError('Something went wrong'));
      final vm = await create();
      final errors = <String>[];

      await vm.sendImage(picked, onError: errors.add);

      expect(errors, ['Something went wrong']);
      expect(ids(vm), [1, 2, 3]);
      vm.dispose();
    });
  });
}
