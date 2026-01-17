import 'dart:async';

import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/barrage_builder.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/fijk_panel.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:get/get.dart';

import '../../app/model/home/topic_list_model.dart';
import '../../app/model/home/video_play_model.dart';
import '../../utils/light_model.dart';

class FIJKVideoPlayer extends StatefulWidget {
  final String url;
  final String? title;
  final String? cover;
  final bool autoPlay;
  final bool canPlay;
  final bool? simpleModel; // 是否为简单模式
  final bool? loop; // 是否循环播放
  final MediaInfo? mediaInfo; // 视频信息
  final double? aspectRatio;
  Function? onCompleted; // 完成播放会调

  FIJKVideoPlayer(
      {super.key,
      required this.url,
      this.title,
      this.cover,
      this.simpleModel = false,
      this.autoPlay = true,
      this.canPlay = true,
      this.loop = true,
      this.aspectRatio = 9 / 16,
      this.mediaInfo,
      this.onCompleted});

  @override
  State<FIJKVideoPlayer> createState() => _FIJKVideoPlayerState();
}

class _FIJKVideoPlayerState extends State<FIJKVideoPlayer> {
  bool _playable = false;
  String videoUri = "";

  @override
  void initState() {
    super.initState();
    initPlayVideo();
  }

  Future<void> initPlayVideo() async {
    final cacheManager = M3u8CacheManager();
    videoUri = getVideoRemotePath(widget.url);
    try {
      final playableUrl = await cacheManager.preparePlayableUrl(videoUri,
          mediaInfo: widget.mediaInfo);
      videoUri = playableUrl;
    } catch (e) {
      // 出错时直接回退到原始可播放地址，避免一直卡缓冲
      videoUri = videoUri;
    }

    // 使用 FIJKPlayerManager 获取或创建播放器实例
    final playerManager = FIJKPlayerManager();
    playerManager.player?.setLoop(0);
    playerManager.videoRemoteUri = videoUri;
    if (playerManager.isShrinkModel) {
      // 返回缩略模式不要重建播放器
      playerManager.closeShrinkModel();
      _playable = true;
      setState(() {});
    } else {
      // 获取或创建播放器实例
      playerManager.getPlayer(url: videoUri, autoPlay: true);
    }

    // 如果是简单模式，设置播放器为简单模式
    if (widget.simpleModel == true) {
      playerManager.setSimpleModel(canPlay: widget.canPlay);
    } else {
      playerManager.barrageController = BarrageController();
    }

    // 添加状态监听器
    playerManager.player?.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() async {
    final playerManager = FIJKPlayerManager();
    if (!_playable && playerManager.player != null) {
      setState(() => _playable = playerManager.player!.isPlayable());
    }
    if (playerManager.player?.state == FijkState.prepared) {
      print(
          "widget.autoPlay${widget.autoPlay}===>playerManager.playMark${playerManager.playMark}");
      if (!widget.autoPlay && !playerManager.playMark) {
        playerManager.player?.pause();
      }
    }
    if (playerManager.player?.state == FijkState.started) {
      playerManager.playMark = true;
    }
    if (playerManager.player?.state == FijkState.completed) {
      if (widget.onCompleted != null) {
        widget.onCompleted?.call();
      } else if (widget.loop ?? false) {
        await playerManager.player?.stop();
        await playerManager.player?.reset();
        await playerManager.player?.setDataSource(videoUri, autoPlay: true);
        await playerManager.player?.prepareAsync();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    final playerManager = FIJKPlayerManager();
    playerManager.player?.removeListener(_onPlayerStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    final playerManager = FIJKPlayerManager();

    return _playable && playerManager.hasPlayer
        ? FijkView(
            player: playerManager.player!,
            color: theme.getColor(ThemeColor.bg),
            panelBuilder: (player, data, context, size, rect) =>
                CustomFIJKPlayer(player,
                    buildContext: context, viewSize: size, texturePos: rect),
            height: screen.screenWidth * widget.aspectRatio!,
            fs: true,
            width: screen.screenWidth)
        : Container(
            height: screen.screenWidth * widget.aspectRatio!,
            width: screen.screenWidth,
            color: theme.getColor(ThemeColor.bg),
            child: Stack(alignment: Alignment.center, children: [
              ImageLoader.withP(widget.cover, width: screen.screenWidth).load(),
              getLoadingWidget()
            ]));
  }
}

class FIJKPlayerManager {
  // 静态单例实例
  static final FIJKPlayerManager _instance = FIJKPlayerManager._internal();

  factory FIJKPlayerManager() => _instance;

  FIJKPlayerManager._internal();

  String PLAYER_BOOM_KEY = "_key_set_player_boom";

  // 播放器全剧状态部分
  bool isFullScreen = false; // 是否全屏状态
  bool isShrinkModel = false; // 是否缩放模式
  bool simpleModel = false; // 是否简单模式
  bool isOpenBoom = false; // showTime 震动是否开启
  bool canContinuePlay = false; // 是否可以继续播放
  bool playMark = false; // 标记是否已经尝试播放过
  final StreamController<bool> playingController = StreamController.broadcast();

  Stream<bool> get isPlaying => playingController.stream;
  String? videoRemoteUri;
  FijkPlayer? _player;
  MediaPlayModel? _mediaPlayModel;
  OverlayEntry? overlayEntry; // 画中画弹层实例
  Offset floatingPosition = Offset(20, 100); // 画中画模式时在屏幕中的位置
  BarrageController? barrageController;

  // 获取播放器实例
  FijkPlayer getPlayer({String? url, bool autoPlay = true}) {
    if (_player == null ||
        _player!.state == FijkState.end ||
        _player!.state == FijkState.error) {
      // 如果没有实例或实例已结束/错误，创建新实例
      _player?.release(); // 释放旧实例
      _player = FijkPlayer();
      // configurePlayer(_player!);
      if (url != null) {
        _player!.setDataSource(url, autoPlay: autoPlay).catchError((e) {
          log.i("_fijk_player_log", 'Error setting data source: $e');
        });
      }
    } else if (url != null && _player!.dataSource != url) {
      // 如果 URL 不同，重置并设置新数据源
      _player!.reset().then((_) {
        _player!.setDataSource(url, autoPlay: autoPlay).catchError((e) {
          log.i("_fijk_player_log", 'Error setting data source: $e');
        });
      });
    }
    return _player!;
  }

  MediaPlayModel? get mediaPlayModel => _mediaPlayModel;

  FijkPlayer? get player => _player;

  set mediaPlayModel(media) => _mediaPlayModel = media;

  void switchVideo(String url, {bool autoPlay = true}) async {
    await player?.reset();
    playMark = false; // 恢复标志
    String videoUri = getVideoRemotePath(url);
    await player?.setDataSource(videoUri, autoPlay: autoPlay);
    if (player?.state != FijkState.asyncPreparing) {
      await player?.prepareAsync();
    }
  }

  void setSimpleModel({bool? canPlay}) async {
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
    lightKV.setBool(PLAYER_BOOM_KEY, status);
  }

  void togglePlay() {
    bool playing = player?.state == FijkState.started;
    if (playing) {
      player?.pause();
      playingController.add(false);
    } else {
      if (canContinuePlay) {
        player?.start();
        playingController.add(true);
      }
    }
  }

  void closeShrinkModel() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    isShrinkModel = false;
    isFullScreen = false;
    overlayEntry = null;
  }

  // 销毁播放器实例
  void disposePlayer() async {
    final cacheManager = M3u8CacheManager();
    FIJKPlayerManager playerManager = FIJKPlayerManager();
    if (_player != null) {
      try {
        isShrinkModel = false;
        isFullScreen = false;
        simpleModel = false;
        canContinuePlay = false;
        playMark = false;
        cacheManager.stop(playerManager.videoRemoteUri ?? "");
        barrageController?.dispose();
        await _player!.stop(); // 先停止播放
        await _player!.release(); // 释放资源
        overlayEntry?.remove();
        overlayEntry?.dispose();
      } catch (e) {
        log.i("_fijk_player_log", 'Error disposing player: $e');
      }
      _player = null;
      overlayEntry = null;
      barrageController = null;
    }
  }

  // 检查是否存在有效播放器实例
  bool get hasPlayer =>
      _player != null &&
      _player!.state != FijkState.end &&
      _player!.state != FijkState.error;

  // 获取当前播放器状态
  FijkState? get playerState => _player?.state;
}
