// 🐦 Flutter imports:
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/app/views/pull_refresh_view.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/time_util.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/screen.dart';
import '../../../model/home/services_model.dart';
import '../controllers/message_center_page_controller.dart';

class MessageCenterPageView extends GetView<MessageCenterPageController> {
  const MessageCenterPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    ThemeManager theme = Get.find<ThemeManager>();
    MessageCenterPageController logic = Get.find<MessageCenterPageController>();
    return Stack(children: [
      Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("消息中心"),
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: Obx(() {
                return Column(children: [
                  Obx(
                    () => _buildMessageItem(
                        title: "系统消息",
                        icon: R.assetsImgIconMessageSystem,
                        onTap: () {
                          shareKeys.systemRead.value = true;
                          Get.toNamed(Routes.SYSTEM_MESSAGE_PAGE);
                        },
                        desc: logic.messageList.isNotEmpty
                            ? logic.messageList[0].title
                            : "暂无新消息",
                        read: shareKeys.systemRead.value),
                  ),
                  SizedBox(height: Dimens.pt25),
                  getHengLine(
                      h: Dimens.pt2, color: Colors.white.withOpacity(.1)),
                  SizedBox(height: Dimens.pt25),
                  _buildMessageItem(
                      title: "在线客服",
                      onTap: () async {
                        logic.enterLoading.value = true;
                        ServicesModel? model = await ApiRes.getCustomServers();
                        String? queryString =
                            (model?.sign!.split('?').length)! > 1
                                ? model?.sign?.split('?')[1]
                                : '';
                        logic.enterLoading.value = false;

                        ShareKeys shareKeys = Get.find<ShareKeys>();
                        Get.toNamed(Routes.ACTIVITY_WEB_PAGE, arguments: {
                          "title": "在线客服",
                          "uri":
                              "${shareKeys.baseUrl}/zoudoboh-h5service/?theme=theme1&$queryString"
                        });
                      },
                      icon: R.assetsImgIconMessageCustom,
                      desc: "问题咨询及反馈",
                      read: shareKeys.customRead.value),
                  SizedBox(height: Dimens.pt25),
                  getHengLine(
                      h: Dimens.pt2, color: Colors.white.withOpacity(.1))
                ]);
              }))),
      Obx(() => logic.enterLoading.value
          ? Container(
              width: screen.screenWidth,
              height: screen.screenHeight,
              color: Colors.black.withOpacity(.5),
              child: getLoadingWidget())
          : const SizedBox())
    ]);
  }

  Widget _buildMessageItem(
      {String? title,
      String? icon,
      String? desc,
      bool? read,
      VoidCallback? onTap}) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            width: Dimens.pt78,
            height: Dimens.pt78,
            alignment: Alignment.center,
            color: theme.getColor(ThemeColor.bgGrey),
            child: Image.asset(icon ?? "",
                width: Dimens.pt50, height: Dimens.pt50)),
        SizedBox(width: Dimens.pt20),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title ?? "",
              style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
          Text(desc ?? "",
              style: TextStyle(
                  fontSize: Dimens.pt24,
                  color: theme.getColor(ThemeColor.textGrey)))
        ])),
        !(read ?? false)
            ? Container(
                width: Dimens.pt18,
                height: Dimens.pt18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(Dimens.pt20)))
            : const SizedBox()
      ]),
    );
  }
}

Widget buildTemp() {
  MessageCenterPageController logic = Get.find();
  return Center(
      child: PullRefreshView(
    controller: logic.refreshController,
    onRefresh: () => logic.onRefresh(),
    onLoading: () => logic.onLoadMore(),
    child: ListView.separated(
        itemBuilder: (c, index) {
          return Container(
              width: screen.screenWidth,
              margin: EdgeInsets.symmetric(horizontal: Dimens.pt15),
              padding: EdgeInsets.symmetric(
                  horizontal: Dimens.pt12, vertical: Dimens.pt10),
              decoration: BoxDecoration(
                  color: AppColors.primaryRaised,
                  borderRadius: BorderRadius.circular(Dimens.pt8)),
              child: Column(children: [
                Row(children: [
                  // Image.asset(R.assetsImgIconMessage,
                  //     width: Dimens.pt40),
                  SizedBox(width: Dimens.pt10),
                  Text(logic.messageList[index].title ?? "",
                      style: TextStyle(
                          fontSize: Dimens.pt14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor1B1B)),
                ]),
                SizedBox(height: Dimens.pt17),
                Text(logic.messageList[index].content ?? "",
                    style: TextStyle(
                        fontSize: Dimens.pt14, color: AppColors.textColore97)),
                SizedBox(height: Dimens.pt17),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(
                      TimeUtil.buildChineseYYMMDD(
                          logic.messageList[index].createdAt ?? ""),
                      style: TextStyle(
                          fontSize: Dimens.pt12,
                          color: AppColors.textColore97)),
                ])
              ]));
        },
        separatorBuilder: (c, index) => SizedBox(height: Dimens.pt16),
        itemCount: logic.messageList.length),
  ));
}
