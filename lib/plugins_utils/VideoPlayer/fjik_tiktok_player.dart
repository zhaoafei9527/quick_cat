import 'dart:async';

import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/dialog/comment_dialog.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/video_play_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/fijk_tiktok_panel.dart';
import 'package:quick_cat_client/plugins_utils/video_player_core/video_player_core.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/ads_type.dart';
import '../../app/model/home/topic_list_model.dart';
import '../../app/routes/app_pages.dart';
import '../../utils/common_util.dart';
import '../../utils/dimens.dart';
import '../../utils/screen.dart';
import '../ImageLoader/ImageLoader.dart';

/// 抖音风格的短视频播放页面，支持上下滑动切换。
///
/// 内部基于 [CoreFijkTiktokFeedPage] 实现，所有的播放器池化、预加载、缓存、生命周期
/// 管理都委托给 video_player_core。本文件只负责把 [MediaInfo] 列表映射成 core 的
/// [CoreVideoItem]，并提供广告插入、收藏分享等业务功能。
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
  int pageNum = 1; // 当前页码
  bool initOk = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pageNum = widget.medias.length ~/ 10;
    _initMediaList();
  }

  Future<void> _initMediaList() async {
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _coreController.togglePause(true);
    }
  }

  Future<void> _onCoreVideoPlay(CoreVideoItem item, int index) async {
    final media = item.extra is MediaInfo ? item.extra as MediaInfo : null;
    if (media == null || (media.isAds ?? false)) return;
    unawaited(WatchRecord.addWatchRecord(media, MediaType.videoShort));

    final MediaPlayModel? playModel =
        await widget.onVideoPlay?.call(media.id ?? 0);
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
          child: const Center(
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
            const CircularProgressIndicator(
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
          final size = MediaQuery.of(context).size;
          return FijkTiktokPanel(
            player,
            viewSize: size,
            mediaInfo: media,
            buildContext: context,
            controller: widget.controller,
            texturePos: Rect.fromLTWH(0, 0, size.width, size.height),
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

  void _appendMedias(List<MediaInfo> newMedias) {
    setState(() => _medias.addAll(newMedias));
    _coreController.append(newMedias.map(_toCoreVideoItem).toList());
  }

  void _resetMedias(List<MediaInfo> newMedias,
      {int initIndex = 0, bool autoPlay = false}) {
    setState(() {
      _medias = List.of(newMedias);
      pageNum = newMedias.length ~/ 10;
    });
    _coreController.resetItems(
      _medias.map(_toCoreVideoItem).toList(),
      initIndex: initIndex.clamp(0, newMedias.length - 1),
      autoPlay: autoPlay,
    );
  }
}

/// 对外控制器：暴露给业务层进行追加、重置、暂停等操作。
class FijkTiktokFeedController extends ChangeNotifier {
  _FijkTiktokFeedPageState? _state;

  bool get attached => _state != null;

  void _attach(_FijkTiktokFeedPageState s) {
    _state = s;
  }

  /// 获取当前播放列表（只读）
  List<MediaInfo> get medias => List.unmodifiable(_state?._medias ?? const []);

  void togglePause(bool pause) {
    _state?._coreController.togglePause(pause);
  }

  void resetMedias(List<MediaInfo> newMedias,
      {int initIndex = 0, bool autoPlay = false}) {
    final s = _state;
    if (s == null || newMedias.isEmpty) return;
    s._resetMedias(newMedias, initIndex: initIndex, autoPlay: autoPlay);
    notifyListeners();
  }

  /// 追加一批视频到播放列表尾部。
  void append(List<MediaInfo> newMedias) {
    final s = _state;
    if (s == null || newMedias.isEmpty) return;
    s._appendMedias(newMedias);
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
    return _state?._coreController.getCurrentLooping() ?? true;
  }
}

/// 每隔 5 条媒体插入一次广告条目。
Future<List<MediaInfo>> getAdsMediaList(List<MediaInfo> medias) async {
  final List<MediaInfo> result = [];
  final Advertise? ads = await getCommentAds(type: AdsType.shortVideoPlayAds);
  for (int i = 0; i < medias.length; i++) {
    result.add(medias[i]);
    if (((i + 1) % 5 == 0) && ads != null) {
      result.add(MediaInfo(
        isAds: true,
        coverImg: ads.cover,
        title: ads.title,
        adsId: ads.id,
        adsPath: ads.href,
        playable: false,
      ));
    }
  }
  return result;
}
