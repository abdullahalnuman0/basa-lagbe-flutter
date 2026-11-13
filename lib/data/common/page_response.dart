import 'json.dart';

class PageResponse<T> {
  const PageResponse({
    this.content = const [],
    this.page = 0,
    this.size = 10,
    this.totalElements = 0,
    this.totalPages = 0,
    this.last = true,
  });

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  factory PageResponse.fromJson(Json json, T Function(Json) item) => PageResponse(
    content: asList(json['content'], item),
    page: asInt(json['page']),
    size: asInt(json['size'], 10),
    totalElements: asInt(json['totalElements']),
    totalPages: asInt(json['totalPages']),
    last: asBool(json['last'], true),
  );

  PageResponse<T> copyWith({List<T>? content}) => PageResponse(
    content: content ?? this.content,
    page: page,
    size: size,
    totalElements: totalElements,
    totalPages: totalPages,
    last: last,
  );
}
