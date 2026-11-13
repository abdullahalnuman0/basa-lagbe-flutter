import 'package:flutter/foundation.dart';

import '../../../data/common/page_response.dart';
import '../../network/api_result.dart';

sealed class UiState<T> {
  const UiState();
}

final class UiLoading<T> extends UiState<T> {
  const UiLoading();
}

final class UiError<T> extends UiState<T> {
  const UiError(this.message);

  final String message;
}

final class UiSuccess<T> extends UiState<T> {
  const UiSuccess(this.data);

  final T data;
}

class PageLoader<T> extends ChangeNotifier {
  PageLoader(this._fetch);

  final Future<ApiResult<PageResponse<T>>> Function(int page) _fetch;

  UiState<List<T>> _state = const UiLoading();
  bool _refreshing = false;
  bool _appending = false;
  String? _error;

  int _page = 0;
  bool _last = false;
  int _generation = 0;
  bool _disposed = false;

  UiState<List<T>> get state => _state;

  bool get refreshing => _refreshing;

  bool get appending => _appending;

  String? get error => _error;

  List<T> get items => switch (_state) {
    UiSuccess(:final data) => data,
    _ => const [],
  };

  bool get endReached => _last;

  void loadFirst() {
    final gen = ++_generation;
    _state = const UiLoading();
    _page = 0;
    _last = false;
    _notify();
    _fetchInto(true, gen);
  }

  Future<void> refresh() async {
    final gen = ++_generation;
    _refreshing = true;
    _page = 0;
    _last = false;
    _notify();
    await _fetchInto(true, gen);
    if (gen == _generation) {
      _refreshing = false;
      _notify();
    }
  }

  Future<void> loadMore() async {
    if (_last || _appending || _refreshing || _state is! UiSuccess) return;
    final gen = _generation;
    _appending = true;
    _page += 1;
    _notify();
    await _fetchInto(false, gen);
    _appending = false;
    _notify();
  }

  void consumeError() {
    _error = null;
  }

  void mutate(List<T> Function(List<T> current) transform) {
    final current = _state;
    if (current is UiSuccess<List<T>>) {
      _state = UiSuccess(transform(current.data));
      _notify();
    }
  }

  Future<void> _fetchInto(bool replace, int gen) async {
    final r = await _fetch(_page);
    if (_disposed || gen != _generation) return;
    switch (r) {
      case ApiError(:final message):
        if (_state is UiSuccess) {
          // keep what's on screen; report the failure
          if (!replace) _page -= 1;
          _error = message;
        } else {
          _state = UiError(message);
        }
      case ApiSuccess(:final data):
        _last = data.last;
        _state = UiSuccess(replace ? data.content : [...items, ...data.content]);
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
