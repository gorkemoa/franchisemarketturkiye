class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResult.success(this.data, {this.statusCode}) : error = null;
  ApiResult.failure(this.error, {this.statusCode}) : data = null;

  bool get isSuccess => error == null;
}
