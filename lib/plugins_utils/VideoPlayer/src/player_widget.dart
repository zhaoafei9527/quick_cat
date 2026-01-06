// 🐦 Flutter imports:
import 'package:quick_cat_client/app/model/home/video_play_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/dialog/common_dialog.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/conf/config.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/light_model.dart';
import '../../../app/data/enum.dart';
import '../../../app/model/home/topic_list_model.dart';
import '../../../utils/toast_util.dart';
import '../fijk_player.dart';

// 添加浮动播放器
void addFloatingPlayer(BuildContext context) {
  OverlayState overlayState = Overlay.of(context);
  FIJKPlayerManager manager = FIJKPlayerManager();
  manager.overlayEntry = OverlayEntry(builder: (context) {
    return StatefulBuilder(builder: (context, setState) {
      return Positioned(
          left: manager.floatingPosition.dx,
          top: manager.floatingPosition.dy,
          child: Draggable(
              feedback: _buildFloatingPlayer(),
              onDragEnd: (details) {
                setState(() => manager.floatingPosition = details.offset);
              },
              childWhenDragging: Container(),
              child: _buildFloatingPlayer()));
    });
  });
  manager.isShrinkModel = true;
  overlayState.insert(manager.overlayEntry!);
}

// 构建浮动播放器
Widget _buildFloatingPlayer() {
  ThemeManager theme = Get.find();
  FIJKPlayerManager manager = FIJKPlayerManager();
  FijkPlayer? player = manager.player;
  manager.playingController.add(player?.state == FijkState.started);
  return FijkView(
      player: manager.player!,
      color: theme.getColor(ThemeColor.bg),
      panelBuilder: (player, data, context, size, rect) =>
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(
                  padding: EdgeInsets.only(left: 5, top: 5),
                  child: GestureDetector(
                      onTap: () => manager.disposePlayer(),
                      child: Icon(Icons.close_rounded,
                          size: 25, color: Colors.white))),
              Padding(
                  padding: const EdgeInsets.only(right: 5, top: 5),
                  child: GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.VIDEO_PLAYER_PAGE, arguments: {
                          "id": "${manager.mediaPlayModel?.mediaInfo?.id}"
                        });
                      },
                      child:
                          Image.asset(R.assetsImgIconPlayerPipIn, width: 20)))
            ]),
            Expanded(
                child: StreamBuilder(
                    stream: manager.isPlaying,
                    builder: (context, snapshot) {
                      return GestureDetector(
                          onTap: () => manager.togglePlay(),
                          child: Center(
                              child: Image.asset(
                                  !(snapshot.data ?? false)
                                      ? R.assetsImgIconPlayerPause
                                      : R.assetsImgIconPlayerPlay,
                                  width: 25)));
                    }))
          ]),
      width: 240,
      height: 240 / 16 * 9);
}

Future<bool> openBoomDialog() async {
  FIJKPlayerManager manager = FIJKPlayerManager();
  manager.player?.pause();
  bool canOpen = false;
  ShareKeys shareKeys = Get.find<ShareKeys>();
  ThemeManager theme = Get.find<ThemeManager>();
  if ((shareKeys.userInfo.vipType ?? 0) > 0) {
    canOpen = await showPlayerCommonDialog(Get.context!,
        title: "友情提示",
        content: "全新互动功能——“震动模式”,是否开启？",
        btnList: ["否", "是"],
        btnCall: [
          () => Get.back(result: false),
          () {
            manager.setPlayerBoom(false);
            Get.back(result: true);
          }
        ],
        btnActionIndex: 1);
  } else {
    bool? experienced = await lightKV.getBool(AppConfig.KEY_EXPERIENCE_BOOM);
    List<String> btnList = ["获得会员"];
    List<Function> btnCall = [
      () async {
        await Get.toNamed(Routes.VIP_CENTER_PAGE);
        // 返回成功后判断是否VIP用户
        bool res = (shareKeys.userInfo.vipType ?? 0) > 0;
        canOpen = res;
        manager.setPlayerBoom(res);
      }
    ];
    TextSpan text = TextSpan(
        text: "非会员用户免费体验一次,会员用户终身享受！",
        style: TextStyle(color: theme.getColor(ThemeColor.textYellow)));
    if (!(experienced ?? false)) {
      btnList.insert(0, "体验一次");
      btnCall.insert(0, () {
        Get.back(result: true);
        showTypeToast(msg: "体验成功", toastType: ToastType.SUCCESS);
      });
    }
    canOpen = await showPlayerCommonDialog(Get.context!,
        title: "友情提示",
        content: "全新互动功能——“震动模式”,在您高潮时会为您带来震动感,为您的观影体验增加带入感,",
        attachedText: [text],
        btnList: btnList,
        btnCall: btnCall,
        btnActionIndex: (experienced ?? false) ? 0 : 1);
  }

  return canOpen;
}

// 不能观看弹出 弹窗
Future<bool?> playableDialog(FijkPlayer? player, {MediaInfo? mediaInfo}) async {
  ShareKeys shareKeys = Get.find<ShareKeys>();
  // 不能播放 只分为金币和会员视频
  bool isCoinVideo = (mediaInfo?.payType == PaymentType.coinPaymentType);

  bool haveFree = shareKeys.userInfo.haveFreeTickets ?? false;
  bool? continuePlay = false;
  String content =
      isCoinVideo ? "该影片需金币解锁后可观看,请解锁后观看！" : "对不起，您当前还不是会员开通会员才能继续观看影片";
  continuePlay = await showPlayerCommonDialog(Get.context!,
      title: "友情提示",
      content: content,
      btnList: [isCoinVideo ? "金币解锁" : "获得会员", haveFree ? "使用观影券" : "获得观影券"],
      btnCall: [
        () async => await coinPayVideo(player,
            isCoinVideo: isCoinVideo, mediaInfo: mediaInfo),
        () async => await useFreeTickets(player, haveFree, mediaInfo: mediaInfo)
      ],
      btnActionIndex: 0);
  return continuePlay;
}

Future<void> coinPayVideo(FijkPlayer? player,
    {bool? isCoinVideo, MediaInfo? mediaInfo}) async {
  ShareKeys shareKeys = Get.find<ShareKeys>();

  double price = (mediaInfo?.price ?? 0) / 100;
  double balance = double.tryParse(shareKeys.userBalance.value) ?? .0;

  if (isCoinVideo ?? false) {
    if (balance >= price) {
      await ApiRes.mediaPayAndPlay(
          id: mediaInfo?.id,
          payType: 1,
          onSuccess: () {
            Get.back(result: true);
            showTypeToast(msg: "金币支付成功", toastType: ToastType.SUCCESS);
          });
      await ApiRes.getUpdateUserInfo();
    } else {
      Get.back(result: false);
      showTypeToast(msg: "余额不足，请充值后尝试");
    }
  } else {
    if (player?.value.fullScreen ?? false) player?.exitFullScreen();
    await Get.toNamed(Routes.VIP_CENTER_PAGE);
    // 返回成功后判断是否VIP用户
    Get.back(result: (shareKeys.userInfo.vipType ?? 0) > 0);
  }
}

// 使用免费观影券观看
Future<void> useFreeTickets(FijkPlayer? player, haveFree,
    {MediaInfo? mediaInfo}) async {
  if (haveFree) {
    await ApiRes.mediaPayAndPlay(
        id: mediaInfo?.id,
        payType: 2,
        onSuccess: () {
          Get.back(result: true);
          showTypeToast(msg: "使用观影券成功", toastType: ToastType.SUCCESS);
        });
    await ApiRes.getUpdateUserInfo();
  } else {
    if (player?.value.fullScreen ?? false) player?.exitFullScreen();
    await Get.toNamed(Routes.WEEKLY_CHECK_TASK_PAGE);
    Get.back(result: false);
  }
}

bool _useOneExperienced() {
  lightKV.setBool(AppConfig.KEY_EXPERIENCE_BOOM, true);
  return true;
}
