import '../../common/json.dart';

class FileResponse {
  const FileResponse({required this.contentType, required this.fileKey, required this.size});

  final String contentType;
  final String fileKey;
  final int size;

  factory FileResponse.fromJson(Json json) => FileResponse(
    contentType: asString(json['contentType']),
    fileKey: asString(json['fileKey']),
    size: asInt(json['size']),
  );
}
