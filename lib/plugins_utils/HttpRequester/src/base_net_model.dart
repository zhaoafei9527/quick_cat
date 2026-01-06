/// It's a base class for all network models
abstract class BaseNetModel {
  dynamic fromJson(Map<String, dynamic> json);
}

/// future 扔出的异常
class ApiException implements Exception {
  int? code = -200;
  String? message;

  ApiException([this.code, this.message]);

  @override
  String toString() {
    if (message == null) return "ApiException:code:$code";
    return "ApiException:code:$code message:$message";
  }
}
