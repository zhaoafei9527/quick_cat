// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/app/dialog/game_notify_dialog.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import '../../../../conf/api_res.dart';
import '../../../../plugins_utils/VideoPlayer/fijk_player.dart';
import '../../../../plugins_utils/VideoPlayer/src/barrage_builder.dart';
import '../../../../utils/toast_util.dart';
import '../../../data/share_key.dart';
import '../../../model/home/video_play_model.dart';

class VideoPlayerPageController extends GetxController
    with GetTickerProviderStateMixin {
  RxBool initOk = false.obs;
  int videoId = 0;
  MediaType mediaType = MediaType.videoLong; // 视频类型
  RxString title = "".obs;
  RxBool vidInitOk = false.obs; // 视频初始化成功
  RxString videoUrl = "".obs; // 视频地址
  RxBool showBarrage = true.obs; // 是否展示弹幕

  List<String> tabList = ["详情", "评论"];
  RxList<MediaInfo> relatedMediaList = <MediaInfo>[].obs; // 相关视频系列列表
  RxList<MediaInfo> relatedComicList = <MediaInfo>[].obs; // 相关漫画列表
  Rx<MediaInfo> collectMedia = MediaInfo().obs; // 合集属性

  ShareKeys? shareKeys;
  bool pipEnter = false;
  RxBool showLinePanel = false.obs;
  RxInt lineIndex = 0.obs;
  RxString lineText = "切换线路".obs;
  MediaPlayModel? mediaPlayModel;
  RxInt collects = 0.obs;
  RxBool isCollect = false.obs;
  RxInt comments = 0.obs;
  late String coverImg = "";
  RxBool changing = false.obs;
  RxString barrageText = ''.obs;
  Rx<int> paymentType = 0.obs;
  TextEditingController barrageField = TextEditingController();
  RxInt tabIndex = 0.obs;
  late TabController tabController;
  TabController? typeTabController;
  List<String> typeTabList = ["动漫推荐", "视频推荐", "漫画推荐", "小说推荐"];
  List<MediaType> typeSort = [
    MediaType.cartoon,
    MediaType.videoLong,
    MediaType.comic,
    MediaType.novel
  ];

  @override
  void onInit() async {
    super.onInit();
    int id = TextUtil.getIntArgument("id");
    mediaType = MediaType.values[TextUtil.getIntArgument("mediaType")];
    if (id > 0) {
      videoId = id;
      shareKeys = Get.find<ShareKeys>();
      typeTabController =
          TabController(length: typeTabList.length, vsync: this);
      tabController =
          TabController(length: tabList.length, vsync: this, initialIndex: 0);
      tabController.addListener(() {
        tabIndex.value = tabController.index;
      });
      await startInitPlayVideo(videoId);
      if (shareKeys?.gameNotify.value == false) {
        showGameNotifyDialog(Get.context!);
      }
      barrageField.addListener(barrageFieldListener);
    }
  }

  Future<void> startInitPlayVideo(videoId) async {
    // GlobalPlayerController player = GlobalPlayerController();
    // int? tempVid = player.videoId;
    // 画中画模式关闭画中画
    // if (player.isPiPModel) player.overlayEntry?.remove();
    // 画中画模式获取本地数据
    // pipEnter = player.isPiPModel && videoId == tempVid;
    FIJKPlayerManager playerManager = FIJKPlayerManager();

    mediaPlayModel = playerManager.isShrinkModel
        ? playerManager.mediaPlayModel
        : await _getNetData(videoId: videoId);
    if (mediaPlayModel == null) {
      showToast(msg: "获取视频信息失败，请稍后再试");
      return;
    }
    paymentType.value = mediaPlayModel?.mediaInfo?.payType?.index ?? 0;
    relatedMediaList.value = mediaPlayModel?.mediaList ?? [];
    relatedComicList.value = mediaPlayModel?.comicsList ?? [];
    collectMedia.value = mediaPlayModel?.collect ?? MediaInfo();

    playerManager.mediaPlayModel = mediaPlayModel;
    playerManager.canContinuePlay = mediaPlayModel?.playable ?? false;
    videoUrl.value = mediaPlayModel?.mediaInfo?.videoUrl ?? "";

    MediaInfo? mediaInfo = mediaPlayModel?.mediaInfo;
    title.value = mediaInfo?.title ?? "";
    isCollect.value = mediaInfo?.isCollect ?? false;
    comments.value = mediaInfo?.comments ?? 0;
    collects.value = (mediaInfo?.collects ?? 0) + (mediaInfo?.likes ?? 0);

    // /// firebase 播放上报
    // await FirebaseUtils.firebaseLogEvent(
    //     eventName: "longVideoPlay",
    //     routePath: Routes.VIDEO_PLAYER_PAGE,
    //     eventArgs: {"vid": "${mediaInfo?.id}"});
    initOk.value = true;
    // if (player.isPiPModel) {
    //   vidInitOk.value = player.isPiPModel;
    //   player.setPipModel(false);
    //   if (videoId != tempVid) startPlayVideo(mediaPlayModel?.mediaInfo);
    // } else {
    //   startPlayVideo(mediaPlayModel?.mediaInfo);
    // }
  }

  Future<void> switchVideoInPage(int id) async {
    FIJKPlayerManager playerManager = FIJKPlayerManager();
    playerManager.player?.pause();
    changing.value = true;
    await startInitPlayVideo(id);
    playerManager.switchVideo(videoUrl.value, autoPlay: true);
    playerManager.player?.start();
    changing.value = false;
  }

  collectVideo() async {
    bool flag = !isCollect.value;
    isCollect.value = flag;
    collects.value = flag ? collects.value + 1 : collects.value - 1;
    await ApiRes.addCollect(
        type: ActionType.Collect,
        collectType: mediaType,
        objectId: videoId,
        flag: flag);
  }

  Future<MediaPlayModel?> _getNetData({videoId}) async {
    MediaPlayModel? mediaPlayModel = await ApiRes.playVideo(
        data: {"id": videoId},
        onError: (error) {
          showToast(msg: "请求影片信息失败 id:$videoId,message:$error");
        });

    return mediaPlayModel;
  }

  sendBarrage() async {
    if (await canNotSendBarrageDialog(text: "弹幕功能仅会员用户可发送,请先获得会员！")) {
      FocusScope.of(Get.context!).unfocus();
      if ((barrageField.text).isEmpty) {
        showTypeToast(msg: "请输入弹幕内容后在发送!");
        return;
      }
      FIJKPlayerManager manager = FIJKPlayerManager();
      await ApiRes.sendBarrageToVideo(
          mediaId: videoId,
          content: barrageField.text,
          publishAt: manager.player?.currentPos.inSeconds ?? 0,
          onSuccess: () {
            manager.barrageController?.addBarrage(Barrage(
                content: barrageField.text,
                currentTime: manager.player?.currentPos.inSeconds ?? 0,
                isLocalSend: true));
            showTypeToast(msg: "弹幕发送完成", toastType: ToastType.SUCCESS);
          });
    }
    barrageField.text = '';
  }

  /// 切换播放器线路
  changeVideoLine(index, text) async {
    if (index != shareKeys!.lineIndex) {
      showLinePanel.value = false;
      if (await canNotSendBarrageDialog(text: "该线路仅会员用户可使用,请先获得会员！")) {
        // lineIndex.value = index;
        shareKeys!.lineIndex = index;
        changing.value = true;
        lineText.value = text;
        Future.delayed(Durations.extralong2, () {
          FIJKPlayerManager manager = FIJKPlayerManager();
          changing.value = false;
          manager.player?.seekTo(0);
          manager.player?.start();
          showTypeToast(msg: "线路已切换", toastType: ToastType.SUCCESS);
        });
      }
    }
  }

  // 不能观看弹出 弹窗
  Future<bool> canNotSendBarrageDialog({String? text}) async {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    if ((shareKeys.userInfo.vipType ?? 0) >= 0) return true;
    var result = await showPlayerCommonDialog(Get.context!,
        title: "友情提示",
        content: text ?? "弹幕功能仅会员用户可发送,请先获得会员！",
        btnCall: [() => _goVipRecharge()],
        btnActionIndex: 0);
    return result ?? false;
  }

  Future<bool> _goVipRecharge() async {
    bool isVip = false;
    ShareKeys shareKeys = Get.find<ShareKeys>();
    await Get.toNamed(Routes.VIP_CENTER_PAGE);
    if (shareKeys.userInfo.isActiveMember ?? false) {
      isVip = true;
    }
    return isVip;
  }

  barrageFieldListener() {
    barrageText.value = barrageField.text;
  }

  Future<MediaList?> getRecommendMediaData(
      {pageNum, required MediaType type}) async {
    MediaList? model = await ApiRes.getPlayerRecommendVideo(
        id: videoId, pageNum: pageNum, contentType: type);

    return model;
  }

  @override
  void onClose() {
    super.onClose();
    barrageField.removeListener(barrageFieldListener);
    if (mediaPlayModel != null && mediaPlayModel!.mediaInfo != null) {
      WatchRecord.addWatchRecord(mediaPlayModel!.mediaInfo!, mediaType);
    }
    Get.delete<VideoPlayerPageController>();
  }
}
