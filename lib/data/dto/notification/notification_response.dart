import '../../common/json.dart';
import '../../enums/enums.dart';

class NotificationResponse {
  const NotificationResponse({
    this.id = 0,
    this.title = '',
    this.body,
    this.type = '',
    this.read = false,
    this.refType,
    this.refId,
    this.createdAt,
  });

  final int id;
  final String title;
  final String? body;
  final String type;
  final bool read;
  final NotyRefType? refType;
  final int? refId;
  final String? createdAt;

  factory NotificationResponse.fromJson(Json json) => NotificationResponse(
    id: asInt(json['id']),
    title: asString(json['title']),
    body: asStringOrNull(json['body']),
    type: asString(json['type']),
    read: asBool(json['read']),
    refType: enumByNameOrNull(NotyRefType.values, json['refType']),
    refId: json['refId'] == null ? null : asInt(json['refId']),
    createdAt: asStringOrNull(json['createdAt']),
  );

  NotificationResponse copyWith({bool? read}) => NotificationResponse(
    id: id,
    title: title,
    body: body,
    type: type,
    read: read ?? this.read,
    refType: refType,
    refId: refId,
    createdAt: createdAt,
  );
}
