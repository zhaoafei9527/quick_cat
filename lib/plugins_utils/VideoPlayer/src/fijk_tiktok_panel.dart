import 'dart:async';
import 'dart:math';

import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/comment_dialog.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/modules/short_video_player/controllers/short_video_player_controller.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/player_widget.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/common_util.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../app/data/enum.dart';
import '../../../app/model/home/topic_list_model.dart';
import '../../../utils/dimens.dart';
import '../../../utils/screen.dart';
import '../fjik_tiktok_player.dart';
import 'fijk_slider.dart';
import 'head_animate_view.dart';
import 'm3u8_cache_manager.dart';

class FijkTiktokPanel extends StatefulWidget {
  final FijkPlayer player;
  final Size viewSize;
  final BuildContext buildContext;
  final Rect texturePos;
  final MediaInfo? mediaInfo;
  final FijkTiktokFeedController? controller;

  const FijkTiktokPanel(this.player,
      {super.key,
      required this.viewSize,
      required this.mediaInfo,
      this.controller,
      required this.buildContext,
      required this.texturePos});

  @override
  State<FijkTiktokPanel> createState() => _FijkTiktokPanelState();
}

class _FijkTiktokPanelState extends State<FijkTiktokPanel> {
  FijkPlayer get player => widget.player;
  FijkPlayer? _attachedPlayer; // 记录当前已绑定监听的player

  Duration _duration = Duration(); // 视频总时长
  Duration _currentPos = Duration(); // 当前播放位置
  Duration _bufferPos = Duration(); // 缓冲位置
  bool _clearView = false; // 是否清屏
  bool _playing = false; // 是否正在播放
  bool _prepared = false; // 是否已准备好
  String? _exception; // 异常信息
  bool _showTimePanel = false;

  bool _buffering = false; // 是否正在缓冲
  bool _playChecked = false; // 是否已检查播放状态

  double _bufferPercent = 0.0; // 缓冲下载速度

  double _seekPos = -1.0; // 拖动进度条时的目标位置

  StreamSubscription? _currentPosSubs; // 当前播放位置订阅

  StreamSubscription? _bufferPosSubs; // 缓冲位置订阅

  StreamSubscription? _bufferingSubs; // 缓冲状态订阅

  StreamSubscription? _bufferPercentSubs; // 缓冲状态订阅

  @override
  void initState() {
    super.initState();
    _bindPlayer(widget.player);
  }

  @override
  void didUpdateWidget(covariant FijkTiktokPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player != widget.player) {
      _unbindPlayer(oldWidget.player);
      _bindPlayer(widget.player);
    }
  }

  void _playerValueChanged() {
    FijkValue value = player.value;
    if (value.duration != _duration) {
      setState(() => _duration = value.duration);
    }

    bool playing = (value.state == FijkState.started);
    bool prepared = value.prepared;
    String? exception = value.exception.message;
    if (playing != _playing ||
        prepared != _prepared ||
        exception != _exception) {
      setState(() {
        _playing = playing;
        _prepared = prepared;
        _exception = exception;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_attachedPlayer != null) {
      _unbindPlayer(_attachedPlayer!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      Container(
          color: Colors.transparent,
          width: screen.screenWidth,
          height: screen.screenHeight),
      _buildTiktokPlayerPause(),
      _buildTiktokVideoInfo(widget.mediaInfo, controller: widget.controller),
      _buildTiktokVideoUtils(mediaInfo: widget.mediaInfo, showHead: false),
    ]);
  }

  // 绑定到指定 player 的所有监听
  void _bindPlayer(FijkPlayer p) {
    _attachedPlayer = p;
    _duration = p.value.duration;
    _currentPos = p.currentPos;
    _bufferPos = p.bufferPos;
    _prepared = p.state.index >= FijkState.prepared.index;
    _playing = p.state == FijkState.started;
    _exception = p.value.exception.message;
    _buffering = p.isBuffering;

    p.addListener(_playerValueChanged);
    _bufferingSubs = p.onBufferStateUpdate.listen((isBuffering) {
      setState(() => _buffering = isBuffering);
    });
    _bufferPercentSubs = p.onBufferPercentUpdate.listen((percent) {
      setState(() => _bufferPercent = percent / 10.0);
    });
    _currentPosSubs = p.onCurrentPosUpdate.listen((v) async {
      if (!(widget.mediaInfo?.playable ?? false) &&
          v.inSeconds > 5 &&
          !_playChecked) {
        // 如果视频不可播放, 且当前播放时间超过5秒, 则暂停
        p.pause();
        M3u8CacheManager manager = M3u8CacheManager();
        manager.stop(widget.mediaInfo?.videoUrl ?? "");
        bool? canPlay =
            await playableDialog(player, mediaInfo: widget.mediaInfo);
        if (canPlay ?? false) {
          await player.start();
          manager.resume(widget.mediaInfo?.videoUrl ?? "");
          _playChecked = true; // 标记已检查播放状态
        }
      }
      setState(() => _currentPos = v);
    });
    _bufferPosSubs = p.onBufferPosUpdate.listen((v) {
      final diff = _duration.inMilliseconds - v.inMilliseconds;
      _bufferPos = v;
      if (diff.abs() < 500) _bufferPos = _duration;
      setState(() => {});
    });
  }

  // 解绑旧 player 的所有监听
  void _unbindPlayer(FijkPlayer p) {
    try {
      p.removeListener(_playerValueChanged);
    } catch (_) {}
    _currentPosSubs?.cancel();
    _bufferPosSubs?.cancel();
    _bufferingSubs?.cancel();
    _bufferPercentSubs?.cancel();
    _currentPosSubs = null;
    _bufferPosSubs = null;
    _bufferingSubs = null;
    _bufferPercentSubs = null;
  }

  Widget _buildTiktokPlayerPause() {
    return Positioned.fill(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _playing ? player.pause() : player.start();
            },
            child: Center(
                child: _buffering
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : _playing && player.value.prepared
                        ? const SizedBox()
                        : Image.asset(R.assetsImgIconPlayerPause,
                            width: Dimens.pt100, height: Dimens.pt100))));
  }

  Widget _buildTiktokVideoUtils({bool showHead = false, MediaInfo? mediaInfo}) {
    return Positioned(
        right: Dimens.pt5,
        bottom: Dimens.pt165,
        child: SizedBox(
            width: Dimens.pt142,
            height: Dimens.pt600 + Dimens.pt120,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              showHead ? const HeadAnimateView() : const SizedBox(),
              SizedBox(height: Dimens.pt55),
              _buildMediaUtils(mediaInfo),
            ])));
  }

  Widget _buildTiktokVideoInfo(MediaInfo? mediaInfo,
      {FijkTiktokFeedController? controller}) {
    double duration = _duration.inSeconds.toDouble();
    double currentValue = _currentPos.inSeconds.toDouble();
    currentValue = min(currentValue, duration);
    currentValue = max(currentValue, 0);
    return Positioned(
        bottom: 0,
        child: Container(
          width: screen.screenWidth,
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!_clearView)
              _buildVideoTitle(mediaInfo, controller: controller),
            _buildTiktokPlayerSlider(currentValue, duration)
          ]),
        ));
  }

  Widget _buildTiktokPlayerSlider(double currentValue, double duration) {
    // print(
    //     "_bufferPos.inMilliseconds.toDouble()${_bufferPos.inMilliseconds.toDouble()}"
    //         "===duration${duration}");
    double currentSeekValue = _seekPos > 0 ? _seekPos : currentValue;
    return SizedBox(
        width: screen.screenWidth,
        height: Dimens.pt40,
        child: Row(children: [
          Text(
              _duration2String(
                  Duration(milliseconds: currentSeekValue.toInt() * 1000)),
              style: TextStyle(fontSize: 14.0, color: Colors.white)),
          SizedBox(width: Dimens.pt15),
          _duration.inMilliseconds == 0
              ? Expanded(child: Center())
              : Expanded(
                  child: FIJKSlider(
                      value: currentSeekValue,
                      cacheValue: 0,
                      min: 0.0,
                      max: duration,
                      onChanged: (v) => setState(() => _seekPos = v),
                      onChangeEnd: (v) {
                        setState(() {
                          player.seekTo((v * 1000).toInt());
                          _currentPos =
                              Duration(milliseconds: (_seekPos * 1000).toInt());
                          _seekPos = -1;
                        });
                      })),
          SizedBox(width: Dimens.pt15),
          Text(_duration2String(_duration),
              style: TextStyle(
                  fontSize: 14.0, color: Colors.white.withOpacity(.6)))
        ]));
  }

  Widget _buildMediaUtils(MediaInfo? mediaInfo) {
    bool isCollect = mediaInfo?.isCollect ?? false;
    int collects = (mediaInfo?.collects ?? 0);
    return SizedBox(
        height: Dimens.pt450,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatefulBuilder(builder: (context, setState) {
                return AnimatedOpacity(
                  opacity: _clearView ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: _buildVideoNumber(
                      icon: isCollect
                          ? R.assetsImgIconVideoCollected
                          : R.assetsImgIconVideoCollect,
                      onTap: () async {
                        isCollect = !isCollect;
                        int objectId = mediaInfo?.id ?? 0;
                        MediaType collectType = MediaType.videoShort;

                        collects = isCollect ? collects + 1 : collects - 1;

                        mediaInfo?.isCollect = isCollect;
                        mediaInfo?.collects = collects;
                        setState(() => {});
                        await ApiRes.addCollect(
                            collectType: collectType,
                            objectId: objectId,
                            flag: isCollect);
                      },
                      text: getShowWatchNumberStr(collects)),
                );
              }),
              // _buildVideoNumber(
              //     icon: R.assetsImgIconVideoCommentShort,
              //     onTap: () {
              //       showCommentsDialog(Get.context!, mediaInfo?.id ?? 0,
              //           mediaInfo: mediaInfo,
              //           comments: mediaInfo?.comments ?? 0);
              //     },
              //     text: "${mediaInfo?.comments ?? 0}"),
              AnimatedOpacity(
                  opacity: _clearView ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: _buildVideoNumber(
                      icon: R.assetsImgIconVideoShareShort,
                      onTap: () async {
                        await player.pause();
                        showShareAccountDialog();
                      },
                      text: "分享")),
              _buildVideoNumber(
                  onTap: () => setState(() => _clearView = !_clearView),
                  icon: _clearView
                      ? R.assetsImgIconShortShow
                      : R.assetsImgIconShortClear,
                  text: _clearView ? "显示" : "清屏")
            ]));
  }
}

Widget _buildVideoTitle(MediaInfo? mediaInfo,
    {FijkTiktokFeedController? controller}) {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  PaymentType payType = mediaInfo?.payType ?? PaymentType.freePaymentType;

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      // buildPayTypeWidget(payType,
      //     price: mediaInfo?.price ?? 0,
      //     width: Dimens.pt73,
      //     height: Dimens.pt35),
      if (payType != PaymentType.freePaymentType && !shareKeys.isVip())
        GestureDetector(
            onTap: () => Get.toNamed(Routes.VIP_CENTER_PAGE),
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Dimens.pt15, vertical: Dimens.pt6),
                decoration: BoxDecoration(
                    color: AppColors.mainRed,
                    borderRadius: BorderRadius.circular(Dimens.pt8)),
                child: Text("玩游戏 领会员 全站视频免费看",
                    style: TextStyle(
                        color: Colors.white, fontSize: Dimens.pt24)))),

      // if (!(mediaInfo?.playable ?? false)) ...[
      //   SizedBox(width: Dimens.pt20),
      //   if (payType == PaymentType.vipPaymentType ||
      //       payType == PaymentType.coinPaymentType)
      //     Container(
      //         height: Dimens.pt35,
      //         alignment: Alignment.center,
      //         padding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
      //         color: theme.getColor(payType == PaymentType.vipPaymentType
      //             ? ThemeColor.textYellow
      //             : ThemeColor.red),
      //         child: Text(payType == PaymentType.vipPaymentType
      //             ? "开通会员,观看完整版"
      //             : "支付${(mediaInfo?.price ?? 0) / 100}金币,观看完整版"))
      // ]
    ]),
    SizedBox(height: Dimens.pt20),
    SizedBox(
        width: Dimens.pt570,
        height: Dimens.pt44,
        child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () async {
                    controller?.togglePause(true);
                    dynamic result =
                        await Get.toNamed(Routes.TAG_DETAIL_PAGE, arguments: {
                      "id": "${mediaInfo?.tagList?[index].id}",
                      "title": mediaInfo?.tagList?[index].name ?? "",
                      "mediaType": MediaType.videoShort.index,
                      "backResultMark": true
                    });
                    if (result == null) return;

                    controller?.resetMedias(result["mediaList"] ?? [],
                        initIndex: result["index"] ?? 0);
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: Dimens.pt12),
                      height: Dimens.pt34,
                      alignment: Alignment.center,
                      color: Color(0xFF352C2B).withOpacity(.6),
                      child: Text("# ${mediaInfo?.tagList?[index].name ?? " "}",
                          style: TextStyle(
                              color: Color(0xFFF5835B),
                              fontSize: Dimens.pt22))),
                ),
            separatorBuilder: (context, index) => SizedBox(width: Dimens.pt25),
            itemCount: mediaInfo?.tagList?.length ?? 0)),
    SizedBox(height: Dimens.pt16),
    SizedBox(
        width: Dimens.pt570,
        child: Text(mediaInfo?.title ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: Dimens.pt28))),
    SizedBox(height: Dimens.pt20),
  ]);
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

Widget _buildVideoNumber({String? icon, String? text, VoidCallback? onTap}) {
  return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Column(children: [
        Image.asset(icon ?? R.assetsImgIconVideoCollect, width: Dimens.pt65),
        SizedBox(height: Dimens.pt10),
        Text(text ?? "",
            style: TextStyle(fontSize: Dimens.pt24, color: Colors.white))
      ]));
}
