import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/widgets/page_loader.dart';
import 'package:messseat/data/common/page_response.dart';

class FakeSource {
  final pages = <int, ApiResult<PageResponse<int>>>{};
  final calls = <int>[];

  Future<ApiResult<PageResponse<int>>> fetch(int page) async {
    calls.add(page);
    return pages[page] ?? const ApiError('missing page');
  }

  void page(int index, List<int> items, {bool last = false}) =>
      pages[index] = ApiSuccess(PageResponse(content: items, page: index, last: last));
}

void main() {
  late FakeSource source;
  late PageLoader<int> loader;

  setUp(() {
    source = FakeSource();
    loader = PageLoader(source.fetch);
  });

  tearDown(() => loader.dispose());

  test('loadFirst goes from loading to success', () async {
    source.page(0, [1, 2, 3]);
    loader.loadFirst();
    expect(loader.state, isA<UiLoading<List<int>>>());

    await pumpEventQueue();
    expect(loader.items, [1, 2, 3]);
    expect(loader.endReached, isFalse);
  });

  test('first page failure becomes an error state', () async {
    loader.loadFirst();
    await pumpEventQueue();
    expect(loader.state, isA<UiError<List<int>>>());
    expect((loader.state as UiError).message, 'missing page');
  });

  test('loadMore appends and stops at the last page', () async {
    source
      ..page(0, [1, 2])
      ..page(1, [3], last: true);
    loader.loadFirst();
    await pumpEventQueue();

    await loader.loadMore();
    expect(loader.items, [1, 2, 3]);
    expect(loader.endReached, isTrue);

    await loader.loadMore();
    expect(source.calls, [0, 1]);
  });

  test('a failed loadMore keeps the list and reports once', () async {
    source.page(0, [1]);
    loader.loadFirst();
    await pumpEventQueue();

    await loader.loadMore();
    expect(loader.items, [1]);
    expect(loader.error, 'missing page');
    loader.consumeError();
    expect(loader.error, isNull);

    source.page(1, [2], last: true);
    await loader.loadMore();
    expect(source.calls, [0, 1, 1]);
    expect(loader.items, [1, 2]);
  });

  test('refresh replaces the content', () async {
    source.page(0, [1, 2]);
    loader.loadFirst();
    await pumpEventQueue();

    source.page(0, [9]);
    final refreshing = loader.refresh();
    expect(loader.refreshing, isTrue);
    await refreshing;
    expect(loader.refreshing, isFalse);
    expect(loader.items, [9]);
  });

  test('mutate only applies to loaded data', () async {
    loader.mutate((l) => [...l, 1]);
    expect(loader.items, isEmpty);

    source.page(0, [1, 2]);
    loader.loadFirst();
    await pumpEventQueue();
    loader.mutate((l) => l.where((e) => e != 1).toList());
    expect(loader.items, [2]);
  });

  test('a stale response is ignored after a newer load', () async {
    final slow = Completer<ApiResult<PageResponse<int>>>();
    var first = true;
    final loader = PageLoader<int>((page) {
      if (first) {
        first = false;
        return slow.future;
      }
      return Future.value(const ApiSuccess(PageResponse(content: [2], last: true)));
    });

    loader.loadFirst();
    loader.loadFirst();
    await pumpEventQueue();
    slow.complete(const ApiSuccess(PageResponse(content: [1], last: true)));
    await pumpEventQueue();

    expect(loader.items, [2]);
    loader.dispose();
  });
}
