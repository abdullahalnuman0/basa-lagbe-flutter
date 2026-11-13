sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

final class ApiError<T> extends ApiResult<T> {
  const ApiError(this.message, {this.code, this.status});

  final String message;
  final String? code;
  final int? status;

  ApiError<R> cast<R>() => ApiError<R>(message, code: code, status: status);
}
