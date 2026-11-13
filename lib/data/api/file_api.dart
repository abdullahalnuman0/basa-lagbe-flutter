import 'package:dio/dio.dart';

import '../common/json.dart';
import '../dto/file/file_response.dart';

class FileApi {
  FileApi(this._dio);

  final Dio _dio;

  Future<FileResponse> upload(MultipartFile file, String? folder) async {
    final res = await _dio.post<Json>(
      'files',
      data: FormData.fromMap({'file': file}),
      queryParameters: {'folder': ?folder},
    );
    return FileResponse.fromJson(res.data!);
  }

  Future<void> delete(String fileKey) async {
    await _dio.delete<dynamic>('files', queryParameters: {'fileKey': fileKey});
  }

  Future<void> deleteAll(List<String> fileKeys) async {
    await _dio.delete<dynamic>('files/batch', data: fileKeys);
  }
}
