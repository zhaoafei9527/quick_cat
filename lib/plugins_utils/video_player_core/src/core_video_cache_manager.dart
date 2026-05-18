import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class CoreVideoCacheProgress {
  final double progress;
  final int cachedSegments;
  final int totalSegments;
  final int cachedBytes;

  const CoreVideoCacheProgress({
    required this.progress,
    required this.cachedSegments,
    required this.totalSegments,
    required this.cachedBytes,
  });
}

class CoreVideoCacheManager {
  static final CoreVideoCacheManager _instance =
      CoreVideoCacheManager._internal();

  factory CoreVideoCacheManager() => _instance;

  CoreVideoCacheManager._internal();

  CacheManager? _cacheManager;
  HttpServer? _server;
  String? _proxyBaseUrl;
  final Map<String, _CoreCacheTask> _tasks = {};

  Future<String> preparePlayableUrl(
    String url, {
    int cacheAheadSegmentCount = 2,
  }) async {
    if (!url.toLowerCase().contains('.m3u8')) return url;
    await _ensureServer();
    final normalized = Uri.parse(url).toString();
    var task = _tasks[normalized];
    if (task == null || task.disposed) {
      task = _CoreCacheTask(
        url: normalized,
        proxyBaseUrl: _proxyBaseUrl!,
        cacheAheadSegmentCount: cacheAheadSegmentCount,
      );
      _tasks[normalized] = task;
    }
    task.cacheAheadSegmentCount = cacheAheadSegmentCount;
    unawaited(_prepareTask(task));
    await task.waitForPlaylistReady();
    return '${task.proxyBaseUrl}/playlist/${task.id}';
  }

  Stream<CoreVideoCacheProgress> progressOf(String url) {
    return _taskOf(url)?.progress.stream ?? const Stream.empty();
  }

  void stop(String url) {
    final task = _taskOf(url);
    if (task == null) return;
    task.dispose();
    _tasks.remove(task.url);
  }

  Future<void> stopProxy() async {
    for (final task in _tasks.values) {
      task.dispose();
    }
    _tasks.clear();
    await _server?.close(force: true);
    _server = null;
    _proxyBaseUrl = null;
  }

  Future<void> _ensureCacheManager() async {
    if (_cacheManager != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _cacheManager = CacheManager(Config(
      'PublicVideoCoreM3u8Segments',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 5000,
      repo:
          JsonCacheInfoRepository(databaseName: 'PublicVideoCoreM3u8Segments'),
      fileSystem: IOFileSystem('${dir.path}/PublicVideoCoreM3u8Segments'),
      fileService: HttpFileService(),
    ));
  }

  Future<void> _ensureServer() async {
    if (_server != null) return;
    _server = await shelf_io.serve(
      _handleRequest,
      InternetAddress.loopbackIPv4,
      0,
    );
    _proxyBaseUrl = 'http://127.0.0.1:${_server!.port}';
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    if (path.startsWith('playlist/')) {
      final id = path.substring('playlist/'.length);
      final task = _tasks.values.firstWhere(
        (task) => task.id == id && !task.disposed,
        orElse: () => throw StateError('playlist not found'),
      );
      await task.waitForPlaylistReady();
      return Response.ok(
        utf8.encode(task.playlist ?? ''),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/vnd.apple.mpegurl',
        },
      );
    }

    if (path == 'seg') {
      final encoded = request.url.queryParameters['url'];
      if (encoded == null) return Response.badRequest(body: 'missing url');
      final segmentUrl = Uri.decodeFull(encoded);
      final task = _taskForSegment(segmentUrl);
      await _ensureCacheManager();
      final file = await _cacheManager!.getSingleFile(segmentUrl);
      final length = await file.length();
      if (task != null) {
        _markCached(task, segmentUrl, length);
        unawaited(_prefetchAhead(task, segmentUrl));
      }
      final rangeHeader = request.headers[HttpHeaders.rangeHeader];
      if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
        final range = rangeHeader.substring('bytes='.length).split('-');
        final start = (int.tryParse(range.first) ?? 0).clamp(0, length - 1);
        final end = range.length > 1 && range[1].isNotEmpty
            ? (int.tryParse(range[1]) ?? length - 1).clamp(start, length - 1)
            : length - 1;
        return Response(
          206,
          body: file.openRead(start, end + 1),
          headers: {
            HttpHeaders.acceptRangesHeader: 'bytes',
            HttpHeaders.contentLengthHeader: '${end - start + 1}',
            HttpHeaders.contentRangeHeader: 'bytes $start-$end/$length',
            HttpHeaders.contentTypeHeader: _mimeType(segmentUrl),
          },
        );
      }
      return Response.ok(
        file.openRead(),
        headers: {
          HttpHeaders.acceptRangesHeader: 'bytes',
          HttpHeaders.contentLengthHeader: '$length',
          HttpHeaders.contentTypeHeader: _mimeType(segmentUrl),
        },
      );
    }

    return Response.notFound('unknown route');
  }

  Future<void> _prepareTask(_CoreCacheTask task) async {
    if (task.prepareStarted) return;
    task.prepareStarted = true;
    try {
      final playlistText = await _fetchText(task.url);
      if (task.disposed) return;
      final mediaUri = _pickMediaPlaylistUri(task.url, playlistText);
      final mediaText = mediaUri == null
          ? playlistText
          : await _fetchText(mediaUri.toString());
      if (task.disposed) return;
      final base = Uri.parse(mediaUri?.toString() ?? task.url);
      final lines = const LineSplitter().convert(mediaText);
      final rewritten = <String>[];
      final segments = <Uri>[];
      var hasExtm3u = false;
      var hasEndList = false;

      for (final line in lines) {
        if (line.startsWith('#EXTM3U')) hasExtm3u = true;
        if (line.startsWith('#EXT-X-ENDLIST')) hasEndList = true;
        if (line.trim().isEmpty || line.startsWith('#')) {
          rewritten.add(_rewriteUriAttributes(line, base, task.proxyBaseUrl));
          continue;
        }
        final segmentUri = base.resolve(line);
        segments.add(segmentUri);
        rewritten.add(
          '${task.proxyBaseUrl}/seg?url=${Uri.encodeFull(segmentUri.toString())}',
        );
      }

      if (!hasExtm3u) rewritten.insert(0, '#EXTM3U');
      if (!hasEndList) rewritten.add('#EXT-X-ENDLIST');
      task.segmentUris = segments;
      task.totalSegments = max(1, segments.length);
      task.playlist = rewritten.join('\n');
      task.markPlaylistReady();
    } catch (error, stackTrace) {
      task.markPlaylistReady();
      if (!task.disposed && !task.progress.isClosed) {
        task.progress.addError(error, stackTrace);
      }
    }
  }

  Future<void> _prefetchAhead(_CoreCacheTask task, String segmentUrl) async {
    if (task.disposed) return;
    final index =
        task.segmentUris.indexWhere((uri) => uri.toString() == segmentUrl);
    if (index < 0 || task.cacheAheadSegmentCount <= 0) return;
    final end = min(
      task.segmentUris.length - 1,
      index + task.cacheAheadSegmentCount,
    );
    for (var i = index + 1; i <= end; i++) {
      if (task.disposed) return;
      final url = task.segmentUris[i].toString();
      if (task.cachedSegments.contains(url) || !task.prefetching.add(url)) {
        continue;
      }
      try {
        await _ensureCacheManager();
        final file = await _cacheManager!.getSingleFile(url);
        _markCached(task, url, await file.length());
      } catch (_) {
        if (task.disposed) return;
      } finally {
        task.prefetching.remove(url);
      }
    }
  }

  void _markCached(_CoreCacheTask task, String url, int length) {
    if (task.disposed || task.progress.isClosed) return;
    if (!task.cachedSegments.add(url)) return;
    task.cachedBytes += length;
    task.progress.add(CoreVideoCacheProgress(
      progress: task.totalSegments == 0
          ? 0
          : task.cachedSegments.length / task.totalSegments,
      cachedSegments: task.cachedSegments.length,
      totalSegments: task.totalSegments,
      cachedBytes: task.cachedBytes,
    ));
  }

  _CoreCacheTask? _taskForSegment(String url) {
    for (final task in _tasks.values) {
      if (task.disposed) continue;
      if (task.segmentUris.any((uri) => uri.toString() == url)) return task;
    }
    return null;
  }

  _CoreCacheTask? _taskOf(String url) {
    final normalized = Uri.tryParse(url)?.toString() ?? url;
    final direct = _tasks[normalized];
    if (direct != null && !direct.disposed) return direct;
    final uri = Uri.tryParse(normalized);
    if (uri != null &&
        _proxyBaseUrl != null &&
        normalized.startsWith(_proxyBaseUrl!) &&
        uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.first == 'playlist' && uri.pathSegments.length > 1) {
        final id = uri.pathSegments[1];
        for (final task in _tasks.values) {
          if (!task.disposed && task.id == id) return task;
        }
      }
      if (uri.pathSegments.first == 'seg') {
        final encoded = uri.queryParameters['url'];
        if (encoded != null) return _taskForSegment(Uri.decodeFull(encoded));
      }
    }
    return _taskForSegment(normalized);
  }

  Future<String> _fetchText(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException('fetch m3u8 failed: ${response.statusCode}');
      }
      final bytes = await response.fold<List<int>>([], (data, chunk) {
        data.addAll(chunk);
        return data;
      });
      return utf8.decode(bytes);
    } finally {
      client.close(force: true);
    }
  }

  Uri? _pickMediaPlaylistUri(String baseUrl, String content) {
    final lines = const LineSplitter().convert(content);
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('#EXT-X-STREAM-INF') && i + 1 < lines.length) {
        final next = lines[i + 1].trim();
        if (next.isNotEmpty && !next.startsWith('#')) {
          return Uri.parse(baseUrl).resolve(next);
        }
      }
    }
    return null;
  }

  String _rewriteUriAttributes(String line, Uri base, String proxyBaseUrl) {
    return line.replaceAllMapped(RegExp(r'URI="([^"]+)"'), (match) {
      final uri = base.resolve(match.group(1)!);
      return 'URI="$proxyBaseUrl/seg?url=${Uri.encodeFull(uri.toString())}"';
    });
  }

  String _mimeType(String url) {
    if (url.endsWith('.m3u8')) return 'application/vnd.apple.mpegurl';
    if (url.endsWith('.ts')) return 'video/mp2t';
    if (url.endsWith('.mp4')) return 'video/mp4';
    return 'application/octet-stream';
  }
}

class _CoreCacheTask {
  final String url;
  final String proxyBaseUrl;
  final String id = _randomId();
  final StreamController<CoreVideoCacheProgress> progress =
      StreamController<CoreVideoCacheProgress>.broadcast();
  int cacheAheadSegmentCount;
  int totalSegments = 0;
  int cachedBytes = 0;
  bool prepareStarted = false;
  bool disposed = false;
  String? playlist;
  List<Uri> segmentUris = [];
  final Set<String> cachedSegments = {};
  final Set<String> prefetching = {};
  Completer<void>? _playlistReady;

  _CoreCacheTask({
    required this.url,
    required this.proxyBaseUrl,
    required this.cacheAheadSegmentCount,
  });

  Future<void> waitForPlaylistReady() async {
    if (playlist != null) return;
    _playlistReady ??= Completer<void>();
    try {
      await _playlistReady!.future.timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  void markPlaylistReady() {
    _playlistReady ??= Completer<void>();
    if (!_playlistReady!.isCompleted) _playlistReady!.complete();
  }

  void dispose() {
    if (disposed) return;
    disposed = true;
    progress.close();
  }
}

String _randomId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(12, (_) => chars[random.nextInt(chars.length)]).join();
}
