import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/presentation/widgets/page_loader.dart';
import 'package:messseat/data/common/page_response.dart';
import 'package:messseat/data/dto/property/property_dtos.dart';
import 'package:messseat/data/repository/property_repository.dart';
import 'package:messseat/features/owner/listings/listings_view_model.dart';
import 'package:mocktail/mocktail.dart';

import '../home/fixtures.dart';

class MockPropertyRepository extends Mock implements PropertyRepository {}

PageResponse<PropertyResponse> page(List<PropertyResponse> content, {bool last = false}) {
  return PageResponse(
    content: content,
    page: 0,
    size: 10,
    totalElements: content.length,
    totalPages: 1,
    last: last,
  );
}

void main() {
  late MockPropertyRepository repo;

  setUpAll(() => registerFallbackValue(<String, String>{}));

  setUp(() => repo = MockPropertyRepository());

  test('loads the first page with the feed page size', () async {
    when(() => repo.findPage(any())).thenAnswer((_) async => ApiSuccess(page([property()])));

    final vm = ListingsViewModel(repo);
    expect(vm.properties.state, isA<UiLoading<List<PropertyResponse>>>());
    await pumpEventQueue();

    expect(vm.properties.items, hasLength(1));
    verify(() => repo.findPage({'page': '0', 'size': '10'})).called(1);
  });

  test('loadMore asks for the next page and appends it', () async {
    when(() => repo.findPage({'page': '0', 'size': '10'}))
        .thenAnswer((_) async => ApiSuccess(page([property(id: 1)])));
    when(() => repo.findPage({'page': '1', 'size': '10'}))
        .thenAnswer((_) async => ApiSuccess(page([property(id: 2)], last: true)));

    final vm = ListingsViewModel(repo);
    await pumpEventQueue();
    await vm.properties.loadMore();

    expect(vm.properties.items.map((p) => p.id), [1, 2]);
    expect(vm.properties.endReached, isTrue);
  });

  test('surfaces the error of the first page', () async {
    when(() => repo.findPage(any())).thenAnswer((_) async => const ApiError('Server down'));

    final vm = ListingsViewModel(repo);
    await pumpEventQueue();

    final state = vm.properties.state;
    expect(state, isA<UiError<List<PropertyResponse>>>());
    expect((state as UiError).message, 'Server down');
  });
}
