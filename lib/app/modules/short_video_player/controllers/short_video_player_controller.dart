// 🐦 Flutter imports:
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/modules/home/home_recommend_page/controllers/home_recommend_page_controller.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import '../../../../plugins_utils/VideoPlayer/fjik_tiktok_player.dart';
import '../../../../utils/toast_util.dart';
import '../../../data/enum.dart';
import '../../../model/home/video_play_model.dart';

class ShortVideoPlayerController extends GetxController
    with GetTickerProviderStateMixin {
  RxList<MediaInfo> mediaList = <MediaInfo>[].obs;
  int initIndex = 0;
  final count = 0.obs;
  MediaInfo? playMedia;
  Function(int pageNum)? dataGetter;
  RxBool initOk = false.obs; // 是否初始化完成
  bool playable = true; // 默认会员可以直接播放
  bool useTicketed = false; // 是否使用了观影券
  String? getVideoPath;
  TabController? tabController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  FijkTiktokFeedController tiktokPlayer = FijkTiktokFeedController();

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    tabController = TabController(
        length: shareKeys.mediaTagType.length, vsync: this, initialIndex: 0);
    tabController?.addListener(() async {});
    tiktokPlayer.setCurrentLooping(true);
    initIndex = TextUtil.getIntArgument("initIndex");
    if (Get.arguments?['dataGetter'] != null) {
      dataGetter = Get.arguments?['dataGetter'];
    }
    List<MediaInfo> list = [];
    if (Get.arguments?['mediaList'] != null) {
      list = Get.arguments['mediaList'] ?? [];
    }
    if (list.isEmpty) {
      list = await getMediasNetData(pageNum: 1);
    }
    mediaList.value = list;
    initOk.value = true;
  }

  /// 根据 mediaId 请求获取 MediaModel
  Future<MediaPlayModel?> playVideoOfId(int mediaId) async {
    try {
      final mediaPlayModel = await ApiRes.playVideo(
        data: {"id": mediaId},
        onError: (error) {
          showToast(msg: "请求影片信息失败 id:$mediaId,message:$error");
        },
      );
      if (mediaPlayModel == null) return null;
      return mediaPlayModel;
    } catch (e) {
      showTypeToast(msg: "播放器故障，请联系客服,$e");
      return null;
    }
  }

  Future<void> toTagPage(int id, {String? name}) async {
    if (tabController == null) return;
    tiktokPlayer.togglePause(true);
    var result = await Get.toNamed(Routes.TAG_DETAIL_PAGE, arguments: {
      "id": id,
      "title": name ?? "",
      "mediaType": MediaType.videoShort.index,
      "coverType": CoverType.coverVertical.index,
      "backResultMark": true,
    });
    if (result == null) return;
    tiktokPlayer.resetMedias(result["mediaList"] ?? [],
        initIndex: result["index"] ?? 0);
  }

  Future<List<MediaInfo>> getMediasNetData({pageNum}) async {
    List<MediaInfo> list = [];
    if (getVideoPath != null) {
      MediaInfo info = MediaInfo();
      info.videoUrl = getVideoPath;
      list.add(info);
      return list;
    }
    MediaList? model =
        await ApiRes.getHomeShortMedia(data: {"pageNum": pageNum});
    if (model != null && (model.mediaList ?? []).isNotEmpty) {
      list = model.mediaList ?? [];
    }
    return list;
  }

  HomeRecommendPageController homeShort =
      Get.find<HomeRecommendPageController>();

  void increment() => count.value++;
}
