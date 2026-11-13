import '../../common/json.dart';
import '../../enums/enums.dart';

class ChatResponse {
  const ChatResponse({
    this.id = 0,
    this.contextId = 0,
    this.otherUserId = 0,
    this.otherUserName = '',
    this.otherUserAvatarUrl,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.createdAt,
  });

  final int id;
  final int contextId;
  final int otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final String? lastMessagePreview;
  final String? lastMessageAt;
  final int unreadCount;
  final String? createdAt;

  factory ChatResponse.fromJson(Json json) => ChatResponse(
    id: asInt(json['id']),
    contextId: asInt(json['contextId']),
    otherUserId: asInt(json['otherUserId']),
    otherUserName: asString(json['otherUserName']),
    otherUserAvatarUrl: asStringOrNull(json['otherUserAvatarUrl']),
    lastMessagePreview: asStringOrNull(json['lastMessagePreview']),
    lastMessageAt: asStringOrNull(json['lastMessageAt']),
    unreadCount: asInt(json['unreadCount']),
    createdAt: asStringOrNull(json['createdAt']),
  );
}

class ChatMessageResponse {
  const ChatMessageResponse({
    this.id = 0,
    this.chatId = 0,
    this.senderId = 0,
    this.senderName = '',
    this.content,
    this.type = MessageType.TEXT,
    this.attachmentUrl,
    this.read = false,
    this.createdAt,
  });

  final int id;
  final int chatId;
  final int senderId;
  final String senderName;
  final String? content;
  final MessageType type;
  final String? attachmentUrl;
  final bool read;
  final String? createdAt;

  factory ChatMessageResponse.fromJson(Json json) => ChatMessageResponse(
    id: asInt(json['id']),
    chatId: asInt(json['chatId']),
    senderId: asInt(json['senderId']),
    senderName: asString(json['senderName']),
    content: asStringOrNull(json['content']),
    type: enumByName(MessageType.values, json['type'], MessageType.TEXT),
    attachmentUrl: asStringOrNull(json['attachmentUrl']),
    read: asBool(json['read']),
    createdAt: asStringOrNull(json['createdAt']),
  );
}

class OpenChatRequest {
  const OpenChatRequest(this.contextId);

  final int contextId;

  Json toJson() => {'contextId': contextId};
}

class SendMessageRequest {
  const SendMessageRequest({this.content, this.type = MessageType.TEXT, this.attachmentUrl});

  final String? content;
  final MessageType type;
  final String? attachmentUrl;

  Json toJson() => {'content': content, 'type': type.name, 'attachmentUrl': attachmentUrl};
}
