import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/light_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../../app/model/home/topic_list_model.dart';
import '../../../app/model/home/video_play_model.dart';

/// 缓存事件
class CacheEvent {
  final double progress; // 缓存进度 0.0~1.0
  final int downloadedBytes; // 已下载字节
  final int downloadedSegments; // 已缓存分片数量
  final double speedKBps; // 下载速度 KB/s

  CacheEvent({
    required this.progress,
    required this.downloadedBytes,
    required this.downloadedSegments,
    required this.speedKBps,
  });

  @override
  String toString() => "progress=${(progress * 100).toStringAsFixed(1)}% "
      "bytes=$downloadedBytes "
      "segments=$downloadedSegments "
      "speed=${speedKBps.toStringAsFixed(1)}KB/s";
}

class M3u8CacheManager {
  static final M3u8CacheManager _instance = M3u8CacheManager._internal();

  factory M3u8CacheManager() => _instance;

  M3u8CacheManager._internal();

  // 使用自定义文件系统，确保缓存存储在应用程序文档目录
  late final CacheManager _cacheManager;
  bool _cacheManagerInitialized = false;

  // 初始化缓存管理器
  Future<void> _initCacheManager() async {
    if (_cacheManagerInitialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _cacheManager = CacheManager(Config(
      'M3u8Segments',
      // 1年，接近永久
      stalePeriod: const Duration(days: 30),
      // 增加缓存容量
      maxNrOfCacheObjects: 5000,
      repo: JsonCacheInfoRepository(databaseName: 'M3u8Segments'),
      fileSystem: IOFileSystem('${dir.path}/M3u8Segments'),
      fileService: HttpFileService(),
    ));

    _cacheManagerInitialized = true;
  }

  HttpServer? _server;
  String? _proxyBaseUrl;

  // 每个URL的下载任务
  final Map<String, _DownloadTask> _urlToTask = {};

  // 运行期内存映射：mediaId -> 缓存信息
  final Map<int, VideoCacheInfo> _videoCacheInfo = {};

  // 运行期内存映射：标准化 url -> mediaId（便于 stop 反查 mediaId）
  final Map<String, int> _urlToMediaId = {};

  // 可选媒体元数据：title/cover，来源于 prepare 时传入的 MediaInfo
  final Map<int, Map<String, String?>> _mediaMeta = {};

  // 持久化 key
  static const String _kvPrefix = 'video_cache_info_';
  static const String _kvIndexKey = 'video_cache_index';

  Future<void> _persistVideoCacheInfo(VideoCacheInfo info) async {
    await lightKV.setString(
        '$_kvPrefix${info.mediaId}', jsonEncode(info.toJson()));
  }

  Future<void> _removeVideoCacheInfo(int mediaId) async {
    await lightKV.remove('$_kvPrefix$mediaId');
  }

  Future<VideoCacheInfo?> _readVideoCacheInfo(int mediaId) async {
    final s = await lightKV.getString('$_kvPrefix$mediaId');
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return VideoCacheInfo.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<List<int>> _readIndex() async {
    final list = await lightKV.getStringList(_kvIndexKey);
    if (list.isEmpty) return [];
    return list.map((e) => int.tryParse(e)).whereType<int>().toList();
  }

  Future<void> _writeIndex(List<int> ids) async {
    // 简单去重并限制上限（可选：LRU 策略，这里仅截断）
    final set = <int>{};
    final dedup = <int>[];
    for (final id in ids) {
      if (set.add(id)) dedup.add(id);
    }
    await lightKV.setStringList(
        _kvIndexKey, dedup.map((e) => e.toString()).toList());
  }

  Future<void> _addToIndex(int mediaId) async {
    final ids = await _readIndex();
    if (!ids.contains(mediaId)) {
      ids.add(mediaId);
      await _writeIndex(ids);
    }
  }

  Future<void> _removeFromIndex(int mediaId) async {
    final ids = await _readIndex();
    if (ids.remove(mediaId)) {
      await _writeIndex(ids);
    }
  }

  /// 启动本地代理
  Future<void> _startProxy({int port = 8888}) async {
    if (_server != null) return;
    handler(Request request) async {
      final path = request.url.path; // e.g. playlist/{id} 或 seg
      try {
        if (path.startsWith('playlist/')) {
          final id = path.substring('playlist/'.length);
          final task = _urlToTask.values.firstWhere(
            (t) => t.taskId == id,
            orElse: () => throw StateError('playlist not found'),
          );
          // 如果未就绪，阻塞等待一小会儿
          if (task.rewrittenPlaylistContent == null) {
            try {
              await task.waitForPlaylistReady(
                  timeout: const Duration(seconds: 5));
            } catch (_) {}
          }
          final content = task.rewrittenPlaylistContent;
          if (content == null) {
            return Response.internalServerError(body: 'playlist not ready');
          }
          return Response.ok(
            utf8.encode(content),
            headers: {
              HttpHeaders.contentTypeHeader: 'application/vnd.apple.mpegurl',
            },
          );
        }

        if (path == 'seg') {
          final encodedUrl = request.url.queryParameters['url'];
          if (encodedUrl == null) {
            return Response.badRequest(body: 'missing url');
          }
          final originUrl = Uri.decodeFull(encodedUrl);
          log.i("_cache_manager", "处理 ts 请求: $originUrl");

          // 判断缓存命中
          bool cacheHit = false;
          File file;
          try {
            await _initCacheManager();
            final fi = await _cacheManager.getFileFromCache(originUrl);
            if (fi != null && await fi.file.exists()) {
              cacheHit = true;
              file = fi.file;
              log.i("_cache_manager", "缓存命中: ${file.path}");
            } else {
              log.i("_cache_manager", "缓存未命中，开始下载: $originUrl");
              file = await _cacheManager.getSingleFile(originUrl);
              log.i("_cache_manager", "下载完成: ${file.path}");
            }
          } catch (e) {
            log.e("_cache_manager", "获取文件失败: $originUrl, 错误: $e");
            await _initCacheManager();
            file = await _cacheManager.getSingleFile(originUrl);
          }

          // 处理 Range 请求，支持 BYTERANGE 片段
          final rangeHeader = request.headers[HttpHeaders.rangeHeader];
          final totalLen = await file.length();
          final contentType = _guessMimeType(originUrl);

          log.i("_cache_manager", "文件大小: $totalLen, 类型: $contentType");

          if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
            // 解析 bytes=start-end（end 可选）
            final range = rangeHeader.substring('bytes='.length).split('-');
            final start = int.tryParse(range[0]) ?? 0;
            final end = range.length > 1 && range[1].isNotEmpty
                ? int.tryParse(range[1]) ?? (totalLen - 1)
                : (totalLen - 1);
            final clampedStart = start.clamp(0, totalLen - 1);
            final clampedEnd = end.clamp(clampedStart, totalLen - 1);

            // 统计更新使用区间大小
            final task = _findTaskBySegment(originUrl);
            if (task != null) {
              final partLen = (clampedEnd - clampedStart + 1);
              task.downloadedBytes += partLen;
              task.downloadedSegments += 1;
            }

            return Response(
              206,
              body: file.openRead(clampedStart, clampedEnd + 1),
              headers: {
                HttpHeaders.acceptRangesHeader: 'bytes',
                HttpHeaders.contentTypeHeader: contentType,
                HttpHeaders.contentLengthHeader:
                    (clampedEnd - clampedStart + 1).toString(),
                HttpHeaders.contentRangeHeader:
                    'bytes $clampedStart-$clampedEnd/$totalLen',
                'X-Cache': cacheHit ? 'HIT' : 'MISS',
              },
            );
          }

          // 非 Range 全量返回
          final task = _findTaskBySegment(originUrl);
          if (task != null) {
            task.downloadedBytes += totalLen;
            task.downloadedSegments += 1;
          }
          return Response.ok(
            file.openRead(),
            headers: {
              HttpHeaders.acceptRangesHeader: 'bytes',
              HttpHeaders.contentTypeHeader: contentType,
              HttpHeaders.contentLengthHeader: totalLen.toString(),
              'X-Cache': cacheHit ? 'HIT' : 'MISS',
            },
          );
        }

        return Response.notFound('unknown route');
      } catch (e, stackTrace) {
        log.e("_cache_manager", "代理服务器错误: $e", stackTrace: stackTrace);
        return Response.internalServerError(body: 'error: $e');
      }
    }

    _server = await shelf_io.serve(
      logRequests().addHandler(handler),
      InternetAddress.loopbackIPv4,
      port,
    );
    _proxyBaseUrl = "http://127.0.0.1:$port";

    print("✅ Proxy started: $_proxyBaseUrl");
  }

  /// 获取代理地址
  Future<String> getProxyUrl(String originUrl) async {
    if (_server == null) {
      await _startProxy();
    }
    return "$_proxyBaseUrl/seg?url=${Uri.encodeFull(originUrl)}";
  }

  /// 传入远程m3u8，开始解析并缓存，返回可播放的本地m3u8地址
  Future<String> preparePlayableUrl(String remoteM3u8Url,
      {MediaInfo? mediaInfo}) async {
    // 非 m3u8 直连回退
    if (!remoteM3u8Url.toLowerCase().contains('.m3u8')) {
      return remoteM3u8Url;
    }

    await _ensureServer();
    final normalized = _normalizeUrl(remoteM3u8Url);

    // 如果提供了媒体信息，记录 url -> mediaId 绑定与元信息
    if (mediaInfo != null && mediaInfo.id != null) {
      _urlToMediaId[normalized] = mediaInfo.id!;
      _mediaMeta[mediaInfo.id!] = {
        'title': mediaInfo.title,
        'coverImg': mediaInfo.coverImg,
      };
    }

    var task = _urlToTask[normalized];
    if (task == null) {
      task = _DownloadTask(url: normalized, proxyBase: _proxyBaseUrl!);
      _urlToTask[normalized] = task;
      unawaited(_startDownloadTask(task, mediaInfo: mediaInfo));
    }
    await task.waitForPlaylistReady(timeout: const Duration(seconds: 5));
    return "$_proxyBaseUrl/playlist/${task.taskId}";
  }

  /// 获取进度流：既支持远程 m3u8，也支持代理可播放地址（playlist/{id} 或 seg?url=）
  Stream<CacheEvent> onUrlProgress(String urlOrProxy) {
    final task = _getTaskForUrlOrProxy(urlOrProxy);
    if (task != null) {
      return task.progressController.stream;
    }
    // 未找到任务则返回空流，避免误创建无效任务
    return const Stream.empty();
  }

  /// 暂停
  void pause(String urlOrProxy) {
    final task = _getTaskForUrlOrProxy(urlOrProxy);
    task?.pause();
  }

  /// 继续
  void resume(String urlOrProxy) {
    final task = _getTaskForUrlOrProxy(urlOrProxy);
    task?.resume();
  }

  /// 暂停全部任务
  void pauseAll() {
    for (final task in _urlToTask.values) {
      task.pause();
    }
  }

  /// 恢复全部任务
  void resumeAll() {
    for (final task in _urlToTask.values) {
      task.resume();
    }
  }

  /// 停止并清理该URL任务（不清空已下载缓存文件）
  void stop(String urlOrProxy) {
    final task = _getTaskForUrlOrProxy(urlOrProxy);
    if (task != null) {
      // 在停止时落盘当前缓存信息（若有匹配的媒体）
      final mediaId = _urlToMediaId[task.url] ?? _findMediaIdByTask(task);
      if (mediaId != null) {
        final meta = _mediaMeta[mediaId] ?? {};
        final info = VideoCacheInfo(
          mediaId: mediaId,
          title: meta['title'] ?? _videoCacheInfo[mediaId]?.title ?? '未知视频',
          coverImg: meta['coverImg'] ?? _videoCacheInfo[mediaId]?.coverImg,
          cacheTime: DateTime.now(),
          cacheSizeBytes: task.downloadedBytes,
          totalCount: task.totalSegments,
          segmentCount: task.downloadedSegments,
          originalUrl: task.url,
        );
        _videoCacheInfo[mediaId] = info;
        unawaited(_persistVideoCacheInfo(info));
        unawaited(_addToIndex(mediaId));
      }
      task.dispose();
    }
  }

  /// 停止并清理全部任务（不清空已下载缓存文件）
  void stopAll() {
    final urls = _urlToTask.keys.toList();
    for (final url in urls) {
      stop(url);
    }
  }

  /// 清空缓存
  Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final m3u8CacheDir = Directory(dir.path);
      if (await m3u8CacheDir.exists()) {
        // 删除缓存目录下的所有文件
        await for (final entity in m3u8CacheDir.list(recursive: true)) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (_) {
            // 忽略无法删除的文件/目录
          }
        }
      }
    } catch (e) {
      log.i("_cache_manager", "清空缓存失败: $e");
    }
  }

  /// 获取当前全部缓存的内存大小（MB）
  Future<double> getCacheSizeMB() async {
    try {
      int totalBytes = 0;

      // // 遍历所有活跃的下载任务，计算已下载的字节数
      // for (final task in _urlToTask.values) {
      //   totalBytes += task.downloadedBytes;
      // }

      // 如果还有缓存管理器中的文件，也计算一下
      try {
        final dir = await getApplicationDocumentsDirectory();
        final m3u8CacheDir = Directory(dir.path);
        if (await m3u8CacheDir.exists()) {
          await for (final entity in m3u8CacheDir.list(recursive: true)) {
            if (entity is File) {
              try {
                final size = await entity.length();
                totalBytes += size;
              } catch (_) {
                // 忽略无法读取的文件
              }
            }
          }
        }
      } catch (_) {
        // 如果无法访问缓存目录，只使用任务统计
      }


      return totalBytes / (1024 * 1024); // 转换为 MB
    } catch (e) {
      log.i("_cache_manager", "获取缓存大小失败: $e");
      return 0.0;
    }
  }

  /// 停止代理
  Future<void> stopProxy() async {
    await _server?.close(force: true);
    _server = null;
    for (final t in _urlToTask.values) {
      t.dispose();
    }
    _urlToTask.clear();
  }

  String _guessMimeType(String url) {
    if (url.endsWith(".m3u8")) return "application/vnd.apple.mpegurl";
    if (url.endsWith(".ts")) return "video/mp2t";
    if (url.endsWith(".mp4")) return "video/mp4";
    return "application/octet-stream";
  }

  Future<void> _ensureServer() async {
    if (_server == null) {
      await _startProxy();
    }
  }

  _DownloadTask? _findTaskBySegment(String segmentUrl) {
    // 通过前缀匹配所属playlist的host判断
    try {
      final host = Uri.parse(segmentUrl).origin;
      for (final t in _urlToTask.values) {
        if (t.sourceOrigin == host) return t;
      }
      for (final t in _urlToTask.values) {
        if (segmentUrl.contains(t.url)) return t;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  _DownloadTask? _getTaskForUrlOrProxy(String input) {
    try {
      // 1) 代理 playlist/{id}
      if (_proxyBaseUrl != null && input.startsWith(_proxyBaseUrl!)) {
        final uri = Uri.parse(input);
        if (uri.pathSegments.isNotEmpty &&
            uri.pathSegments.first == 'playlist') {
          final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
          if (id.isNotEmpty) {
            for (final t in _urlToTask.values) {
              if (t.taskId == id) return t;
            }
          }
        }
        // 2) 代理 seg?url=encoded
        if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'seg') {
          final encoded = uri.queryParameters['url'];
          if (encoded != null) {
            final origin = Uri.decodeFull(encoded);
            final t = _findTaskBySegment(origin);
            if (t != null) return t;
          }
        }
      }
      // 3) 远程 m3u8 原始地址
      final normalized = _normalizeUrl(input);
      final t = _urlToTask[normalized];
      if (t != null) return t;
    } catch (_) {}
    return null;
  }

  Future<void> _startDownloadTask(_DownloadTask task,
      {MediaInfo? mediaInfo}) async {
    try {
      // 1. 下载主m3u8
      final playlistText = await _fetchText(task.url);
      // 如果是主清单(多码率)，尽量选择第一个媒体清单
      final mediaUri = _pickMediaPlaylistUri(task.url, playlistText);
      final mediaText = mediaUri == null
          ? playlistText
          : await _fetchText(mediaUri.toString());

      final base = Uri.parse(mediaUri?.toString() ?? task.url);

      task.sourceOrigin = base.origin;

      // 2. 解析分片与key，重写为本地代理seg链接
      final lines = const LineSplitter().convert(mediaText);
      final List<String> rewritten = [];
      final List<Uri> segmentUris = [];
      bool hasEndList = false;
      bool hasPlaylistTypeVod = false;
      bool hasPlaylistTypeEvent = false;
      bool hasExtm3u = false;
      bool hasStart = false;
      for (final line in lines) {
        if (line.trim().isEmpty) {
          rewritten.add(line);

          continue;
        }
        if (line.startsWith('#')) {
          // 处理EXT-X-KEY中的URI重写
          if (line.startsWith('#EXT-X-KEY') && line.contains('URI=')) {
            final newLine = _rewriteKeyLine(line, base, _proxyBaseUrl!);
            rewritten.add(newLine);
          } else if (line.startsWith('#EXT-X-MAP') && line.contains('URI=')) {
            final newLine = _rewriteMapLine(line, base, _proxyBaseUrl!);
            rewritten.add(newLine);
          } else {
            rewritten.add(line);
          }
          if (line.startsWith('#EXT-X-ENDLIST')) hasEndList = true;
          if (line.startsWith('#EXTM3U')) hasExtm3u = true;
          if (line.startsWith('#EXT-X-PLAYLIST-TYPE')) {
            if (line.toUpperCase().contains('VOD')) hasPlaylistTypeVod = true;
            if (line.toUpperCase().contains('EVENT')) {
              hasPlaylistTypeEvent = true;
            }
          }
          if (line.startsWith('#EXT-X-START')) hasStart = true;

          continue;
        }
        // 分片相对/绝对路径
        final segUri = base.resolve(line);
        segmentUris.add(segUri);
        final local =
            "$_proxyBaseUrl/seg?url=${Uri.encodeFull(segUri.toString())}";
        rewritten.add(local);
      }

      task.totalSegments = max(1, segmentUris.length);
      // 确保含有 #EXTM3U 作为首行
      if (!hasExtm3u) {
        rewritten.insert(0, '#EXTM3U');
      }
      // 如果没有声明类型，且不是 EVENT，标记为 VOD，利于播放器识别为点播
      if (!hasPlaylistTypeVod && !hasPlaylistTypeEvent) {
        rewritten.insert(1, '#EXT-X-PLAYLIST-TYPE:VOD');
      }
      // 明确从 0 开始，减少回到起点时的关键帧等待
      if (!hasStart) {
        int insertIdx = 1;
        if (rewritten.length > 1 &&
            rewritten[1].startsWith('#EXT-X-PLAYLIST-TYPE')) {
          insertIdx = 2;
        }
        rewritten.insert(insertIdx, '#EXT-X-START:TIME-OFFSET=0');
      }
      // 如果原清单没有 ENDLIST（常见于部分服务端未补全），追加，方便播放器触发结束事件
      if (!hasEndList) {
        rewritten.add('#EXT-X-ENDLIST');
      }
      task.rewrittenPlaylistContent = rewritten.join('\n');
      // 通知playlist已就绪
      task._playlistReadyCompleter?.complete();

      // 3. 主动拉取分片到缓存（顺序下载，支持暂停/恢复）
      await _downloadSegments(task, segmentUris);

      // 4. 如果有 MediaInfo，保存缓存信息到内存
      if (mediaInfo != null && mediaInfo.id != null) {
        _saveVideoCacheInfo(mediaInfo, task);
      }
    } catch (e) {
      task.progressController.addError(e);
    }
  }

  Future<void> _downloadSegments(_DownloadTask task, List<Uri> segments) async {
    // 定时速度上报
    Timer? timer;
    int lastBytes = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = task.downloadedBytes - lastBytes;
      lastBytes = task.downloadedBytes;
      final speedKBps = diff / 1024;
      final event = CacheEvent(
        progress: task.totalSegments == 0
            ? 0
            : min(1.0, task.downloadedSegments / task.totalSegments),
        downloadedBytes: task.downloadedBytes,
        downloadedSegments: task.downloadedSegments,
        speedKBps: speedKBps,
      );
      task.progressController.add(event);
    });

    try {
      for (final uri in segments) {
        if (task.isDisposed) break;
        // 等待恢复
        await task.waitIfPaused();
        // 使用缓存管理器拉取，命中则立即返回
        await _initCacheManager();
        final file = await _cacheManager.getSingleFile(uri.toString());
        final len = await file.length();
        task.downloadedBytes += len;
        task.downloadedSegments += 1;
      }
      // 完成上报一次
      final event = CacheEvent(
        progress: 1.0,
        downloadedBytes: task.downloadedBytes,
        downloadedSegments: task.downloadedSegments,
        speedKBps: 0,
      );
      task.progressController.add(event);
    } finally {
      timer.cancel();
    }
  }

  Future<String> _fetchText(String url) async {
    final client = HttpClient();
    client.userAgent = 'Dart/CacheManager';
    final req = await client.getUrl(Uri.parse(url));
    final resp = await req.close();
    if (resp.statusCode != 200) {
      throw HttpException('fetch m3u8 failed: ${resp.statusCode}',
          uri: Uri.parse(url));
    }
    final bytes = await resp.fold<List<int>>([], (p, e) => p..addAll(e));
    return utf8.decode(bytes);
  }

  Uri? _pickMediaPlaylistUri(String baseUrl, String content) {
    // 简单判断是否为主清单：存在EXT-X-STREAM-INF且后续行为子清单路径
    final lines = const LineSplitter().convert(content);
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith('#EXT-X-STREAM-INF')) {
        // 下一行应为子清单uri
        if (i + 1 < lines.length) {
          final next = lines[i + 1].trim();
          if (next.isNotEmpty && !next.startsWith('#')) {
            return Uri.parse(baseUrl).resolve(next);
          }
        }
      }
    }
    return null;
  }

  String _rewriteKeyLine(String line, Uri base, String proxyBase) {
    // 将 URI="xyz" 重写为本地seg代理
    final uriMatch = RegExp(r'URI="([^"]+)"').firstMatch(line);
    if (uriMatch == null) return line;
    final keyUri = base.resolve(uriMatch.group(1)!);
    final local = "$proxyBase/seg?url=${Uri.encodeFull(keyUri.toString())}";
    return line.replaceFirst(uriMatch.group(0)!, 'URI="$local"');
  }

  String _rewriteMapLine(String line, Uri base, String proxyBase) {
    // 重写 EXT-X-MAP 初始化段 URI
    final uriMatch = RegExp(r'URI="([^"]+)"').firstMatch(line);
    if (uriMatch == null) return line;
    final mapUri = base.resolve(uriMatch.group(1)!);
    final local = "$proxyBase/seg?url=${Uri.encodeFull(mapUri.toString())}";
    return line.replaceFirst(uriMatch.group(0)!, 'URI="$local"');
  }

  String _normalizeUrl(String url) => Uri.parse(url).toString();

  void _saveVideoCacheInfo(MediaInfo mediaInfo, _DownloadTask task) {
    final videoCacheInfo = VideoCacheInfo(
      mediaId: mediaInfo.id!,
      title: mediaInfo.title ?? '未知视频',
      coverImg: mediaInfo.coverImg,
      cacheTime: DateTime.now(),
      cacheSizeBytes: task.downloadedBytes,
      segmentCount: task.downloadedSegments,
      totalCount: task.totalSegments,
      originalUrl: task.url,
    );
    _videoCacheInfo[videoCacheInfo.mediaId] = videoCacheInfo;
    _urlToMediaId[task.url] = videoCacheInfo.mediaId;
    _mediaMeta[videoCacheInfo.mediaId] = {
      'title': mediaInfo.title,
      'coverImg': mediaInfo.coverImg,
    };
    unawaited(_addToIndex(videoCacheInfo.mediaId));
  }

  /// 获取指定视频的缓存信息
  VideoCacheInfo? getVideoCacheInfo(int mediaId) {
    return _videoCacheInfo[mediaId];
  }

  /// 获取所有视频缓存信息
  List<VideoCacheInfo> getAllVideoCacheInfo() {
    return _videoCacheInfo.values.toList();
  }

  /// 获取所有视频缓存信息（包括持久化的，基于索引）
  Future<List<VideoCacheInfo>> getAllVideoCacheInfoPersistent() async {
    final List<VideoCacheInfo> allCache = [];
    // 内存已有的先加上
    allCache.addAll(_videoCacheInfo.values);
    // 基于索引按需加载
    final ids = await _readIndex();
    for (final id in ids) {
      if (_videoCacheInfo.containsKey(id)) continue;
      final info = await _readVideoCacheInfo(id);
      if (info != null) {
        _videoCacheInfo[id] = info;
        allCache.add(info);
      }
    }
    return allCache;
  }

  /// 删除指定视频的缓存
  Future<bool> deleteVideoCache(int mediaId) async {
    try {
      final cacheInfo =
          _videoCacheInfo[mediaId] ?? await _readVideoCacheInfo(mediaId);
      if (cacheInfo == null) return false;

      // 从内存中移除
      _videoCacheInfo.remove(mediaId);
      _urlToMediaId.remove(cacheInfo.originalUrl);
      _mediaMeta.remove(mediaId);

      // 从缓存文件系统中删除（建议按 mediaId 单独目录存储时更高效，此处保守匹配）
      final cacheDir = await getApplicationDocumentsDirectory();
      final m3u8CacheDir = Directory('${cacheDir.path}/M3u8Segments');
      if (await m3u8CacheDir.exists()) {
        await for (final entity in m3u8CacheDir.list(recursive: true)) {
          if (entity is File && entity.path.contains(cacheInfo.originalUrl)) {
            try {
              await entity.delete();
            } catch (_) {
              // 忽略删除失败的文件
            }
          }
        }
      }

      // 停止相关的下载任务
      final task = _urlToTask[cacheInfo.originalUrl];
      if (task != null) {
        task.dispose();
        _urlToTask.remove(cacheInfo.originalUrl);
      }

      await _removeVideoCacheInfo(mediaId);
      await _removeFromIndex(mediaId);
      return true;
    } catch (e) {
      log.i("_cache_manager", "删除视频缓存失败: $e");
      return false;
    }
  }

  /// 检查指定视频是否有缓存
  bool hasVideoCache(int mediaId) {
    return _videoCacheInfo.containsKey(mediaId);
  }

  /// 检查指定视频是否有缓存（包括持久化的）
  Future<bool> hasVideoCachePersistent(int mediaId) async {
    // 先检查内存
    if (_videoCacheInfo.containsKey(mediaId)) {
      return true;
    }

    // 再检查持久化存储
    try {
      final info = await _readVideoCacheInfo(mediaId);
      if (info != null) {
        // 加载到内存中
        _videoCacheInfo[mediaId] = info;
        return true;
      }
    } catch (e) {
      log.i("_cache_manager", "检查持久化缓存失败: $e");
    }

    return false;
  }

  /// 根据任务反查媒体ID（通过已保存的映射，简单实现：url 匹配）
  int? _findMediaIdByTask(_DownloadTask task) {
    return _urlToMediaId[task.url];
  }
}

class _DownloadTask {
  final String url; // 入口m3u8地址（或子清单）
  final String proxyBase;
  final String taskId = _randomId();

  final StreamController<CacheEvent> progressController =
      StreamController<CacheEvent>.broadcast();

  bool _paused = false;
  Completer<void>? _resumeCompleter;
  bool isDisposed = false;

  int downloadedBytes = 0;
  int downloadedSegments = 0;
  int totalSegments = 0;
  String? rewrittenPlaylistContent;
  String? sourceOrigin;

  _DownloadTask({required this.url, required this.proxyBase});

  // 播放列表就绪信号
  Completer<void>? _playlistReadyCompleter;

  Future<void> waitForPlaylistReady(
      {Duration timeout = const Duration(seconds: 5)}) async {
    if (rewrittenPlaylistContent != null) return;
    _playlistReadyCompleter ??= Completer<void>();
    try {
      await _playlistReadyCompleter!.future.timeout(timeout);
    } catch (_) {}
  }

  void pause() {
    _paused = true;
    _resumeCompleter ??= Completer<void>();
  }

  void resume() {
    if (_paused) {
      _paused = false;
      _resumeCompleter?.complete();
      _resumeCompleter = null;
    }
  }

  Future<void> waitIfPaused() async {
    if (_paused) {
      _resumeCompleter ??= Completer<void>();
      await _resumeCompleter!.future;
    }
  }

  void resetStats() {
    downloadedBytes = 0;
    downloadedSegments = 0;
  }

  void dispose() {
    isDisposed = true;
    progressController.close();
  }
}

String _randomId() {
  final r = Random();
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(12, (_) => chars[r.nextInt(chars.length)]).join();
}
