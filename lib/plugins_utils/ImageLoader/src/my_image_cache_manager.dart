// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/address.dart';
import 'decrypt_image.dart';

const imageDecryptPathHeader = 'x-image-decrypt-path';

class MyImageCacheManager extends CacheManager {
  static const key = "customCacheV3";
  static const maxMemoryCacheSize = 100; // 最大内存缓存数量

  static final MyImageCacheManager _instance = MyImageCacheManager._();

  factory MyImageCacheManager() {
    return _instance;
  }

  // 内存缓存
  final _memoryCache = <String, Uint8List>{};
  final _memoryCacheOrder = <String>[];

  MyImageCacheManager._()
      : super(Config(key,
      maxNrOfCacheObjects: 388,
      stalePeriod: const Duration(days: 7),
      fileService: CustomFileResponse()));

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return path.join(directory.path, key);
  }

  // 预加载图片
  Future<void> preloadImage(String url) async {
    final decryptPath = url;
    if (!url.startsWith("http") && !url.startsWith("https")) {
      String imgCdn = Address.imgCdn ?? "";
      url = path.join(imgCdn, url);
    }

    final cacheKey = _cacheKey(url, decryptPath);
    if (_memoryCache.containsKey(cacheKey)) return;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = await decryptImage({
          "imgBytes": response.bodyBytes,
          "path": decryptPath,
          "url": url,
        });
        _addToMemoryCache(cacheKey, bytes);
      }
    } catch (e) {
      debugPrint('预加载图片失败: $e');
    }
  }

  // 添加到内存缓存
  void _addToMemoryCache(String url, Uint8List bytes) {
    if (_memoryCache.length >= maxMemoryCacheSize) {
      // 移除最旧的缓存
      final oldestUrl = _memoryCacheOrder.removeAt(0);
      _memoryCache.remove(oldestUrl);
    }

    _memoryCache[url] = bytes;
    _memoryCacheOrder.add(url);
  }

  // 从内存缓存获取
  Uint8List? getFromMemoryCache(String url) {
    if (_memoryCache.containsKey(url)) {
      // 更新访问顺序
      _memoryCacheOrder.remove(url);
      _memoryCacheOrder.add(url);
      return _memoryCache[url];
    }
    return null;
  }

  // 清除内存缓存
  void clearMemoryCache() {
    _memoryCache.clear();
    _memoryCacheOrder.clear();
  }

  String _cacheKey(String url, String decryptPath) => "$url::$decryptPath";
}

class CustomFileResponse extends HttpFileService {
  final http.Client _httpClient = http.Client();

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers = const {}}) async {
    final requestHeaders = Map<String, String>.from(headers ?? {});
    final decryptPath = requestHeaders.remove(imageDecryptPathHeader) ?? url;
    if (!url.startsWith("http") && !url.startsWith("https")) {
      String imgCdn = Address.imgCdn ?? "";
      url = path.join(imgCdn, url);
    }

    // 检查内存缓存
    final cacheManager = MyImageCacheManager();
    final cacheKey = cacheManager._cacheKey(url, decryptPath);
    final cachedBytes = cacheManager.getFromMemoryCache(cacheKey);
    if (cachedBytes != null) {
      return HttpGetResponse(StreamedResponse(
        Stream.fromFuture(Future.value(cachedBytes)),
        200,
        contentLength: cachedBytes.length,
        request: http.Request('GET', Uri.parse(url)),
        headers: requestHeaders,
      ));
    }

    final response = http.Request('GET', Uri.tryParse(url)!);
    requestHeaders['cache-control'] = 'max-age=31104000';
    response.headers.addAll(requestHeaders);
    final httpResponse = await _httpClient.send(response);

    var stream = await httpResponse.stream.toBytes();
    final decryptedBytes = await decryptImage({
      "imgBytes": stream,
      "path": decryptPath,
      "url": url,
    });

    // 添加到内存缓存
    cacheManager._addToMemoryCache(cacheKey, decryptedBytes);

    StreamedResponse streamedResponse = StreamedResponse(
        Stream.fromFuture(Future.value(decryptedBytes)),
        httpResponse.statusCode,
        contentLength: decryptedBytes.length,
        request: httpResponse.request,
        headers: httpResponse.headers,
        isRedirect: httpResponse.isRedirect,
        persistentConnection: httpResponse.persistentConnection,
        reasonPhrase: httpResponse.reasonPhrase);

    return HttpGetResponse(streamedResponse);
  }
}