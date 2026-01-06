// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/model/home/video_play_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/fjik_tiktok_player.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:quick_cat_client/utils/toast_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../../data/share_key.dart';
import '../../../../model/home/config_model_model.dart';
import '../../../../views/pull_refresh_view.dart';

class HomePostPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var count = 0.obs;
  RxBool openCommentPanel = false.obs; //  是否但开了评论 缩放视频
  RxList<MediaInfo> mediaList = <MediaInfo>[].obs;
  int initIndex = 0;
  RxBool initOk = false.obs; // 是否初始化完成
  MediaInfo? playMedia;
  String? getVideoPath;
  Function(int pageNum)? dataGetter;
  TabController? tabController;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  FijkTiktokFeedController tiktokPlayer = FijkTiktokFeedController();

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    tiktokPlayer.setCurrentLooping(true);
    tabController = TabController(
        length: shareKeys.mediaTagType.length, vsync: this, initialIndex: 0);
    tabController?.addListener(() async {});
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
    tiktokPlayer.togglePause(true);
    var result = await Get.toNamed(Routes.TAG_DETAIL_PAGE, arguments: {
      "id": id,
      "title": name ?? "",
      "mediaType": MediaType.videoShort.index,
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


  void increment() => count.value++;
}
