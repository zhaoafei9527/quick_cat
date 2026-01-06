// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:acgn_client/app/model/barrages_model.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/logger_utils.dart';
import '../../../utils/screen.dart';

/// 对外控制器：支持在运行时向播放列表追加视频
class BarrageController extends ChangeNotifier {
  _BarrageBuilderState? _state;

  bool get attached => _state != null;

  void _attach(_BarrageBuilderState s) {
    _state = s;
  }

  void _detach(_BarrageBuilderState s) {
    if (_state == s) _state = null;
  }

  /// 获取当前播放列表（只读）
  List<Barrage> get barrages =>
      List.unmodifiable(_state?._barrageList ?? const []);

  void setShowBarrage(bool show) {
    if (_state == null) return;
    _state!._showBarrage = show;
    _state!.setState(() {});
  }

  /// 添加弹幕到当前播放列表
  void addBarrage(Barrage barrage) {
    if (_state == null) return;
    _state!._barrageList.add(barrage);
    // 解决添加弹幕之后所有的弹幕会重新出现
    _state!.setState(() {});
  }
}

/// BarrageBuilder is used to display barrage comments in a video player.
/// It listens to the video position and displays barrage comments
/// that are relevant to the current time in the video.
class BarrageBuilder extends StatefulWidget {
  final FijkPlayer player;
  final int? mediaId;
  final BarrageController? controller;

  const BarrageBuilder(this.player, {super.key, this.mediaId, this.controller});

  @override
  State<BarrageBuilder> createState() => _BarrageBuilderState();
}

class _BarrageBuilderState extends State<BarrageBuilder> {
  FijkPlayer get player => widget.player;

  int? get mediaId => widget.mediaId;

  int get seconds => player.currentPos.inSeconds; // 当前视频播放时间（秒）
  StreamSubscription? _currentPosSubs; // 当前播放位置订阅
  bool _hasMoreBarrage =
      true; // Flag to indicate if there are more barrages to load
  final List<Barrage> _barrageList = <Barrage>[];
  bool? _loading = false;
  bool _showBarrage = true; // 是否显示弹幕

  Future<List<Barrage>?> _getNetBarrage({int? second}) async {
    List<Barrage> list = [];
    List<DanmuMsgsBySecond>? model = await ApiRes.getBarrageList(
        mediaId: mediaId, startAt: second ?? 1, size: 30);
    for (DanmuMsgsBySecond item in model ?? []) {
      for (DanmuMsg key in item.barrages ?? []) {
        list.add(Barrage(
            currentTime: item.publishAt,
            content: key.content,
            level: key.vipType));
      }
    }
    return list;
  }

  Future<void> _getBarrageOfVideoTime({int? second}) async {
    if (mediaId == null) return;
    if (_barrageList.isNotEmpty && _barrageList.last.currentTime! >= second!) {
      return; // No need to fetch if the last barrage is already at or beyond the current time
    }
    if (_barrageList.isNotEmpty) {
      second = _barrageList.last.currentTime! + 1;
    } else {
      second ??= 1; // Default to 1 if no barrages are present
    }
    log.i("_barrage_request", "开始请求弹幕数据, 当前时间: $second");
    List<Barrage>? list = await _getNetBarrage(second: second);
    log.i("_barrage_request",
        "弹幕数据请求完成, 当前时间: $second, 获取到 ${list?.length} 条弹幕, 最后一条弹幕的时间: ${list?.last.currentTime}");
    if (list != null && list.isNotEmpty) {
      _barrageList.addAll(list);
      _barrageList.sort((a, b) => a.currentTime!.compareTo(b.currentTime!));
      setState(() {});
    } else {
      _hasMoreBarrage = false; // No more barrages to load
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) async {
      if (v.inSeconds > 2) {
        if (_hasMoreBarrage && !_loading! && _showBarrage) {
          _loading = true;
          await _getBarrageOfVideoTime(second: v.inSeconds);
          _loading = false;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?._detach(this);
    _currentPosSubs?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: true,
        child: Stack(children: [
          const Align(alignment: Alignment.center),
          ...List.generate(_barrageList.length, (index) {
            int bt = _barrageList[index].currentTime ?? 0;
            if (bt >= seconds) return const SizedBox();
            if (!_showBarrage) return const SizedBox(); // 如果不显示弹幕，直接返回空容器
            return BarragePlayItem(
                player: player, barrage: _barrageList[index], index: index);
          })
        ]));
  }
}

class BarragePlayItem extends StatefulWidget {
  final Barrage? barrage;
  final int? index;
  final FijkPlayer player;

  const BarragePlayItem(
      {super.key, required this.player, this.barrage, this.index});

  @override
  State<BarragePlayItem> createState() => _BarragePlayItemState();
}

class _BarragePlayItemState extends State<BarragePlayItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int get currentTime => widget.barrage?.currentTime ?? 0;

  String get text => widget.barrage?.content ?? "";

  int get level => widget.barrage?.level ?? 0;

  bool get isLocalSend => widget.barrage?.isLocalSend ?? false;

  int get index => widget.index ?? 0;

  double? top = Random().nextDouble() * (screen.screenWidth * (7.5 / 25));

  int get seconds => widget.player.currentPos.inSeconds; // 当前视频播放时间（秒）

  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    int duration = Random().nextInt(6) + 3;
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: duration));
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => isCompleted = true);
        // player.barrageList?[index].already = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int vipType = level - 1;
    vipType = vipType < 2 ? 1 : vipType;
    List<Color> textColors = AppColors.vipTextColor;
    return !isCompleted
        ? AnimatedBuilder(
            animation: _controller,
            child: AnimatedOpacity(
                opacity: currentTime > (seconds - 10) ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: Dimens.pt10, horizontal: Dimens.pt15),
                    decoration: isLocalSend
                        ? BoxDecoration(
                            border: Border.all(color: AppColors.primaryColor))
                        : null,
                    child: Text(text,
                        style: TextStyle(
                            fontSize: Dimens.pt28,
                            color: isLocalSend
                                ? AppColors.primaryColor
                                : textColors[vipType])))),
            builder: (context, _) {
              var a = Tween(begin: screen.screenWidth, end: -screen.screenWidth)
                  .evaluate(_controller);
              return Positioned(left: a, top: top, child: _ ?? Container());
            })
        : const SizedBox();
  }
}

class Barrage {
  final String? content;
  final int? currentTime;
  final bool? isLocalSend;
  final int? level; // 发送时用户等级
  bool? already;

  Barrage(
      {this.content,
        this.currentTime,
        this.level,
        this.isLocalSend,
        this.already = false});
}
