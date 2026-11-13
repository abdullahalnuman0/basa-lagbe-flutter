import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_result.dart';
import '../../core/network/safe_api_call.dart';
import '../../core/utils/app_properties.dart';
import '../api/file_api.dart';

class FileRepository {
  FileRepository(this._api);

  final FileApi _api;

  static const roomDefaultImage = 'assets/images/room_default_image.png';

  Future<ApiResult<String>> upload(XFile file, String folder) async {
    final List<int> bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      return const ApiError("Couldn't read that file.");
    }
    if (bytes.length > AppProperties.maxFileUploadBytes) {
      return const ApiError('Images must be under ${AppProperties.maxFileUploadSize}MB.');
    }

    final name = file.name.isNotEmpty ? file.name.split('/').last : 'upload.jpeg';
    final part = MultipartFile.fromBytes(
      bytes,
      filename: name,
      contentType: DioMediaType.parse(file.mimeType ?? _mimeFor(name)),
    );

    final r = await safeApiCall(() => _api.upload(part, folder));
    return switch (r) {
      ApiSuccess(:final data) => ApiSuccess(data.fileKey),
      ApiError() => r.cast<String>(),
    };
  }

  Future<ApiResult<void>> delete(String fileKey) => safeApiCall(() => _api.delete(fileKey));

  Future<ApiResult<void>> deleteAll(List<String> fileKeys) =>
      safeApiCall(() => _api.deleteAll(fileKeys));

  static String _mimeFor(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }
}
