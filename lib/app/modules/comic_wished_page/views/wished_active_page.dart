import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:acgn_client/utils/time_util.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/comic_wished_page_controller.dart';

class WishedActivePage extends GetView<ComicWishedPageController> {
  const WishedActivePage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<ComicWishedPageController>(builder: (logic) {
      return Scaffold(
          appBar: getCommonAppBar("当前榜单"),
          backgroundColor: theme.getColor(ThemeColor.bg),
          body: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildTopInfoView(logic)),
            SliverList(
                delegate: SliverChildBuilderDelegate((c, index) {
              WishedActiveMember member = logic.activeMemberList[index];
              bool wished = member.isCollet ?? false;
              return Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  child: Container(
                      width: screen.screenWidth,
                      height: Dimens.pt80,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: theme.getColor(ThemeColor.bgGrey),
                                  width: Dimens.pt1))),
                      child: Row(children: [
                        Container(
                            width: Dimens.pt76,
                            height: Dimens.pt48,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: theme.getColor(ThemeColor.primary))),
                            child: Center(
                                child: Text("${index + 1}",
                                    style: TextStyle(
                                        fontSize: Dimens.pt30,
                                        fontWeight: FontWeight.w900,
                                        color: theme
                                            .getColor(ThemeColor.primary))))),
                        SizedBox(width: Dimens.pt20),
                        Expanded(
                            child: Text(member.name ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: Dimens.pt30,
                                    color:
                                        theme.getColor(ThemeColor.primary)))),
                        SizedBox(width: Dimens.pt55),
                        Text("助力人数：${member.hopeNum ?? 0}",
                            style: TextStyle(
                                fontSize: Dimens.pt18,
                                color: theme.getColor(ThemeColor.textGrey))),
                        SizedBox(width: Dimens.pt95),
                        GestureDetector(
                            onTap: () =>
                                logic.clickWishSponsor(member.id ?? 0, index),
                            child: Obx(() => Container(
                                width: Dimens.pt96,
                                height: Dimens.pt48,
                                color: theme.getColor(ThemeColor.primary),
                                child: Center(
                                    child: Text(wished ? "已助力" : "助力",
                                        style: TextStyle(
                                            fontSize: Dimens.pt22,
                                            color: theme.getColor(wished
                                                ? ThemeColor.textGrey
                                                : ThemeColor.textYellow)))))))
                      ])));
            },
                    childCount: logic.activeMemberList.length,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false))
          ]));
    });
  }

  Widget _buildTopInfoView(ComicWishedPageController logic) {
    ThemeManager theme = Get.find<ThemeManager>();
    WishedInfoModel? active = logic.wishedList.value.activity;
    return Column(children: [
      Image.asset(R.assetsImgBgWishedPage,
          width: screen.screenWidth, height: Dimens.pt330),
      SizedBox(height: Dimens.pt30),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          onTap: () => Get.toNamed(Routes.WISHING_PAGE),
          child: Container(
              width: Dimens.pt185,
              height: Dimens.pt66,
              color: theme.getColor(ThemeColor.primary),
              alignment: Alignment.center,
              child: Text("立即许愿",
                  style: TextStyle(
                      fontSize: Dimens.pt26,
                      fontWeight: FontWeight.w600,
                      color: theme.getColor(ThemeColor.bg)))),
        )
      ]),
      SizedBox(height: Dimens.pt40),
      Text(active?.name ?? "",
          style: TextStyle(
              fontSize: Dimens.pt38,
              color: theme.getColor(ThemeColor.primary))),
      SizedBox(height: Dimens.pt5),
      Text("火热进行中！我们会选择“期待榜”前20名更新！",
          style: TextStyle(
              fontSize: Dimens.pt22,
              color: theme.getColor(ThemeColor.textYellow))),
      Text("截止时间: ${TimeUtil.buildYYMMDDPunctuate(active?.end ?? "", sp: "-")}",
          style: TextStyle(
              fontSize: Dimens.pt22,
              color: theme.getColor(ThemeColor.primary))),
      SizedBox(height: Dimens.pt40)
    ]);
  }
}
