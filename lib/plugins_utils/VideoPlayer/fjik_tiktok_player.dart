import 'dart:async';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/dialog/comment_dialog.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/video_play_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/fijk_tiktok_panel.dart';
import 'package:quick_cat_client/plugins_utils/video_player_core/video_player_core.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../app/data/ads_type.dart';
import '../../app/model/home/topic_list_model.dart';
import '../../app/routes/app_pages.dart';
import '../../utils/common_util.dart';
import '../../utils/dimens.dart';
import '../../utils/screen.dart';
import '../ImageLoader/ImageLoader.dart';
import 'src/m3u8_cache_manager.dart';

/// 页面（支持上下滑切换。生命周期：前后台自动暂停/恢复当前）
class FijkTiktokFeedPage extends StatefulWidget {
  final List<MediaInfo> medias;
  final int initIndex;
  final bool firstPlay; // 是否第一次播放（默认 false）
  final int cacheCount; // 最多同时保留几个 Player（默认 3）
  final int cacheAheadSegmentCount; // 播放进度后预缓存的 m3u8 分片数
  final FijkTiktokFeedController? controller;
  final Function(int pageNum)? onLoadMore; // 可选：加载更多回调
  final Function(int id)? onVideoPlay; // 可选：播放视频回调（用于广告等）
  final Function(int adsId)? onAdsClick; // 可选：广告点击回调

  const FijkTiktokFeedPage(
      {super.key,
      required this.medias,
      this.controller,
      this.cacheCount = 3,
      this.cacheAheadSegmentCount = 2,
      this.onLoadMore,
      this.onVideoPlay,
      this.onAdsClick,
      this.initIndex = 0,
      this.firstPlay = false});

  @override
  State<FijkTiktokFeedPage> createState() => _FijkTiktokFeedPageState();
}

class _FijkTiktokFeedPageState extends State<FijkTiktokFeedPage>
    with WidgetsBindingObserver {
  late List<MediaInfo> _medias;
  final CoreFijkTiktokFeedController _coreController =
      CoreFijkTiktokFeedController();
  int _current = 0;
  int pageNum = 1; // 当前页码
  bool initOk = false;

  // 移除未使用的字段

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 初始化tiktok 页面控制器 计算进入时最大的页码位置
    pageNum = widget.medias.length ~/ 10;
    getMediaList();
  }

  Future<void> getMediaList() async {
    _medias = await getAdsMediaList(widget.medias);
    widget.controller?._attach(this);
    if (mounted) setState(() => initOk = true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _coreController.togglePause(true);
    } else if (state == AppLifecycleState.resumed &&
        shareKeys.tabIndex.value == 1) {
      // _coreController.togglePause(false);
    }
  }

  Future<void> _onCoreVideoPlay(CoreVideoItem item, int index) async {
    _current = index;
    final media = item.extra is MediaInfo ? item.extra as MediaInfo : null;
    if (media == null || (media.isAds ?? false)) return;
    unawaited(WatchRecord.addWatchRecord(media, MediaType.videoShort));

    // 请求视频播放权限
    MediaPlayModel? playModel = await widget.onVideoPlay?.call(media.id ?? 0);
    if (playModel != null && playModel.mediaInfo != null) {
      media.playable = playModel.playable;
    }
  }

  Future<List<CoreVideoItem>> _loadMoreCoreItems(int nextPage) async {
    if (widget.onLoadMore == null) return [];
    final model = await widget.onLoadMore!(nextPage);
    if (model.isEmpty) return [];
    final withAds = await getAdsMediaList(model);
    _medias.addAll(withAds);
    pageNum = nextPage;
    log.i("_tiktok_player", "_mediasLen:${_medias.length}");
    return withAds.map(_toCoreVideoItem).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!initOk) {
      return Container(
          color: Colors.black,
          width: screen.screenWidth,
          height: screen.screenHeight,
          child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: CoreFijkTiktokFeedPage(
        items: _medias.map(_toCoreVideoItem).toList(),
        initIndex: widget.initIndex,
        firstPlay: widget.firstPlay,
        playerCacheCount: widget.cacheCount,
        cacheConfig: CoreVideoCacheConfig(
          aheadSegmentCount: widget.cacheAheadSegmentCount,
        ),
        controller: _coreController,
        isVideoItem: (item) {
          final media =
              item.extra is MediaInfo ? item.extra as MediaInfo : null;
          return !(media?.isAds ?? false);
        },
        onLoadMore: _loadMoreCoreItems,
        onVideoPlay: _onCoreVideoPlay,
        coverBuilder: (_, item) {
          final media =
              item.extra is MediaInfo ? item.extra as MediaInfo : null;
          return ImageLoader.withP(media?.coverImg ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity)
              .load();
        },
        placeholderBuilder: (_, item, __) {
          final media =
              item.extra is MediaInfo ? item.extra as MediaInfo : null;
          return Stack(alignment: Alignment.center, children: [
            ImageLoader.withP(media?.coverImg ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity)
                .load(),
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
          ]);
        },
        nonVideoItemBuilder: (_, item) {
          final media =
              item.extra is MediaInfo ? item.extra as MediaInfo : null;
          return _buildAdsView(mediaInfo: media);
        },
        overlayBuilder: (context, item, player, state) {
          final media =
              item.extra is MediaInfo ? item.extra as MediaInfo : null;
          return FijkTiktokPanel(
            player,
            viewSize: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            mediaInfo: media,
            buildContext: context,
            controller: widget.controller,
            texturePos: Rect.fromLTWH(
              0,
              0,
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
          );
        },
      ),
    );
  }

  CoreVideoItem _toCoreVideoItem(MediaInfo media) {
    return CoreVideoItem(
      id: media.id,
      url: media.isAds == true ? '' : getVideoRemotePath(media.videoUrl ?? ''),
      title: media.title,
      coverUrl: media.coverImg,
      width: media.width,
      height: media.height,
      playable: media.playable ?? true,
      extra: media,
    );
  }

  Widget _buildAdsView({MediaInfo? mediaInfo}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
      onTap: () {
        if (mediaInfo == null || mediaInfo.adsId == null) return;
        AppPages.jumpRouter(path: mediaInfo.adsPath ?? "", id: mediaInfo.adsId);
      },
      child: Stack(alignment: Alignment.bottomLeft, children: [
        ImageLoader.withP(mediaInfo?.coverImg,
                width: screen.screenWidth, height: screen.screenHeight)
            .load(),
        Container(
            height: Dimens.pt230,
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: Dimens.pt73,
                  height: Dimens.pt35,
                  alignment: Alignment.center,
                  color: theme.getColor(ThemeColor.textGrey),
                  child: Text("广告",
                      style: TextStyle(
                          fontSize: Dimens.pt22,
                          color: theme.getColor(ThemeColor.bg)))),
              SizedBox(height: Dimens.pt25),
              Text(mediaInfo?.title ?? "",
                  style: TextStyle(
                      fontSize: Dimens.pt30,
                      fontWeight: FontWeight.bold,
                      color: theme.getColor(ThemeColor.primary))),
              SizedBox(height: Dimens.pt15),
              Container(
                  height: Dimens.pt70,
                  alignment: Alignment.center,
                  color: theme.getColor(ThemeColor.textYellow),
                  child: Text("点击前往",
                      style: TextStyle(
                          fontSize: Dimens.pt38,
                          color: theme.getColor(ThemeColor.primary))))
            ]))
      ]),
    );
  }

  void appendMedias(List<MediaInfo> newMedias) {
    setState(() {
      _medias.addAll(newMedias);
    });
    _coreController.append(newMedias.map(_toCoreVideoItem).toList());
  }

  void resetMedias(List<MediaInfo> newMedias,
      {int initIndex = 0, bool autoPlay = false}) {
    setState(() {
      _medias = List.of(newMedias);
      _current = initIndex.clamp(0, newMedias.length - 1);
      pageNum = newMedias.length ~/ 10;
    });
    _coreController.resetItems(
      _medias.map(_toCoreVideoItem).toList(),
      initIndex: _current,
      autoPlay: autoPlay,
    );
  }
}

/// 单个视频页
class FeedVideoItem extends StatelessWidget {
  final int index;
  final bool isActive;
  final MediaInfo? mediaInfo;
  final PlayerHolder? holder;
  final FijkTiktokFeedController? controller;

  const FeedVideoItem(
      {super.key,
      required this.index,
      required this.isActive,
      required this.holder,
      this.controller,
      this.mediaInfo});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
          color: Colors.black,
          width: screen.screenWidth,
          height: screen.screenHeight),
      ValueListenableBuilder<bool>(
          valueListenable:
              holder?.preparedNotifier ?? ValueNotifier<bool>(false),
          builder: (context, isPrepared, _) {
            int videoWidth = mediaInfo?.width ?? screen.screenWidth.toInt();
            int videoHeight = mediaInfo?.height ?? screen.screenHeight.toInt();
            double aspectRatio =
                videoHeight > 0 ? videoWidth / videoHeight : 1.0;
            if (isPrepared && holder != null) {
              return AspectRatio(
                  aspectRatio: aspectRatio,
                  child: FijkView(
                      player: holder!.player,
                      fit: FijkFit.fill,
                      panelBuilder: (player, data, context, size, rect) {
                        return Container();
                      }));
            }
            return Stack(alignment: Alignment.center, children: [
              ImageLoader.withP(mediaInfo?.coverImg ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity)
                  .load(),
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            ]);
          }),
      if (holder != null)
        Positioned.fill(
            child: FijkTiktokPanel(holder!.player,
                viewSize: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
                mediaInfo: mediaInfo,
                buildContext: context,
                controller: controller,
                texturePos: Rect.fromLTWH(
                    0,
                    0,
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height)))
    ]);
  }
}

/// 一个可回收、可预加载的 Player 包装
class PlayerHolder {
  final int index; // 视频索引
  final String path;
  final MediaInfo? media;
  final int cacheAheadSegmentCount;
  final FijkPlayer player = FijkPlayer();
  final ValueNotifier<bool> preparedNotifier = ValueNotifier(false);

  // 移除未使用的订阅字段
  bool _isDisposed = false;
  bool _isPrepared = false;
  bool _playable = false;
  double _volume = 1.0;
  double _speed = 1.0;
  bool _isLooping = true; // 添加循环播放标志，默认为true
  // 进度卡在结尾的兜底检测
  StreamSubscription<Duration>? _posSub;
  Timer? _loopGuardTimer;
  String _resolvedUri = ""; // 记录实际用于播放的地址，便于重置兜底
  int _operationToken = 0;

  PlayerHolder(
      {required this.index,
      required this.path,
      required this.cacheAheadSegmentCount,
      this.media});

  bool get isDisposed => _isDisposed;

  bool get isPrepared => _isPrepared;

  bool get playable => _playable;

  double get volume => _volume;

  double get speed => _speed;

  bool get isLooping => _isLooping; // 添加getter

  /// 仅预加载（不自动播放）
  Future<void> preload({int? token}) async {
    final int currentToken = token ?? _operationToken;
    await player.setOption(
        FijkOption.codecCategory, "mediacodec", 1); // 启用硬件解码（Android/iOS）
    await player.setOption(
        FijkOption.codecCategory, "mediacodec-auto-rotate", 1); // 自动旋转
    await player.setOption(FijkOption.codecCategory,
        "mediacodec-handle-resolution-change", 1); // 处理分辨率变化
    await player.setOption(
        FijkOption.playerCategory, "infbuf", 0); // 禁用无限缓冲，适合点播
    await player.setOption(
        FijkOption.playerCategory, "enable-accurate-seek", 1); // 启用精确 seek
    await player.setOption(FijkOption.codecCategory,
        "mediacodec-handle-resolution-change", 1); // 处理分辨率变化
    if (path == "") return;
    final cacheManager = M3u8CacheManager();
    String uri = getVideoRemotePath(path);
    try {
      final localUri = await cacheManager.preparePlayableUrl(uri,
          mediaInfo: media, cacheAheadSegmentCount: cacheAheadSegmentCount);
      uri = localUri;
    } catch (e) {
      // 出错时直接回退到原始可播放地址，避免一直卡缓冲
      log.i("_tiktok_player_play", "本地缓存播放解析出错：$e");
    }

    if (_isDisposed || _isPrepared || currentToken != _operationToken) return;
    player.addListener(_onPlayerStateChanged);
    await player.setDataSource(uri, autoPlay: false);
    if (_isDisposed || currentToken != _operationToken) return;
    await player.prepareAsync();
    if (_isDisposed || currentToken != _operationToken) return;
    _resolvedUri = uri;
    _isPrepared = true;
  }

  void _onPlayerStateChanged() async {
    if (!_playable) {
      _playable = player.isPlayable();
      preparedNotifier.value = _playable;
    }
    if (player.state == FijkState.completed && _isLooping) {
      try {
        if (_resolvedUri.isNotEmpty) {
          await player.stop();
          await player.reset();

          await player.setDataSource(_resolvedUri, autoPlay: true);
          await player.prepareAsync();
        } else {
          // 回退到原有方式
          await player.pause();
          await player.seekTo(0);
          await Future.delayed(const Duration(milliseconds: 120));
          await player.start();
        }
      } catch (_) {}
    }
  }

  /// 开始播放（若尚未 prepare，会等待）
  Future<void> play() async {
    if (_isDisposed) return;
    final int currentToken = ++_operationToken;
    if (!_isPrepared) {
      await preload(token: currentToken);
    }
    if (_isDisposed || currentToken != _operationToken) return;
    await player.start();
  }

  Future<void> pause() async {
    if (_isDisposed) return;
    _operationToken++;
    final cacheManager = M3u8CacheManager();
    if (player.state == FijkState.started) {
      cacheManager.stop(player.dataSource ?? "");
      await player.pause();
    } else if (player.state == FijkState.asyncPreparing) {
      try {
        await player.reset();
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    if (_isDisposed) return;
    _operationToken++;
    await player.stop();
  }

  Future<void> seekTo(Duration position) async {
    if (_isDisposed) return;
    await player.seekTo(position.inMilliseconds);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await player.setVolume(_volume);
  }

  Future<void> toggleMute() async {
    await setVolume(_volume > 0 ? 0.0 : 1.0);
  }

  Future<void> setSpeed(double s) async {
    _speed = s.clamp(0.5, 2.0);
    await player.setSpeed(_speed);
  }

  /// 设置循环播放
  Future<void> setLooping(bool loop) async {
    _isLooping = loop;
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      await player.stop();
      await player.reset();
      await player.release();
      player.removeListener(_onPlayerStateChanged);
      await _posSub?.cancel();
      _loopGuardTimer?.cancel();
    } catch (_) {}
    _isPrepared = false;
    preparedNotifier.value = false;
  }
}

/// 管理滑动窗口内的 Player（最多 capacity 个）
class PlayerPoolManager {
  List<MediaInfo> medias;
  final int capacity; // 例如 5
  final int cacheAheadSegmentCount;
  final Map<int, PlayerHolder> _holders = {};

  int currentIndex = 0;

  PlayerPoolManager(
      {required this.medias,
      this.capacity = 3,
      this.cacheAheadSegmentCount = 2}) {
    if (capacity < 1) {
      throw ArgumentError('Capacity must be at least 1');
    }
    if (medias.isEmpty) {
      throw ArgumentError('Media list cannot be empty');
    }
  }

  bool get isValid => medias.isNotEmpty;

  int get lastIndex => medias.length - 1;

  PlayerHolder? holderOf(int index) => _holders[index];

  /// 获取或创建某 index 的 holder，但不做预加载
  PlayerHolder? _getOrCreate(int index) {
    // 如果是广告，不创建 holder
    if (medias[index].isAds ?? false) {
      return null;
    }
    return _holders[index] ??= PlayerHolder(
        index: index,
        path: medias[index].videoUrl ?? "",
        media: medias[index],
        cacheAheadSegmentCount: cacheAheadSegmentCount);
  }

  /// 追加一批视频到池中（仅限未存在的索引）
  void append(List<MediaInfo> newMedias) {
    for (int i = 0; i < newMedias.length; i++) {
      final media = newMedias[i];
      final index = medias.length + i;
      if (!_holders.containsKey(index) && !(media.isAds ?? false)) {
        _holders[index] = PlayerHolder(
            index: index,
            path: media.videoUrl ?? "",
            media: media,
            cacheAheadSegmentCount: cacheAheadSegmentCount);
        medias.add(media);
      }
    }
  }

  /// 更新 medias 列表引用，用于广告插入后的同步
  void updateMedias(List<MediaInfo> newMedias) {
    medias = newMedias;
    // 清理已不存在的 holder
    final keysToRemove =
        _holders.keys.where((key) => key >= newMedias.length).toList();
    for (final key in keysToRemove) {
      final holder = _holders.remove(key);
      unawaited(holder?.dispose());
    }
  }

  ///   切到 newIndex：
  /// - 播放 newIndex
  /// - 预加载 newIndex +/- 1（优先同向）
  /// - 保证池内 <= capacity，并移除相反方向最远的一个
  Future<void> switchTo(int newIndex,
      {required ScrollDirection dir, bool autoPlay = true}) async {
    if (newIndex < 0 || newIndex > lastIndex) return;
    currentIndex = newIndex;
    // 添加浏览记录
    if (!(medias[newIndex].isAds ?? false)) {
      unawaited(
          WatchRecord.addWatchRecord(medias[newIndex], MediaType.videoShort));
    }
    // 1) 暂停上一个（只保留当前在播）
    _pauseOthers(except: newIndex);
    if (!(medias[newIndex].isAds ?? false)) {
      // 2) 准备并播放当前
      PlayerHolder? cur = _getOrCreate(newIndex);
      if (autoPlay) {
        await cur?.play();
      }
    }

    // 3) 预加载：优先同向邻居，其次反向邻居
    final List<int> preloadOrder = [];
    if (dir == ScrollDirection.forward) {
      // 向下（索引 +1）
      if (newIndex + 1 <= lastIndex) preloadOrder.add(newIndex + 1);
      if (newIndex - 1 >= 0) preloadOrder.add(newIndex - 1);
    } else if (dir == ScrollDirection.reverse) {
      // 向上（索引 -1）
      if (newIndex - 1 >= 0) preloadOrder.add(newIndex - 1);
      if (newIndex + 1 <= lastIndex) preloadOrder.add(newIndex + 1);
    } else {
      // idle：两侧都预加载
      if (newIndex + 1 <= lastIndex) preloadOrder.add(newIndex + 1);
      if (newIndex - 1 >= 0) preloadOrder.add(newIndex - 1);
    }

    for (final i in preloadOrder) {
      final h = _getOrCreate(i);
      // 只预加载，不播放
      unawaited(h?.preload());
    }

    // 4) 修剪池：保持最多 capacity 个
    _trimPool(dir: dir);
  }

  /// 只要还活着的 holder，暂停掉
  void _pauseOthers({required int except}) {
    _holders.forEach((i, h) {
      if (i != except) {
        if (h.player.state == FijkState.started ||
            h.player.state == FijkState.asyncPreparing) {
          unawaited(h.pause());
        }
      }
    });
  }

  /// 将窗口维持在 [currentIndex-2, currentIndex+2]（共 5）
  /// 当新加入导致 > capacity，则按【与滚动方向相反的一端优先丢弃】
  void _trimPool({required ScrollDirection dir}) {
    if (_holders.length <= capacity) return;

    // 构造目标窗口范围
    final int half = (capacity - 1) ~/ 2; // 5 -> 2
    int start = (currentIndex - half).clamp(0, lastIndex);
    int end = (currentIndex + half).clamp(0, lastIndex);

    // 若靠近边界，尽量扩展到 capacity 个
    while (end - start + 1 < capacity) {
      if (start > 0) {
        start--;
      } else if (end < lastIndex) {
        end++;
      } else {
        break;
      }
    }

    final shouldKeep = <int>{};
    for (int i = start; i <= end; i++) {
      shouldKeep.add(i);
    }

    // 需要移除的索引
    final toRemove =
        _holders.keys.where((k) => !shouldKeep.contains(k)).toList()..sort();

    if (toRemove.isEmpty) return;

    // 根据滚动方向相反的一端优先丢弃
    // 向下滚（forward），丢弃较小的索引；向上滚（reverse），丢弃较大的索引
    if (dir == ScrollDirection.forward) {
      // 移除最小的开始直到数量合规
      for (final i in toRemove) {
        if (_holders.length <= capacity) break;
        _disposeIndex(i);
      }
    } else if (dir == ScrollDirection.reverse) {
      // 移除最大的开始直到数量合规
      for (final i in toRemove.reversed) {
        if (_holders.length <= capacity) break;
        _disposeIndex(i);
      }
    } else {
      // idle：简单从两端各移除，直到合规
      int left = 0, right = toRemove.length - 1;
      while (_holders.length > capacity && left <= right) {
        _disposeIndex(toRemove[left++]);
        if (_holders.length > capacity && left <= right) {
          _disposeIndex(toRemove[right--]);
        }
      }
    }
  }

  void _disposeIndex(int i) {
    final h = _holders.remove(i);
    if (h != null) {
      unawaited(h.dispose());
    }
  }

  /// 主动清理所有
  Future<void> disposeAll() async {
    final futures = _holders.values.map((h) => h.dispose());
    await Future.wait(futures);
    _holders.clear();
  }

  /// 设置所有播放器的循环播放状态
  Future<void> setAllLooping(bool loop) async {
    final futures = _holders.values.map((h) => h.setLooping(loop));
    await Future.wait(futures);
  }

  /// 设置指定播放器的循环播放状态
  Future<void> setLooping(int index, bool loop) async {
    final holder = _holders[index];
    if (holder != null) {
      await holder.setLooping(loop);
    }
  }

  /// 获取指定播放器的循环播放状态
  bool getLooping(int index) {
    final holder = _holders[index];
    return holder?.isLooping ?? true;
  }
}

/// 对外控制器：支持在运行时向播放列表追加视频
class FijkTiktokFeedController extends ChangeNotifier {
  _FijkTiktokFeedPageState? _state;

  bool get attached => _state != null;

  void _attach(_FijkTiktokFeedPageState s) {
    _state = s;
  }

  // 移除未使用的 _detach 方法

  /// 获取当前播放列表（只读）
  List<MediaInfo> get medias => List.unmodifiable(_state?._medias ?? const []);

  void togglePause(bool pause) {
    final s = _state;
    if (s == null) return;
    s._coreController.togglePause(pause);
  }

  void resetMedias(List<MediaInfo> newMedias,
      {int initIndex = 0, bool autoPlay = false}) {
    final s = _state;
    if (s == null || newMedias.isEmpty) return;
    s.resetMedias(newMedias, initIndex: initIndex, autoPlay: autoPlay);
    notifyListeners();
  }

  /// 追加一批视频到播放列表尾部。
  void append(List<MediaInfo> newMedias) {
    final s = _state;
    if (s == null || newMedias.isEmpty) return;
    s.appendMedias(newMedias);
    notifyListeners();
  }

  /// 追加单个
  void appendOne(MediaInfo media, {bool autoPlay = false}) => append([media]);

  /// 设置所有播放器的循环播放状态
  Future<void> setAllLooping(bool loop) async {
    final s = _state;
    if (s == null) return;
    await s._coreController.setAllLooping(loop);
    notifyListeners();
  }

  /// 设置当前播放器的循环播放状态
  Future<void> setCurrentLooping(bool loop) async {
    final s = _state;
    if (s == null) return;
    await s._coreController.setCurrentLooping(loop);
    notifyListeners();
  }

  /// 获取当前播放器的循环播放状态
  bool getCurrentLooping() {
    final s = _state;
    if (s == null) return true;
    return s._coreController.getCurrentLooping();
  }
}

Future<List<MediaInfo>> getAdsMediaList(List<MediaInfo> medias) async {
  List<MediaInfo> newMedias = [];
  Advertise? ads = await getCommentAds(type: AdsType.shortVideoPlayAds);
  for (int i = 0; i < medias.length; i++) {
    newMedias.add(medias[i]);
    if (((i + 1) % 5 == 0) && ads != null) {
      newMedias.add(MediaInfo(
          isAds: true,
          coverImg: ads.cover,
          title: ads.title,
          adsId: ads.id,
          adsPath: ads.href,
          playable: false));
    }
  }
  return newMedias;
}
