import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:messseat/core/di/locator.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/chat/chat_dtos.dart';
import 'package:messseat/data/repository/chat_repository.dart';
import 'package:messseat/domain/model/user.dart';
import 'package:messseat/features/shared/chat/chat_screen.dart';
import 'package:messseat/main_view_model.dart';
import 'package:messseat/ui/theme/theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';

void main() {
  late MockChatRepository repo;
  late MockMainViewModel main;

  setUp(() {
    repo = MockChatRepository();
    main = MockMainViewModel();
    when(() => main.user).thenReturn(User(id: 1, fullName: 'Tanvir Ahmed', email: 't@mail.com'));
    when(() => main.unreadNotification).thenReturn(0);
    locator.registerSingleton<ChatRepository>(repo);
  });

  tearDown(() => locator.reset());

  Widget app() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: ChatScreen()),
        ),
        GoRoute(
          path: '/conversation/:id',
          builder: (_, state) => Text('conversation ${state.pathParameters['id']}'),
        ),
      ],
    );
    return ChangeNotifierProvider<MainViewModel>.value(
      value: main,
      child: MaterialApp.router(theme: lightTheme, routerConfig: router),
    );
  }

  testWidgets('lists chats and opens the conversation on tap', (tester) async {
    when(() => repo.list(0)).thenAnswer(
      (_) async => const ApiSuccess(
        PageResponse(
          content: [
            ChatResponse(
              id: 12,
              otherUserName: 'Sadia Islam',
              lastMessagePreview: 'Is the seat still free?',
              unreadCount: 2,
            ),
            ChatResponse(id: 13, otherUserName: 'Imran Hossain'),
          ],
        ),
      ),
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Sadia Islam'), findsOneWidget);
    expect(find.text('Is the seat still free?'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('New chat'), findsOneWidget);

    await tester.tap(find.text('Sadia Islam'));
    await tester.pumpAndSettle();

    expect(find.text('conversation 12'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no chats', (tester) async {
    when(() => repo.list(0)).thenAnswer((_) async => const ApiSuccess(PageResponse()));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('No chats yet'), findsOneWidget);
  });
}
