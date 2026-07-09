// 🎯 Dart imports:
import 'dart:async';
import 'dart:ui' as ui;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/ImageLoader/src/decrypt_image.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/src/progress_data.dart';

class CachedImage extends StatefulWidget {
  final String url;

  final Map<String, dynamic>? headers;

  final ImageErrorWidgetBuilder? errorBuilder;

  ///Usage: loadingBuilder(context, FastCachedProgressData progressData){return  Text('${progress.downloadedBytes ~/ 1024} / ${progress.totalBytes! ~/ 1024} kb')}
  final Widget Function(BuildContext, FastCachedProgressData)? loadingBuilder;

  final Duration fadeInDuration;

  final int? cacheWidth;
  final int? cacheHeight;

  final double? width;

  final double? height;

  final double scale;

  final Color? color;

  final Animation<double>? opacity;

  final FilterQuality filterQuality;

  final BlendMode? colorBlendMode;

  final BoxFit? fit;

  final AlignmentGeometry alignment;

  ///[repeat] 重复属性
  final ImageRepeat repeat;

  ///[centerSlice] Flutter 内存加载 memory 只支持原生.
  final Rect? centerSlice;

  ///[matchTextDirection] Flutter 内存加载 memory 只支持原生.
  final bool matchTextDirection;

  /// 将 [gaplessPlayback] 的默认值设置为 false 有助于防止
  /// 可能会出现陈旧或误导性信息的情况。
  final bool gaplessPlayback;

  ///[semanticLabel] Flutter 内存加载 memory 只支持原生.
  final String? semanticLabel;

  ///[excludeFromSemantics] Flutter 内存加载 memory 只支持原生.
  final bool excludeFromSemantics;

  ///[isAntiAlias] Flutter 内存加载 memory 只支持原生
  final bool isAntiAlias;

  ///[showErrorLog] 如果想忽略错误日志，可以设置为 true
  final bool showErrorLog;

  const CachedImage(
      {required this.url,
      this.headers,
      this.scale = 1.0,
      this.errorBuilder,
      this.semanticLabel,
      this.loadingBuilder,
      this.excludeFromSemantics = false,
      this.showErrorLog = true,
      this.width,
      this.height,
      this.color,
      this.opacity,
      this.colorBlendMode,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.centerSlice,
      this.matchTextDirection = false,
      this.gaplessPlayback = false,
      this.isAntiAlias = false,
      this.filterQuality = FilterQuality.low,
      this.fadeInDuration = const Duration(milliseconds: 500),
      this.cacheWidth,
      this.cacheHeight,
      super.key});

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage>
    with TickerProviderStateMixin {
  ///[_imageResponse] not public API.
  _ImageResponse? _imageResponse;

  ///[_animation] not public API.
  late Animation<double> _animation;

  ///[_animationController] not public API.
  late AnimationController _animationController;

  ///[_progressData] holds the data indicating the progress of download.
  late FastCachedProgressData _progressData;

  bool changeLoading = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: widget.fadeInDuration);
    _animation = Tween<double>(
            begin: widget.fadeInDuration == Duration.zero ? 1 : 0, end: 1)
        .animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAsync(widget.url, widget.headers);
      _animationController
          .addStatusListener((status) => _animationListener(status));
    });

    clearProgressData();
    super.initState();
  }

  void _animationListener(AnimationStatus status) {
    // if (status == AnimationStatus.completed &&
    //     mounted &&
    //     widget.fadeInDuration != Duration.zero) setState(() => {});
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (oldWidget.url != widget.url) {
      () async {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          setState(() => changeLoading = true);
          await _loadAsync(widget.url, widget.headers);
          _animationController
              .addStatusListener((status) => _animationListener(status));

          clearProgressData();
        });
      }();
    }

    super.didUpdateWidget(oldWidget);
  }

  void clearProgressData() async {
    _progressData = FastCachedProgressData(
        progressPercentage: ValueNotifier(0),
        totalBytes: null,
        downloadedBytes: 0,
        isDownloading: false);
  }

  @override
  void dispose() {
    _animationController.removeListener(() => {});
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageResponse?.error != null && widget.errorBuilder != null) {
      _logErrors(_imageResponse?.error);
      return widget.errorBuilder!(
          context, Object, StackTrace.fromString(_imageResponse!.error!));
    }

    return SizedBox(
        child: Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [
          if (_animationController.status != AnimationStatus.completed)
            // (widget.loadingBuilder != null)
            // ? widget.loadingBuilder!(context)
            // :
            (widget.loadingBuilder != null)
                ? ValueListenableBuilder(
                    valueListenable: _progressData.progressPercentage,
                    builder: (context, p, c) {
                      return widget.loadingBuilder!(context, _progressData);
                    })
                : const SizedBox(),
          if (_imageResponse != null)
            FadeTransition(
                opacity: _animation,
                child: Image.memory(
                  _imageResponse!.imageData,
                  color: widget.color,
                  width: widget.width,
                  height: widget.height,
                  alignment: widget.alignment,
                  key: widget.key,
                  cacheWidth: widget.cacheWidth,
                  cacheHeight: widget.cacheHeight,
                  fit: widget.fit,
                  errorBuilder: (a, c, v) {
                    if (_animationController.status !=
                        AnimationStatus.completed) {
                      _animationController.forward();
                      _logErrors(c);
                      CachedImageConfig.deleteCachedImage(
                          imageUrl: widget.url, showLog: widget.showErrorLog);
                    }
                    return widget.errorBuilder != null
                        ? widget.errorBuilder!(a, c, v)
                        : const SizedBox();
                  },
                  centerSlice: widget.centerSlice,
                  colorBlendMode: widget.colorBlendMode,
                  excludeFromSemantics: widget.excludeFromSemantics,
                  filterQuality: widget.filterQuality,
                  gaplessPlayback: widget.gaplessPlayback,
                  isAntiAlias: widget.isAntiAlias,
                  matchTextDirection: widget.matchTextDirection,
                  opacity: widget.opacity,
                  repeat: widget.repeat,
                  scale: widget.scale,
                  semanticLabel: widget.semanticLabel,
                  frameBuilder: (widget.loadingBuilder != null)
                      ? (context, a, b, c) {
                          if (b == null) {
                            return widget.loadingBuilder!(
                                context,
                                FastCachedProgressData(
                                    progressPercentage:
                                        _progressData.progressPercentage,
                                    totalBytes: _progressData.totalBytes,
                                    downloadedBytes:
                                        _progressData.downloadedBytes,
                                    isDownloading: false));
                          }

                          if (_animationController.status !=
                              AnimationStatus.completed) {
                            _animationController.forward();
                          }
                          return a;
                        }
                      : null,
                )),
          if (changeLoading && widget.loadingBuilder != null)
            ValueListenableBuilder(
                valueListenable: _progressData.progressPercentage,
                builder: (context, p, c) {
                  return widget.loadingBuilder!(context, _progressData);
                })
        ]));
  }

  ///[_loadAsync] Not public API.
  Future<void> _loadAsync(String url, Map<String, dynamic>? headers) async {
    CachedImageConfig._checkInit();
    // 根据URI获取缓存堆债中的图片数据
    Uint8List? image = await CachedImageConfig._getImage(url);

    if (!mounted) return;

    if (image != null) {
      setState(
          () => _imageResponse = _ImageResponse(imageData: image, error: null));
      if (widget.loadingBuilder == null) _animationController.forward();

      return;
    }

    StreamController chunkEvents = StreamController();

    try {
      final Uri resolved = Uri.base.resolve(url);
      Dio dio = Dio();

      if (!mounted) return;

      // 设置下载状态
      _progressData.isDownloading = true;
      if (widget.loadingBuilder != null && mounted) {
        widget.loadingBuilder!(context, _progressData);
      }
      Response response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes, headers: headers),
          onReceiveProgress: (int received, int total) {
        if (received < 0 || total < 0) return;
        if (widget.loadingBuilder != null) {
          _progressData.downloadedBytes = received;
          _progressData.totalBytes = total;
          double.parse((received / total).toStringAsFixed(2));
          // _progress.value = tot != null ? _downloaded / _total! : 0;
          _progressData.progressPercentage.value =
              double.parse((received / total).toStringAsFixed(2));
          if (mounted) widget.loadingBuilder!(context, _progressData);
        }

        chunkEvents.add(ImageChunkEvent(
          cumulativeBytesLoaded: received,
          expectedTotalBytes: total,
        ));
      });

      final Uint8List oldBytes = response.data;

      /// 重新解密图片数据
      Uint8List bytes = await decryptImage({
        "imgBytes": oldBytes,
        "path": url,
        "url": url,
      });
      if (response.statusCode != 200) {
        String error = NetworkImageLoadException(
                statusCode: response.statusCode ?? 0, uri: resolved)
            .toString();
        if (mounted) {
          setState(() => _imageResponse =
              _ImageResponse(imageData: Uint8List.fromList([]), error: error));
        }
        return;
      }
      if (changeLoading) setState(() => changeLoading = false);

      /// 下载完成重新设置状态
      _progressData.isDownloading = false;

      if (bytes.isEmpty && mounted) {
        setState(() => _imageResponse =
            _ImageResponse(imageData: bytes, error: 'Image is empty.'));
        return;
      }
      if (mounted) {
        setState(() =>
            _imageResponse = _ImageResponse(imageData: bytes, error: null));
        if (widget.loadingBuilder == null) _animationController.forward();
      }

      await CachedImageConfig._saveImage(url, bytes);
    } catch (e) {
      if (mounted) {
        setState(() => _imageResponse = _ImageResponse(
            imageData: Uint8List.fromList([]), error: e.toString()));
      }
    } finally {
      if (!chunkEvents.isClosed) await chunkEvents.close();
    }
  }

  void _logErrors(dynamic object) {
    if (widget.showErrorLog) {
      debugPrint('$object - Image url : ${widget.url}');
    }
  }
}

class _ImageResponse {
  Uint8List imageData;
  String? error;

  _ImageResponse({required this.imageData, required this.error});
}

///[CachedImageConfig] is the class to manage and set the cache configurations.
class CachedImageConfig {
  static LazyBox? _imageKeyBox;
  static LazyBox? _imageBox;
  static bool _isInitialized = false;
  static const String _notInitMessage =
      'CachedImage is not initialized. Please use CachedImageConfig.init to initialize CachedImage';

  /// 初始化图片缓存配置 注意 web状态下不能传 subDir
  static Future<void> init({String? subDir, Duration? clearCacheAfter}) async {
    if (_isInitialized) return;

    clearCacheAfter ??= const Duration(days: 7);

    await Hive.initFlutter(subDir);
    _isInitialized = true;

    _imageKeyBox = await Hive.openLazyBox(_BoxNames.imagesKeyBox);
    _imageBox = await Hive.openLazyBox(_BoxNames.imagesBox);
    await _clearOldCache(clearCacheAfter);
  }

  static Future<Uint8List?> _getImage(String url) async {
    final key = _keyFromUrl(url);
    if (_imageKeyBox!.keys.contains(url) && _imageBox!.containsKey(url)) {
      // Migrating old keys to new keys
      await _replaceImageKey(oldKey: url, newKey: key);
      await _replaceOldImage(
          oldKey: url, newKey: key, image: await _imageBox!.get(url));
    }

    if (_imageKeyBox!.keys.contains(key) && _imageBox!.keys.contains(key)) {
      Uint8List? data = await _imageBox!.get(key);
      if (data == null || data.isEmpty) return null;

      return data;
    }

    return null;
  }

  ///[_saveImage] is to save an image to cache. Not part of public API.
  static Future<void> _saveImage(String url, Uint8List image) async {
    final key = _keyFromUrl(url);

    await _imageKeyBox!.put(key, DateTime.now());
    await _imageBox!.put(key, image);
  }

  ///[_clearOldCache] clears the old cache. Not part of public API.
  static Future<void> _clearOldCache(Duration cleatCacheAfter) async {
    DateTime today = DateTime.now();

    for (final key in _imageKeyBox!.keys) {
      DateTime? dateCreated = await _imageKeyBox!.get(key);

      if (dateCreated == null) continue;

      if (today.difference(dateCreated) > cleatCacheAfter) {
        await _imageKeyBox!.delete(key);
        await _imageBox!.delete(key);
      }
    }
  }

  static Future<void> _replaceImageKey(
      {required String oldKey, required String newKey}) async {
    _checkInit();

    DateTime? dateCreated = await _imageKeyBox!.get(oldKey);

    if (dateCreated == null) return;

    _imageKeyBox!.delete(oldKey);
    _imageKeyBox!.put(newKey, dateCreated);
  }

  static Future<void> _replaceOldImage({
    required String oldKey,
    required String newKey,
    required Uint8List image,
  }) async {
    await _imageBox!.delete(oldKey);
    await _imageBox!.put(newKey, image);
  }

  ///[deleteCachedImage] function takes in a image [imageUrl] and removes the image corresponding to the url
  /// from the cache if the image is present in the cache.
  static Future<void> deleteCachedImage(
      {required String imageUrl, bool showLog = true}) async {
    _checkInit();

    final key = _keyFromUrl(imageUrl);
    if (_imageKeyBox!.keys.contains(key) && _imageBox!.keys.contains(key)) {
      await _imageKeyBox!.delete(key);
      await _imageBox!.delete(key);
      if (showLog) {
        debugPrint('FastCacheImage: Removed image $imageUrl from cache.');
      }
    }
  }

  ///[clearAllCachedImages] function clears all cached images. This can be used in scenarios such as
  ///logout functionality of your app, so that all cached images corresponding to the user's account is removed.
  static Future<void> clearAllCachedImages({bool showLog = true}) async {
    _checkInit();
    await _imageKeyBox!.deleteFromDisk();
    await _imageBox!.deleteFromDisk();
    if (showLog) debugPrint('FastCacheImage: All cache cleared.');
    _imageKeyBox = await Hive.openLazyBox(_BoxNames.imagesKeyBox);
    _imageBox = await Hive.openLazyBox(_BoxNames.imagesBox);
  }

  ///[_checkInit] method ensures the hive db is initialized. Not part of public API
  static void _checkInit() {
    if ((CachedImageConfig._imageKeyBox == null ||
            !CachedImageConfig._imageKeyBox!.isOpen) ||
        CachedImageConfig._imageBox == null ||
        !CachedImageConfig._imageBox!.isOpen) {
      throw Exception(_notInitMessage);
    }
  }

  ///[isCached] returns a boolean indicating whether the given image is cached or not.
  ///Returns true if cached, false if not.
  static bool isCached({required String imageUrl}) {
    _checkInit();

    final key = _keyFromUrl(imageUrl);
    if (_imageKeyBox!.containsKey(key) && _imageBox!.keys.contains(key)) {
      return true;
    }
    return false;
  }

  static _keyFromUrl(String url) => const Uuid().v5(Uuid.NAMESPACE_URL, url);
}

///[_BoxNames] contains the name of the boxes. Not part of public API
class _BoxNames {
  ///[imagesBox] db for images
  static String imagesBox = 'cachedImages';

  ///[imagesKeyBox] db for keys of images
  static String imagesKeyBox = 'cachedImagesKeys';
}

/// The fast cached image implementation of [image_provider.NetworkImage].
@immutable
class CachedImageProvider extends ImageProvider<NetworkImage>
    implements NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const CachedImageProvider(this.url, {this.scale = 1.0, this.headers});

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String>? headers;

  @override
  Future<CachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      NetworkImage key, DecoderBufferCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key as CachedImageProvider, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<NetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    CachedImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderBufferCallback decode,
  ) async {
    try {
      assert(key == this);
      Dio dio = Dio();

      // CachedImageConfig._checkInit();
      //
      // Uint8List? image = await CachedImageConfig._getImage(url);
      // if (image != null) {
      //   final ui.ImmutableBuffer buffer =
      //       await ui.ImmutableBuffer.fromUint8List(image);
      //   return decode(buffer);
      // }

      final Uri resolved = Uri.base.resolve(key.url);

      if (headers != null) dio.options.headers.addAll(headers!);
      Response response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (int received, int total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: received,
            expectedTotalBytes: total,
          ));
        },
      );

      final Uint8List oldBytes = response.data;
      final Uint8List bytes = await decryptImage({
        "imgBytes": oldBytes,
        "path": url,
        "url": url,
      });
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }

      final ui.ImmutableBuffer buffer =
          await ui.ImmutableBuffer.fromUint8List(bytes);
      // await CachedImageConfig._saveImage(url, bytes);
      return decode(buffer);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CachedImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImage')}("$url", scale: $scale)';
}
