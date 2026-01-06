// 🐦 Flutter imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/comic_chapter.dart';
import 'package:acgn_client/app/model/task_center_model.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/full_bg.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/utils/screen.dart';
import '../../../../r.dart';
import '../../../../utils/dimens.dart';
import '../../../../utils/toast_util.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_colors.dart';
import '../controllers/weekly_check_in_controller.dart';

class WeeklyCheckInPageView extends GetView<WeeklyCheckInController> {
  const WeeklyCheckInPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<WeeklyCheckInController>(
        builder: (WeeklyCheckInController logic) {
      logic.todayChecked.value;
      return Scaffold(
        backgroundColor: Color(0xFFFFF6F5),
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(alignment: Alignment.topCenter, children: [
            ImageLoader.withP(
                    "aes/image/ae/61/9fa/31/dd5aee9a289277f9fa1961461fee31cf.png",
                    width: screen.screenWidth)
                .load(),
            transparentAppbar("签到", titleColor: Colors.black)
          ]),
          SizedBox(height: Dimens.pt30),
          // Text("活动内容",
          //     style: TextStyle(
          //         fontSize: Dimens.pt32,
          //         fontWeight: FontWeight.w600,
          //         color: Colors.white)),
          // SizedBox(height: Dimens.pt25),
          // Text(
          //     "现金红包大派送！即日平台所有用户，每天首次登陆都可以获赠一份随机额度的彩金红包！快邀请您的好友一起来领取吧！",
          //     style: TextStyle(
          //         fontSize: Dimens.pt26,
          //         color: const Color(0xFF8A8785))),
          // SizedBox(height: Dimens.pt50),
          _buildDaySingInView(),
          SizedBox(height: Dimens.pt50),
          _buildSingInContainer(),
          SizedBox(height: Dimens.pt50),
          // _buildEnvelopeTable(),
          // SizedBox(height: Dimens.pt50),
          // _buildEnvelopeReceive(),
          // SizedBox(height: Dimens.pt50),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt30),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Text("签到规则说明",
                    style: TextStyle(
                        fontSize: Dimens.pt32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF663500))),
                SizedBox(height: Dimens.pt25),
                Text(
                    "1.领取的随机红包1倍流水,即可出款！\n2.每个会员、每个IP仅限参与一次,如出现同IP多账号现象,则视为同一个人,不可再次参与！\n3.为避免文字差异,我司保留本活动的解释权！",
                    style: TextStyle(
                        fontSize: Dimens.pt24, color: const Color(0xFF663500)))
              ])),

          SizedBox(height: screen.bottomNavBarH)
        ])),
      );
    });
  }

  Widget _buildEnvelopeReceive() {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.VIP_CENTER_PAGE),
      child: Container(
        width: screen.screenWidth,
        height: Dimens.pt84,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: const Color(0xFFFF6213),
            borderRadius: BorderRadius.circular(Dimens.pt45)),
        child: Text("开通会员",
            style: TextStyle(
                fontSize: Dimens.pt32,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildEnvelopeTable() {
    WeeklyCheckInController logic = Get.find();

    Widget buildTableHeader(String text) {
      return Container(
        height: Dimens.pt68,
        color: AppColors.primaryColor,
        child: Center(
            child: Text(text,
                style: TextStyle(fontSize: Dimens.pt24, color: Colors.white))),
      );
    }

    Widget buildTableOption(String text) {
      return Container();
    }

    return Center(
        child: Obx(
      () => Table(
          border: TableBorder.all(color: const Color(0xFF8A8785)),
          // 添加边框
          children: [
            TableRow(children: [
              buildTableHeader("等级"),
              buildTableHeader("红包"),
              buildTableHeader(""),
            ]),
            ...List.generate(logic.envList.length, (index) {
              return TableRow(children: [
                Container(
                    height: Dimens.pt70,
                    alignment: Alignment.center,
                    child: Text('vip${(logic.envList[index].vipType! - 1)}',
                        style: TextStyle(
                            fontSize: Dimens.pt22,
                            color: const Color(0xFF8A8785)))),
                Container(
                    height: Dimens.pt70,
                    alignment: Alignment.center,
                    child: Text("最高${(logic.envList[index].money ?? 0) / 100}元",
                        style: TextStyle(
                            fontSize: Dimens.pt22,
                            color: const Color(0xFF8A8785)))),
                Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        if (logic.todayVipType.value ==
                                (logic.envList[index].vipType! - 1) &&
                            !logic.todayReceive.value &&
                            (logic.userInfo.isActiveMember ?? false)) {
                          logic.clickGetEnv(index);
                        } else if (!(logic.userInfo.isActiveMember ?? false)) {
                          showTypeToast(msg: "您当前会员已过期");
                        }
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: Dimens.pt16),
                          padding: EdgeInsets.symmetric(
                              horizontal: Dimens.pt26, vertical: Dimens.pt4),
                          decoration: BoxDecoration(
                              color: logic.todayVipType.value ==
                                          (logic.envList[index].vipType! - 1) &&
                                      !logic.todayReceive.value &&
                                      (logic.userInfo.isActiveMember ?? false)
                                  ? AppColors.primaryColor
                                  : const Color(0xFF8A8785),
                              borderRadius: BorderRadius.circular(Dimens.pt45)),
                          child: Text(
                              logic.todayVipType.value ==
                                          (logic.envList[index].vipType! - 1) &&
                                      logic.todayReceive.value
                                  ? "已领取"
                                  : "领取",
                              style: TextStyle(
                                  fontSize: Dimens.pt22, color: Colors.white))),
                    ))
              ]);
            })
          ]),
    ));
  }

  Widget _buildSingInContainer() {
    WeeklyCheckInController logic = Get.find();
    return GestureDetector(
        onTap: () => logic.checkInAndReceive(),
        child: Obx(
          () => Container(
              width: screen.screenWidth,
              height: Dimens.pt84,
              margin: EdgeInsets.symmetric(horizontal: Dimens.pt30),
              decoration: BoxDecoration(
                  gradient: !logic.todayChecked.value
                      ? LinearGradient(
                          colors: [Color(0xFFFFA26E), Color(0xFFFF6E4E)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)
                      : null,
                  borderRadius: BorderRadius.circular(Dimens.pt45),
                  color: logic.todayChecked.value
                      ? const Color(0xFF8A8785)
                      : null),
              child: Center(
                  child: Text(logic.todayChecked.value ? "已签到" : "立即签到",
                      style: TextStyle(
                          fontSize: Dimens.pt34,
                          color: logic.todayChecked.value
                              ? Colors.grey
                              : Colors.white)))),
        ));
  }

  Widget _buildDaySingInView() {
    WeeklyCheckInController logic = Get.find<WeeklyCheckInController>();
    int mondayIndex = 0;
    // 获取从昨天开始的连续7天
    List<String> getDateList() {
      List<String> dates = [];
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      for (int i = -1; i < 6; i++) {
        DateTime date = today.add(Duration(days: i));
        String dateStr;
        if (i == -1) {
          dateStr = "昨天";
        } else if (i == 0) {
          dateStr = "今天";
        } else if (i == 1) {
          dateStr = "明天";
        } else {
          dateStr = "${date.day}号";
        }
        // 标注周一
        if (date.weekday == DateTime.monday) mondayIndex = i + 1;
        dates.add(dateStr);
      }
      return dates;
    }

    return Container(
        width: screen.screenWidth,
        height: Dimens.pt630,
        margin: EdgeInsets.symmetric(horizontal: Dimens.pt30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimens.pt25),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFDE9A87)..withOpacity(.4),
                blurRadius: Dimens.pt20,
                offset: Offset(0, Dimens.pt10),
              )
            ]),
        child: Column(children: [
          Stack(alignment: Alignment.center, children: [
            Image.asset(R.assetsImgBgCheckinBoard,
                width: Dimens.pt690, height: Dimens.pt80),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: "已连续签到",
                  style: TextStyle(
                      fontSize: Dimens.pt28, color: const Color(0xFFC58846))),
              TextSpan(
                  text: "${logic.continuouslyDays.value}",
                  style: TextStyle(
                      fontSize: Dimens.pt56,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainRed)),
              TextSpan(
                  text: "天",
                  style: TextStyle(
                      fontSize: Dimens.pt28, color: const Color(0xFFC58846)))
            ]))
          ]),
          SizedBox(height: Dimens.pt25),
          Expanded(
              child: Wrap(
                  spacing: Dimens.pt20,
                  runSpacing: Dimens.pt20,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: getDateList().map((item) {
                    return Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                              width: Dimens.pt138, // 设置每个子项的宽度
                              height: Dimens.pt232, // 设置每个子项的高度
                              child: Column(children: [
                                Container(
                                    width: Dimens.pt138,
                                    height: Dimens.pt154,
                                    alignment: Alignment.bottomCenter,
                                    padding: EdgeInsets.symmetric(
                                        vertical: Dimens.pt14),
                                    decoration: BoxDecoration(
                                        color: Color(0xFFFFEFDB),
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt8)),
                                    child: Text("现金红包",
                                        style: TextStyle(
                                            fontSize: Dimens.pt24,
                                            color: Color(0xFFDD621E)))),
                                SizedBox(height: Dimens.pt16),
                                Container(
                                    width: Dimens.pt102,
                                    height: Dimens.pt40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt40),
                                        color: (item == "今天" && logic.todayChecked.value) ||
                                                (item == "昨天" &&
                                                    logic
                                                        .yesterdayChecked.value)
                                            ? Color(0xFF7A7D8B)
                                            : Color(0xFFFEA68F),
                                        gradient: !((item == "今天" && logic.todayChecked.value) ||
                                                (item == "昨天" &&
                                                    logic.yesterdayChecked
                                                        .value))
                                            ? null
                                            : LinearGradient(
                                                colors: [
                                                    Color(0xFFFEA68F),
                                                    Color(0xFFF52C56)
                                                  ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter)),
                                    child: Text((item == "今天" && logic.todayChecked.value) || (item == "昨天" && logic.yesterdayChecked.value) ? "已签到" : "未签到",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: Dimens.pt22, color: Colors.white)))
                              ])),
                          Positioned(
                              top: -Dimens.pt25,
                              child: Image.asset(R.assetsImgIconCheckined,
                                  width: Dimens.pt100))
                        ]);
                  }).toList()))
        ]));

    // return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

    // Row(
    //   crossAxisAlignment: CrossAxisAlignment.end,
    //   children: [
    //     Text("每日签到",
    //         style: TextStyle(
    //             fontSize: Dimens.pt28,
    //             fontWeight: FontWeight.w600,
    //             color: const Color(0xFFFDF6F2))),
    //     SizedBox(width: Dimens.pt15),
    //     Text("周一签到可额外领取一天VIP会员",
    //         style: TextStyle(
    //             fontSize: Dimens.pt20, color: AppColors.primaryColor))
    //   ],
    // ),
    // SizedBox(height: Dimens.pt25),
    // SizedBox(
    //     height: Dimens.pt210,
    //     child: ListView.separated(
    //         scrollDirection: Axis.horizontal,
    //         itemBuilder: (c, index) {
    //           final dateList = getDateList();
    //           bool todayChecked = index == 1 && logic.todayChecked.value;
    //           bool yesterdayChecked =
    //               index == 0 && logic.yesterdayChecked.value;
    //           bool isChecked = (todayChecked || yesterdayChecked);
    //           return Column(children: [
    //             Stack(
    //               alignment: Alignment.topRight,
    //               children: [
    //                 Container(
    //                     width: Dimens.pt92,
    //                     height: Dimens.pt160,
    //                     decoration: BoxDecoration(
    //                         color: isChecked
    //                             ? AppColors.primaryColor.withOpacity(.1)
    //                             : Color(0xFF2B2827),
    //                         border: isChecked
    //                             ? Border.all(color: AppColors.primaryColor)
    //                             : null,
    //                         borderRadius: BorderRadius.circular(Dimens.pt12)),
    //                     child: Column(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: [
    //                           Image.asset(
    //                               isChecked
    //                                   ? R.assetsImgIconChecked
    //                                   : R.assetsImgIconCheckin,
    //                               width: Dimens.pt67),
    //                           SizedBox(height: Dimens.pt12),
    //                           isChecked
    //                               ? Image.asset(R.assetsImgIconCheckined,
    //                                   width: Dimens.pt29)
    //                               : Text("现金红包",
    //                                   style: TextStyle(
    //                                       fontSize: Dimens.pt18,
    //                                       color: AppColors.textYellowColor)),
    //                           if (index == mondayIndex)
    //                             Text("+1天会员",
    //                                 style: TextStyle(
    //                                     fontSize: Dimens.pt18,
    //                                     color: AppColors.textYellowColor))
    //                         ])),
    //                 if (index == mondayIndex)
    //                   Image.asset(R.assetsImgTipCoverVip, width: Dimens.pt42)
    //               ],
    //             ),
    //             SizedBox(height: Dimens.pt12),
    //             Text(isChecked ? "已签到" : dateList[index],
    //                 style: TextStyle(
    //                     fontSize: Dimens.pt22, color: Color(0xFF8A8785)))
    //           ]);
    //         },
    //         separatorBuilder: (c, i) => SizedBox(width: Dimens.pt10),
    //         itemCount: getDateList().length))
    // ]);
  }
}
