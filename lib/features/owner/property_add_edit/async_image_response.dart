import 'package:image_picker/image_picker.dart';

sealed class AsyncImageResponse {
  const AsyncImageResponse(this.index, this.file);

  final int index;
  final XFile file;
}

final class AsyncImageSuccess extends AsyncImageResponse {
  const AsyncImageSuccess(super.index, super.file, this.fileKey);

  final String fileKey;
}

final class AsyncImageError extends AsyncImageResponse {
  const AsyncImageError(super.index, super.file, this.message);

  final String message;
}
