// 📦 Package imports:
import 'package:dio/dio.dart';

class DioClient {
  // 创建一个 Dio 实例
  static final Dio _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10), // 连接超时
      receiveTimeout: const Duration(seconds: 10), // 接收超时
      headers: {
        'Content-Type': 'application/json',
        // 添加其他默认头部
      }));

  // 提供一个获取 Dio 实例的方法
  static Dio get dio => _dio;
}
