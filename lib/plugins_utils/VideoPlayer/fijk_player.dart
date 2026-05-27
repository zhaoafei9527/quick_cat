import 'dart:async';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/barrage_builder.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/fijk_panel.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import 'package:quick_cat_client/plugins_utils/video_player_core/video_player_core.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/screen.dart';

import '../../app/model/home/topic_list_model.dart';
import '../../app/model/home/video_play_model.dart';
import '../../utils/light_model.dart';

/// 长视频 / 帖子详情通用播放器组件。
///
/// 内部基于 [CoreFijkVideoPlayer]，并复用全局单例 [FIJKPlayerManager] 提供的
/// `FijkPlayer` 实例，以便上层（视频详情页、画中画等）可以独立控制同一个播放器。
///
/// 关键设计：本组件**不**直接调用 `setDataSource` / `prepareAsync`，所有数据源
/// 加载、本地代理、缓存预取、循环播放都委托给 [CoreFijkVideoPlayer]，避免与
/// [FIJKPlayerManager] 形成并发的数据源设置，导致 ijk 抛出 `IllegalStateException`。
class FIJKVideoPlayer extends StatefulWidget {
  final String url;
  final String? title;
  final String? cover;
  final bool autoPlay;
  final bool canPlay;
  final bool prepareOnLoad;

  /// 是否为简单模式（用于帖子详情等只需点击播放/暂停的场景）。
  final bool? simpleModel;

  /// 是否循环播放。
  final bool? loop;

  /// 视频元信息，可空。
  final MediaInfo? mediaInfo;

  /// 显示宽高比（width / height 的倒数）。
  final double? aspectRatio;

  /// 播放进度后预缓存的 m3u8 分片数。
  final int cacheAheadSegmentCount;

  /// 完成播放回调。设置后会覆盖默认的 [loop] 行为。
  final Function? onCompleted;

  const FIJKVideoPlayer({
    super.key,
    required this.url,
    this.title,
    this.cover,
    this.simpleModel = false,
    this.autoPlay = true,
    this.canPlay = true,
    this.prepareOnLoad = false,
    this.loop = true,
    this.aspectRatio = 9 / 16,
    this.cacheAheadSegmentCount = 2,
    this.mediaInfo,
    this.onCompleted,
  });

  @override
  State<FIJKVideoPlayer> createState() => _FIJKVideoPlayerState();
}

class _FIJKVideoPlayerState extends State<FIJKVideoPlayer> {
  final FIJKPlayerManager _manager = FIJKPlayerManager();
  FijkPlayer? _attachedPlayer;
  String _videoUri = "";

  @override
  void initState() {
    super.initState();
    _initPlayerState();
  }

  @override
  void didUpdateWidget(covariant FIJKVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.simpleModel != widget.simpleModel ||
        oldWidget.canPlay != widget.canPlay) {
      _initPlayerState();
    }
  }

  void _initPlayerState() {
    final nextUri = getVideoRemotePath(widget.url);
    _videoUri = nextUri;
    _manager.videoRemoteUri = nextUri;
    _manager.playMark = false;

    if (_manager.isShrinkModel) {
      // 从画中画 / 缩略模式返回时，复用已有播放器实例，不重建。
      _manager.closeShrinkModel();
    } else {
      // 仅创建一个空的 FijkPlayer，数据源由 CoreFijkVideoPlayer 加载。
      _manager.ensurePlayer();
    }

    if (widget.simpleModel == true) {
      _manager.setSimpleModel(canPlay: widget.canPlay);
    } else {
      _manager.simpleModel = false;
      _manager.canContinuePlay = true;
      _manager.barrageController ??= BarrageController();
    }

    _attachPlayerListener();
    if (mounted) setState(() {});
  }

  void _attachPlayerListener() {
    final player = _manager.player;
    if (_attachedPlayer == player) return;
    _attachedPlayer?.removeListener(_onPlayerStateChanged);
    _attachedPlayer = player;
    _attachedPlayer?.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() {
    final player = _manager.player;
    if (player == null) return;
    final state = player.state;
    if (state == FijkState.started) {
      _manager.playMark = true;
      _manager.playingController.add(true);
    } else if (state == FijkState.paused) {
      _manager.playingController.add(false);
    }
  }

  @override
  void dispose() {
    _attachedPlayer?.removeListener(_onPlayerStateChanged);
    _attachedPlayer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager theme = Get.find<ThemeManager>();
    // simpleModel 下需要预加载到 prepared 才能渲染首帧；同时禁用 ijk 自动 loop
    // （改由 CoreFijkVideoPlayer 控制），避免和 onCompleted 回调冲突。
    final bool isSimple = widget.simpleModel == true;
    final bool loopByCore =
        widget.onCompleted == null && (widget.loop ?? false);

    return SizedBox(
        height: screen.screenWidth * widget.aspectRatio!,
        width: screen.screenWidth,
        child: CoreFijkVideoPlayer(
            item: CoreVideoItem(
              id: widget.mediaInfo?.id,
              url: _videoUri,
              title: widget.title ?? widget.mediaInfo?.title,
              coverUrl: widget.cover,
              extra: widget.mediaInfo,
            ),
            player: _manager.player,
            releasePlayerOnDispose: false,
            autoPlay: widget.autoPlay,
            prepareOnLoad: isSimple || widget.prepareOnLoad,
            loop: loopByCore,
            aspectRatio: 1 / widget.aspectRatio!,
            fs: true,
            backgroundColor: theme.getColor(ThemeColor.bg),
            cacheConfig: CoreVideoCacheConfig(
              aheadSegmentCount: widget.cacheAheadSegmentCount,
            ),
            onCompleted: widget.onCompleted == null
                ? null
                : () => widget.onCompleted!.call(),
            onPlayableUrlResolved: (url) {
              _videoUri = url;
              _manager.videoRemoteUri = url;
            },
            coverBuilder: (_, __) =>
                Image(image: ImageLoader.withP(widget.cover).loadMemory()),
            placeholderBuilder: (_, __, ___) => Container(
                  color: theme.getColor(ThemeColor.bg),
                  child: Stack(alignment: Alignment.center, children: [
                    ImageLoader.withP(widget.cover, width: screen.screenWidth)
                        .load(),
                    getLoadingWidget(),
                  ]),
                ),
            panelBuilder: (player, data, context, size, rect) =>
                CustomFIJKPlayer(player,
                    buildContext: context, viewSize: size, texturePos: rect)));
  }
}

/// 简易模式下使用的播放面板。
///
/// - 加载/缓冲中：显示一个 loading 指示器（首帧封面由 [CoreFijkVideoPlayer] 渲染）
/// - 已准备好但未播放：显示大号的播放按钮，点击进入播放
/// - 播放中：透明面板，单击切换暂停
class SimpleFIJKPanel extends StatefulWidget {
  final FijkPlayer player;
  final Size viewSize;
  final BuildContext buildContext;
  final Rect texturePos;

  const SimpleFIJKPanel(
    this.player, {
    super.key,
    required this.viewSize,
    required this.buildContext,
    required this.texturePos,
  });

  @override
  State<SimpleFIJKPanel> createState() => _SimpleFIJKPanelState();
}

class _SimpleFIJKPanelState extends State<SimpleFIJKPanel> {
  bool _prepared = false;
  bool _playing = false;
  bool _buffering = false;
  StreamSubscription<bool>? _bufferingSub;

  @override
  void initState() {
    super.initState();
    final FijkValue value = widget.player.value;
    _prepared = value.prepared;
    _playing = value.state == FijkState.started;
    _buffering = widget.player.isBuffering;
    widget.player.addListener(_onPlayerChanged);
    _bufferingSub = widget.player.onBufferStateUpdate.listen((b) {
      if (!mounted) return;
      setState(() => _buffering = b);
    });
  }

  void _onPlayerChanged() {
    if (!mounted) return;
    final value = widget.player.value;
    final p = value.prepared;
    final s = value.state == FijkState.started;
    if (p != _prepared || s != _playing) {
      setState(() {
        _prepared = p;
        _playing = s;
      });
    }
  }

  void _togglePlay() {
    if (_playing) {
      widget.player.pause();
    } else {
      widget.player.start();
    }
  }

  @override
  void dispose() {
    _bufferingSub?.cancel();
    widget.player.removeListener(_onPlayerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _togglePlay,
      child: Center(child: _buildCenter()),
    );
  }

  Widget _buildCenter() {
    if (_buffering) {
      return getLoadingWidget();
    }
    if (_playing) return const SizedBox.shrink();
    if (!_prepared) {
      // 等待 prepare：依赖 CoreFijkVideoPlayer 的 placeholderBuilder 渲染封面+loading，
      // 这里不再叠加 loading，避免双 loading。
      return const SizedBox.shrink();
    }
    return Image.asset(R.assetsImgIconPlayerPause, height: 40);
  }
}

/// 全局单例：管理整个 App 内最多一个长视频播放器实例与共享状态。
///
/// 注意：本类**不再**在内部主动调用 `setDataSource`，调用方应该把数据源加载交给
/// [CoreFijkVideoPlayer]（[FIJKVideoPlayer] 已经处理）或显式调用 [switchVideo]。
class FIJKPlayerManager {
  static final FIJKPlayerManager _instance = FIJKPlayerManager._internal();

  factory FIJKPlayerManager() => _instance;

  FIJKPlayerManager._internal();

  String playerBoomKey = "_key_set_player_boom";

  // 播放器全局状态部分
  bool isFullScreen = false; // 是否全屏状态
  bool isShrinkModel = false; // 是否缩略 / 画中画模式
  bool simpleModel = false; // 是否简单模式
  bool isOpenBoom = false; // 震动模式开关
  bool canContinuePlay = false; // 是否可以继续播放（计费 / 会员校验后）
  bool playMark = false; // 是否已尝试播放过

  final StreamController<bool> playingController =
      StreamController<bool>.broadcast();

  Stream<bool> get isPlaying => playingController.stream;

  String? videoRemoteUri;
  FijkPlayer? _player;
  MediaPlayModel? _mediaPlayModel;
  OverlayEntry? overlayEntry; // 画中画弹层实例
  Offset floatingPosition = const Offset(20, 100); // 画中画位置
  BarrageController? barrageController;

  /// 仅获取或创建一个 [FijkPlayer]，**不**设置数据源。
  ///
  /// 这是推荐的初始化方式：把数据源管理统一交给 [CoreFijkVideoPlayer]，避免与
  /// 内部 `setDataSource` 形成并发，触发 ijk `IllegalStateException`。
  FijkPlayer ensurePlayer() {
    final p = _player;
    if (p == null || p.state == FijkState.end || p.state == FijkState.error) {
      try {
        p?.release();
      } catch (_) {}
      _player = FijkPlayer();
    }
    return _player!;
  }

  /// 获取或创建播放器实例。
  ///
  /// 仅当显式传入 [url] 且与当前 dataSource 不同的情况下才会调用 `setDataSource`。
  FijkPlayer getPlayer({String? url, bool autoPlay = true}) {
    final player = ensurePlayer();
    if (url == null || player.dataSource == url) return player;
    _safeSetDataSource(player, url, autoPlay: autoPlay);
    return player;
  }

  /// 切换播放源。
  Future<void> switchVideo(String url, {bool autoPlay = true}) async {
    final player = ensurePlayer();
    playMark = false;
    final videoUri = getVideoRemotePath(url);
    videoRemoteUri = videoUri;
    await _safeSetDataSource(player, videoUri, autoPlay: autoPlay);
    if (!autoPlay &&
        player.state != FijkState.asyncPreparing &&
        player.state != FijkState.prepared) {
      try {
        await player.prepareAsync();
      } catch (e) {
        log.i("_fijk_player_log", "prepareAsync error: $e");
      }
    }
  }

  /// 内部安全地设置数据源：先 reset 到 Idle 状态，避免 ijk 抛 `IllegalStateException`。
  Future<void> _safeSetDataSource(FijkPlayer player, String url,
      {bool autoPlay = true}) async {
    final state = player.state;
    if (state != FijkState.idle &&
        state != FijkState.end &&
        state != FijkState.error) {
      try {
        await player.reset();
      } catch (e) {
        log.i("_fijk_player_log", "reset before setDataSource error: $e");
      }
    }
    try {
      await player.setDataSource(url, autoPlay: autoPlay);
    } catch (e) {
      log.i("_fijk_player_log", "setDataSource error: $e");
    }
  }

  MediaPlayModel? get mediaPlayModel => _mediaPlayModel;

  FijkPlayer? get player => _player;

  set mediaPlayModel(MediaPlayModel? media) => _mediaPlayModel = media;

  void setSimpleModel({bool? canPlay}) {
    simpleModel = true;
    canContinuePlay = canPlay ?? true;
    _mediaPlayModel = null;
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry!.dispose();
      overlayEntry = null;
    }
  }

  void setPlayerBoom(bool status) {
    isOpenBoom = status;
    lightKV.setBool(playerBoomKey, status);
  }

  void togglePlay() {
    final p = _player;
    if (p == null) return;
    final playing = p.state == FijkState.started;
    if (playing) {
      p.pause();
      playingController.add(false);
    } else if (canContinuePlay) {
      p.start();
      playingController.add(true);
    }
  }

  void closeShrinkModel() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    isShrinkModel = false;
    isFullScreen = false;
    overlayEntry = null;
  }

  /// 销毁播放器实例。
  Future<void> disposePlayer() async {
    final cacheManager = M3u8CacheManager();
    final p = _player;
    if (p == null) return;
    try {
      isShrinkModel = false;
      isFullScreen = false;
      simpleModel = false;
      canContinuePlay = false;
      playMark = false;
      cacheManager.stop(videoRemoteUri ?? "");
      barrageController?.dispose();
      await p.stop();
      await p.release();
      overlayEntry?.remove();
      overlayEntry?.dispose();
    } catch (e) {
      log.i("_fijk_player_log", 'Error disposing player: $e');
    }
    _player = null;
    overlayEntry = null;
    barrageController = null;
  }

  Future<void> pauseForAppLifecycle() async {
    final p = _player;
    if (p == null) return;
    try {
      if (p.state == FijkState.started ||
          p.state == FijkState.asyncPreparing ||
          p.state == FijkState.prepared) {
        await p.pause();
        playingController.add(false);
      }
    } catch (e) {
      log.i("_fijk_player_log", 'Error pausing player for lifecycle: $e');
    }
  }

  Future<void> disposeForAppExit() async {
    await disposePlayer();
  }

  /// 是否存在有效的播放器实例。
  bool get hasPlayer =>
      _player != null &&
      _player!.state != FijkState.end &&
      _player!.state != FijkState.error;

  FijkState? get playerState => _player?.state;
}
