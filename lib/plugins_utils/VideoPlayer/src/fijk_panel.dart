import 'dart:async';
import 'dart:math';

import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/comment_dialog.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/model/home/video_play_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/player_widget.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/enum.dart';
import '../../../app/model/home/config_model_model.dart';
import '../../../utils/dimens.dart';
import '../../../utils/light_model.dart';
import '../../../utils/screen.dart';
import '../../ImageLoader/ImageLoader.dart';
import '../fijk_player.dart';
import 'barrage_builder.dart';
import 'fijk_slider.dart';

class CustomFIJKPlayer extends StatefulWidget {
  final FijkPlayer player;
  final Size viewSize;
  final BuildContext buildContext;
  final Rect texturePos;

  const CustomFIJKPlayer(this.player,
      {super.key,
      required this.viewSize,
      required this.buildContext,
      required this.texturePos});

  @override
  State<CustomFIJKPlayer> createState() => _CustomFIJKPlayerState();
}

String _duration2String(Duration duration) {
  if (duration.inMilliseconds < 0) return "-: negtive";

  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  int inHours = duration.inHours;
  return inHours > 0
      ? "$inHours:$twoDigitMinutes:$twoDigitSeconds"
      : "$twoDigitMinutes:$twoDigitSeconds";
}

class _CustomFIJKPlayerState extends State<CustomFIJKPlayer> {
  FijkPlayer get player => widget.player;

  Duration _duration = Duration(); // 视频总时长
  Duration _currentPos = Duration(); // 当前播放位置
  double _bufferPos = .0; // 缓冲位置
  bool _playing = false; // 是否正在播放
  bool _prepared = false; // 是否已准备好
  String? _exception; // 异常信息
  bool _showTimePanel = false;

  bool _buffering = false; // 是否正在缓冲
  bool _openPlayerBoom = false; // 播放器震动状态

  double _bufferPercent = 0.0; // 缓冲下载速度

  double _seekPos = -1.0; // 拖动进度条时的目标位置

  StreamSubscription? _currentPosSubs; // 当前播放位置订阅

  StreamSubscription? _bufferingSubs; // 缓冲状态订阅

  StreamSubscription? _bufferPercentSubs; // 缓冲状态订阅

  StreamSubscription<CacheEvent>? _cacheSub; // 缓存数据订阅

  Timer? _hideTimer; // 隐藏控制栏的定时器
  bool _hideStuff = false; // 是否隐藏控制栏

  double _volume = 1.0; // 音量大小

  final barHeight = 40.0;

  bool get simpleModel => FIJKPlayerManager().simpleModel; // 是否为简单模式

  @override
  void initState() {
    super.initState();

    _duration = player.value.duration;
    _currentPos = player.currentPos;
    _prepared = player.state.index >= FijkState.prepared.index;
    _playing = player.state == FijkState.started;
    _exception = player.value.exception.message;
    _buffering = player.isBuffering;
    FIJKPlayerManager manager = FIJKPlayerManager();
    player.addListener(_playerValueChanged);
    _bufferingSubs = player.onBufferStateUpdate.listen((isBuffering) {
      setState(() => _buffering = isBuffering);
    });
    _getBoomStatus();
    M3u8CacheManager cacheManage = M3u8CacheManager();
    _cacheSub =
        cacheManage.onUrlProgress(manager.videoRemoteUri ?? "").listen((event) {
      if (event.speedKBps > 0) {
        setState(() {
          _bufferPos = event.progress; // 0.0~1.0
          log.i("_long_video_play",
              "当前下载速度${event.speedKBps},缓冲进度：${event.progress}");
          _bufferPercent = event.speedKBps; // KB/s
        });
      }
    }, onError: (_) {
      log.i("", "速度监听报错：$_");
    });

    _currentPosSubs = player.onCurrentPosUpdate.listen((v) async {
      int defaultSecond = manager.simpleModel ? 0 : 20;
      if (v.inSeconds >= defaultSecond && !manager.canContinuePlay) {
        await player.pause();
        bool? canPlay = await playableDialog(player,
            mediaInfo: manager.mediaPlayModel?.mediaInfo);
        if (canPlay ?? false) {
          manager.canContinuePlay = true;
          await player.start();
        }
      }
      setState(() => _currentPos = v);
    });
  }

  void _playerValueChanged() {
    FijkValue value = player.value;
    if (value.duration != _duration) {
      setState(() => _duration = value.duration);
    }

    FIJKPlayerManager manager = FIJKPlayerManager();
    if (manager.isFullScreen != value.fullScreen) {
      manager.isFullScreen = value.fullScreen;
    }

    bool playing = (value.state == FijkState.started);
    bool prepared = value.prepared;
    String? exception = value.exception.message;
    if (playing != _playing ||
        prepared != _prepared ||
        exception != _exception) {
      manager.playingController.add(playing);
      setState(() {
        _playing = playing;
        _prepared = prepared;
        _exception = exception;
      });
    }
  }

  void _playOrPause() {
    if (_playing == true) {
      player.pause();
    } else {
      player.start();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _hideTimer?.cancel();
    _cacheSub?.cancel();
    player.removeListener(_playerValueChanged);
    _currentPosSubs?.cancel();
    _bufferingSubs?.cancel();
    _bufferPercentSubs?.cancel();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 30), () {
      setState(() => _hideStuff = true);
    });
  }

  void _cancelAndRestartTimer() {
    if (_hideStuff == true) {
      _startHideTimer();
    }
    setState(() {
      _hideStuff = !_hideStuff;
    });
  }

  Future<void> _getBoomStatus() async {
    FIJKPlayerManager manager = FIJKPlayerManager();
    bool? status = await lightKV.getBool(manager.PLAYER_BOOM_KEY);
    _openPlayerBoom = status ?? false;
  }

  void _setVideoGo({bool isBack = false}) {
    int second = _currentPos.inSeconds;
    if (isBack) {
      second = second - 10 >= 0 ? second - 10 : 0;
    } else {
      second = second + 10 <= _duration.inSeconds
          ? second + 10
          : _currentPos.inSeconds;
    }
    player.seekTo(second * 1000); // 转换为毫秒
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: screen.screenWidth,
        child: GestureDetector(
            onTap: _cancelAndRestartTimer,
            child: AbsorbPointer(
                absorbing: _hideStuff,
                child: Stack(children: [
                  Column(children: [
                    _buildFIJKPlayerHeader(),
                    Expanded(
                        child: Stack(children: [
                      if (!_showTimePanel) ...[
                        if (!simpleModel) _buildFIJKPlayerBarrage(),
                        _buildFIJKPlayerHitArea()
                      ]
                    ])),
                    _buildFIJKPlayerFooter()
                  ]),
                  _buildShowTimePanel(),
                  // if (!simpleModel) _buildVideoCantPlayTip(),
                  if (_exception != null) _buildVideoErrorTip(),
                  if (_prepared && !_playing && !_showTimePanel)
                    _buildPauseAds()
                ]))));
  }

  Widget _buildPauseAds() {
    FIJKPlayerManager manager = FIJKPlayerManager();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    return FutureBuilder(
        future: getCommentAds(type: AdsType.longVideoPauseAds),
        builder: (context, snapshot) {
          Advertise? ad = snapshot.data;
          if (ad == null || (shareKeys.isVip() && !(ad.vipShow ?? false))) {
            return SizedBox();
          }
          return Positioned.fill(
              child: Container(
                  color: Colors.black.withOpacity(.5),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageLoader.withP(ad.cover, width: 160, height: 131)
                            .load(),
                        SizedBox(height: 8),
                        GestureDetector(
                            onTap: () => manager.player?.start(),
                            child: Container(
                                width: 68,
                                height: 25,
                                alignment: Alignment.center,
                                color: ThemeManager().getColor(ThemeColor.bg),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("播放",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: ThemeManager().getColor(
                                                  ThemeColor.primary))),
                                      SizedBox(width: 5),
                                      Image.asset(R.assetsImgIconPlayerPause,
                                          width: 11)
                                    ])))
                      ])));
        });
  }

  Widget _buildVideoErrorTip() {
    return Positioned.fill(
        child: Container(
            color: Colors.black.withOpacity(.5),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text("视频播放出错: $_exception",
                style: TextStyle(fontSize: 16, color: Colors.white))));
  }

  Widget _buildFIJKPlayerBarrage() {
    return BarrageBuilder(player,
        controller: FIJKPlayerManager().barrageController,
        mediaId: FIJKPlayerManager().mediaPlayModel?.mediaInfo?.id ?? 0);
  }

  Widget _buildVideoCantPlayTip() {
    ThemeManager theme = Get.find<ThemeManager>();
    FIJKPlayerManager manager = FIJKPlayerManager();
    MediaInfo? media = manager.mediaPlayModel?.mediaInfo;
    if (media?.payType == PaymentType.freePaymentType ||
        (manager.canContinuePlay)) {
      return SizedBox();
    }
    return Positioned(
        left: 10,
        bottom: barHeight - 10,
        child: Container(
            height: Dimens.pt35,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
            color: theme.getColor(media?.payType == PaymentType.vipPaymentType
                ? ThemeColor.textYellow
                : ThemeColor.red),
            child: Text(media?.payType == PaymentType.vipPaymentType
                ? "开通会员,观看完整版"
                : "支付${(media?.price ?? 0) / 100}金币,观看完整版")));
  }

  Widget _buildShowTimePanel() {
    if (!_showTimePanel) return SizedBox();
    FIJKPlayerManager manager = FIJKPlayerManager();
    MediaInfo? media = manager.mediaPlayModel?.mediaInfo;
    List<SecondsPlayInfoModel> showTimes = media?.showTime ?? [];
    return Container(
        color: Colors.black.withOpacity(.5),
        padding: EdgeInsets.symmetric(
            horizontal: manager.isFullScreen ? 30 : 10,
            vertical: manager.isFullScreen ? 60 : 10),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
                onTap: () => setState(() {
                      _showTimePanel = false;
                      player.start();
                    }),
                child: const Icon(Icons.close_rounded,
                    size: 25, color: Colors.white))
          ]),
          SizedBox(height: 20),
          const Text("跳到你最喜欢的动作",
              style: TextStyle(fontSize: 16, color: Colors.white)),
          SizedBox(height: 12),
          SizedBox(
              height: manager.isFullScreen ? 60 : 60,
              child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => GestureDetector(
                      onTap: () {
                        player.seekTo(
                            showTimes[index].duration?.inMilliseconds ?? 0);
                        player.start();
                        setState(() => _showTimePanel = false);
                      },
                      child: Container(
                          margin: EdgeInsets.only(right: 15),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration:
                              BoxDecoration(color: const Color(0xFF1D1A19)),
                          child: Column(children: [
                            Text(showTimes[index].name ?? "",
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                                '${_duration2String(showTimes[index].duration!)} ',
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF8A8785))),
                          ]))),
                  separatorBuilder: (_, index) => SizedBox(width: 15),
                  itemCount: showTimes.length)),
        ]));
  }

  Widget _buildFIJKPlayerHitArea() {
    ThemeManager theme = Get.find<ThemeManager>();
    if (_buffering) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          getLoadingWidget(),
          Text("${_bufferPercent.toStringAsFixed(2)} KB/s",
              style: TextStyle(
                  fontSize: 14.0, color: theme.getColor(ThemeColor.primary)))
        ]),
      );
    }
    return AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 0.7,
        duration: Duration(milliseconds: 300),
        child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
              onTap: () => _setVideoGo(isBack: true),
              child: Image.asset(R.assetsImgIconPlayerBack, width: 24)),
          const SizedBox(width: 56),
          GestureDetector(
              onTap: () => _playOrPause(),
              child: Image.asset(
                  _playing
                      ? R.assetsImgIconPlayerPlay
                      : R.assetsImgIconPlayerPause,
                  height: 29)),
          const SizedBox(width: 56),
          GestureDetector(
              onTap: () => _setVideoGo.call(),
              child: Image.asset(R.assetsImgIconPlayerGo, width: 24)),
          // Text("${_bufferPercent.toStringAsFixed(2)} KB/s",
          //     style: TextStyle(
          //         fontSize: 12.0, color: theme.getColor(ThemeColor.textYellow)))
        ])));
  }

  Widget _buildFIJKPlayerFooter() {
    FIJKPlayerManager manager = FIJKPlayerManager();
    double duration = _duration.inMilliseconds.toDouble();
    double currentValue =
        _seekPos > 0 ? _seekPos : _currentPos.inMilliseconds.toDouble();
    currentValue = min(currentValue, duration);
    currentValue = max(currentValue, 0);
    return AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 0.8,
        duration: Duration(milliseconds: 300),
        child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: manager.isFullScreen ? 30 : 12.5),
            height: barHeight,
            child: Row(children: [
              GestureDetector(
                  onTap: () => _playOrPause(),
                  child: Image.asset(
                      _playing
                          ? R.assetsImgIconPlayerPlay
                          : R.assetsImgIconPlayerPause,
                      height: 15)),
              SizedBox(width: 10),
              _duration.inMilliseconds == 0
                  ? Expanded(child: Center())
                  : Expanded(
                      child: FIJKSlider(
                          value: currentValue,
                          cacheValue: _bufferPos,
                          min: 0.0,
                          max: duration,
                          onChanged: (v) {
                            _startHideTimer();
                            setState(() {
                              _seekPos = v;
                            });
                          },
                          onChangeEnd: (v) {
                            setState(() {
                              player.seekTo(v.toInt());
                              _currentPos =
                                  Duration(milliseconds: _seekPos.toInt());
                              _seekPos = -1;
                            });
                          })),
              Padding(
                  padding: EdgeInsets.only(right: 3.0, left: 3.0),
                  child: Text("${_duration2String(_currentPos)} /",
                      style: TextStyle(fontSize: 14.0, color: Colors.white))),
              Padding(
                  padding: EdgeInsets.only(right: 3.0),
                  child: Text(_duration2String(_duration),
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white.withOpacity(.6)))),
              SizedBox(width: 5),
              GestureDetector(
                  onTap: () {
                    widget.player.value.fullScreen
                        ? player.exitFullScreen()
                        : player.enterFullScreen();
                  },
                  child: Image.asset(R.assetsImgIconPlayerFull, width: 20))
            ])));
  }

  Widget _buildFIJKPlayerHeader() {
    FIJKPlayerManager manager = FIJKPlayerManager();
    ThemeManager theme = Get.find<ThemeManager>();
    MediaInfo? media = manager.mediaPlayModel?.mediaInfo;
    List<SecondsPlayInfoModel> showTimes = media?.showTime ?? [];
    return Row(children: [
      if (!simpleModel || manager.isFullScreen)
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (manager.isFullScreen) {
                player.exitFullScreen(); // 退出全屏
              } else {
                manager.disposePlayer(); // 销毁播放器实例
                Get.back(); // 返回上一页
              }
            },
            child: Container(
                margin: manager.isFullScreen
                    ? EdgeInsets.all(30)
                    : EdgeInsets.all(12.5),
                child: Image.asset(R.assetsImgIconVideoBank, width: 24))),
      Spacer(),
      if (!simpleModel)
        AnimatedOpacity(
            opacity: _hideStuff ? 0.0 : 0.8,
            duration: Duration(milliseconds: 300),
            child: Row(children: [
              if (!_showTimePanel) ...[
                if (showTimes.isNotEmpty)
                  GestureDetector(
                      onTap: () {
                        player.pause();
                        setState(() => _showTimePanel = true);
                      },
                      child: Image.asset(R.assetsImgIconPlayerQuicklyPlay,
                          width: 20)),
                // SizedBox(width: 15),
                // GestureDetector(
                //     behavior: HitTestBehavior.opaque,
                //     onTap: () async {
                //       if (!_openPlayerBoom) {
                //         bool canOpen = await openBoomDialog();
                //         setState(() => _openPlayerBoom = canOpen);
                //       } else {
                //         setState(() => _openPlayerBoom = false);
                //         manager.setPlayerBoom(false);
                //       }
                //     },
                //     child: Image.asset(
                //         _openPlayerBoom
                //             ? R.assetsImgIconPlayerBoomOpen
                //             : R.assetsImgIconPlayerBoom,
                //         width: 22)),
                // SizedBox(width: 15),
                // GestureDetector(
                //     behavior: HitTestBehavior.opaque,
                //     onTap: () {
                //       if (manager.isFullScreen) {
                //         manager.player?.exitFullScreen();
                //       }
                //       addFloatingPlayer(context);
                //       Get.back();
                //     },
                //     child: Image.asset(R.assetsImgIconPlayerPip, width: 22))
              ]
            ])),
      SizedBox(width: 15)
    ]);
  }
}
