// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/app/widget/common_widget.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/utils/screen.dart';
import 'package:acgn_client/utils/toast_util.dart';
import '../../../../utils/dimens.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_colors.dart';
import '../controllers/welfare_task_controller.dart';

class WelfareTaskPageView extends GetView<WelfareTaskController> {
  const WelfareTaskPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: getCommonAppBar("福利中心"),
      body: GetBuilder<WelfareTaskController>(builder: (logic) {
        return logic.initOk.value
            ? SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Dimens.pt25),
                          // _buildLabelText("新手任务"),
                          // ..._buildTaskInfoList(taskType: 1),
                          // SizedBox(height: Dimens.pt30),
                          // _buildLabelText("每周任务"),
                          // ..._buildTaskInfoList(taskType: 2),
                          // _buildActivityRewards(),
                          // SizedBox(height: screen.bottomNavBarH)
                        ])))
            : getLoadingWidget();
      }),
    );
  }

  // List<Widget> _buildTaskInfoList({int taskType = 1}) {
  //   WelfareTaskController logic = Get.find<WelfareTaskController>();
  //   return logic.taskInfoList
  //       .asMap()
  //       .entries
  //       .where((entry) {
  //         return logic.taskInfoList[entry.key].taskType == taskType;
  //       })
  //       .map((entry) => _buildTaskItemView(
  //           title: entry.value.title,
  //           onTap: () {
  //             entry.value.status != 1 &&
  //                 AppPages.jumpRouter(path: entry.value.goTo);
  //             // AppPages.jumpRouter( path: 'insert://vip_center_page');
  //           },
  //           currParam: entry.value.currParam,
  //           param: entry.value.param,
  //           desc: entry.value.desc,
  //           isDone: entry.value.status == 1))
  //       .toList();
  // }
  //
  // Widget _buildActivityRewards() {
  //   WelfareTaskController logic = Get.find<WelfareTaskController>();
  //   return Container(
  //       width: screen.screenWidth,
  //       height: Dimens.pt520,
  //       margin: EdgeInsets.only(top: Dimens.pt25),
  //       padding: EdgeInsets.symmetric(
  //           horizontal: Dimens.pt25, vertical: Dimens.pt30),
  //       decoration: BoxDecoration(
  //           color: const Color(0xFF1D1A19),
  //           borderRadius: BorderRadius.circular(Dimens.pt12)),
  //       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //           Text("本周的活跃值：",
  //               style: TextStyle(fontSize: Dimens.pt28, color: Colors.white)),
  //           Text("${logic.activityValue.value}",
  //               style: TextStyle(
  //                   fontSize: Dimens.pt40, color: AppColors.primaryColor))
  //         ]),
  //         SizedBox(height: Dimens.pt25),
  //         Padding(
  //           padding: EdgeInsets.symmetric(horizontal: Dimens.pt1),
  //           child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 ...List.generate(
  //                     8,
  //                     (index) => Text("$index",
  //                         style: TextStyle(
  //                             fontSize: Dimens.pt18,
  //                             color: const Color(0xFF8A8785))))
  //               ]),
  //         ),
  //         Stack(children: [
  //           Container(
  //               width: screen.screenWidth,
  //               height: Dimens.pt10,
  //               decoration: BoxDecoration(
  //                   color: const Color(0xFF8A8785),
  //                   borderRadius: BorderRadius.circular(Dimens.pt25))),
  //           FractionallySizedBox(
  //             widthFactor: logic.activityValue.value / logic.totalValue.value,
  //             child: Container(
  //                 height: Dimens.pt10,
  //                 decoration: BoxDecoration(
  //                     gradient: AppColors.saveButtonBgGradient,
  //                     borderRadius: BorderRadius.circular(Dimens.pt10))),
  //           ),
  //           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //             ...List.generate(
  //                 8,
  //                 (index) => index == 0 || index == 7
  //                     ? SizedBox(width: Dimens.pt2)
  //                     : Container(
  //                         height: Dimens.pt10,
  //                         width: Dimens.pt1,
  //                         color: Colors.black))
  //           ])
  //         ]),
  //         SizedBox(height: Dimens.pt10),
  //         Text("活跃值数据每周一00:00:00更新",
  //             style: TextStyle(
  //                 fontSize: Dimens.pt24, color: const Color(0xFF8A8785))),
  //         SizedBox(height: Dimens.pt30),
  //         Expanded(
  //           child: ListView.separated(
  //               scrollDirection: Axis.horizontal,
  //               itemBuilder: (c, index) => GestureDetector(
  //                   onTap: () {
  //                     int nowValue =
  //                         logic.prizeInfoList[index].activityValue ?? 0;
  //                     if (logic.activityValue >= nowValue) {
  //                       logic.clickClaimRewards(index: index);
  //                     } else {
  //                       showToast(msg: "请完成任务后领取");
  //                     }
  //                   },
  //                   child: Column(children: [
  //                     // Text(logic.prizeInfoList[index].title ?? "",
  //                     //     style: TextStyle(
  //                     //         fontSize: Dimens.pt22,
  //                     //         fontWeight: FontWeight.w600,
  //                     //         color: Colors.white)),
  //                     SizedBox(height: Dimens.pt10),
  //                     Container(
  //                         width: Dimens.pt147,
  //                         height: Dimens.pt147,
  //                         alignment: Alignment.center,
  //                         decoration: BoxDecoration(
  //                             color: const Color(0xFF2C2A29),
  //                             borderRadius: BorderRadius.circular(Dimens.pt12)),
  //                         child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
  //                             children: [
  //                               SizedBox(height: Dimens.pt18),
  //                               Obx(() {
  //                                 int? status = logic.prizeInfoList[index].status;
  //                                 String image =
  //                                     logic.prizeInfoList[index].image ?? "";
  //                                 String openImage =
  //                                     logic.prizeInfoList[index].openImage ?? "";
  //                                 return ImageLoader.withP(
  //                                         status == TaskStatus.statusFinish.index
  //                                             ? openImage
  //                                             : image,
  //                                         width: Dimens.pt88,
  //                                         height: Dimens.pt88)
  //                                     .load();
  //                               }),
  //                               SizedBox(height: Dimens.pt2),
  //                               Text(index==(logic.prizeInfoList.length-1)?"  最高999元（可提现）":"",
  //                                   style: TextStyle(
  //                                       fontSize: Dimens.pt14,
  //                                       color: const Color(0xFFFF6213))),
  //                             ]
  //                         )),
  //                     SizedBox(height: Dimens.pt15),
  //                     Obx(() {
  //                       int? status = logic.prizeInfoList[index].status;
  //                       bool isDone = status == TaskStatus.statusDone.index;
  //                       bool isFinish = status == TaskStatus.statusFinish.index;
  //                       return Container(
  //                           padding: EdgeInsets.symmetric(
  //                               horizontal: Dimens.pt20, vertical: Dimens.pt8),
  //                           decoration: BoxDecoration(
  //                               color: isDone
  //                                   ? AppColors.primaryColor
  //                                   : const Color(0xFF2C2A29),
  //                               borderRadius:
  //                                   BorderRadius.circular(Dimens.pt45),
  //                               border: isFinish
  //                                   ? Border.all(color: const Color(0xFF2C2A29))
  //                                   : isDone
  //                                       ? null
  //                                       : Border.all(
  //                                           color: AppColors.primaryColor)),
  //                           child: Text(
  //                               isFinish
  //                                   ? "已领取"
  //                                   : isDone
  //                                       ? "领取"
  //                                       : "${logic.prizeInfoList[index].activityValue}点",
  //                               style: TextStyle(
  //                                   fontSize: Dimens.pt24,
  //                                   color: isFinish
  //                                       ? AppColors.textGrey
  //                                       : isDone
  //                                           ? Colors.white
  //                                           : AppColors.primaryColor)));
  //                     })
  //                   ])),
  //               separatorBuilder: (c, index) => SizedBox(width: Dimens.pt20),
  //               itemCount: logic.prizeInfoList.length),
  //         )
  //       ]));
  // }
  //
  // static buildNodePoint() {
  //   return [
  //     const Spacer(),
  //     Container(height: Dimens.pt10, width: Dimens.pt2, color: Colors.black)
  //   ];
  // }
  //
  // Widget _buildLabelText(String text) {
  //   return Text(text,
  //       style: TextStyle(
  //           fontSize: Dimens.pt32,
  //           fontWeight: FontWeight.w600,
  //           color: Colors.white));
  // }
  //
  // Widget _buildTaskItemView(
  //     {String? title,
  //     String? desc,
  //     int? currParam,
  //     int? param,
  //     VoidCallback? onTap,
  //     bool isDone = false}) {
  //   return GestureDetector(
  //     onTap: () => onTap?.call(),
  //     child: Container(
  //         width: screen.screenWidth,
  //         height: Dimens.pt133,
  //         margin: EdgeInsets.only(top: Dimens.pt25),
  //         padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
  //         decoration: BoxDecoration(
  //             color: const Color(0xFF1D1A19),
  //             borderRadius: BorderRadius.circular(Dimens.pt12)),
  //         child: Row(children: [
  //           Expanded(
  //               child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                 Text(title ?? "",
  //                     style: TextStyle(
  //                         fontSize: Dimens.pt28, color: Colors.white)),
  //                 Text(desc ?? "",
  //                     style: TextStyle(
  //                         fontSize: Dimens.pt24,
  //                         color: AppColors.primaryColor)),
  //               ])),
  //           SizedBox(width: Dimens.pt25),
  //           Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               if ((param ?? 0) > 1) ...[
  //                 Text.rich(
  //                     TextSpan(
  //                         text: "$currParam",
  //                         children: [TextSpan(text: "/$param")],
  //                         style:
  //                             const TextStyle(color: AppColors.primaryColor)),
  //                     style: TextStyle(
  //                         fontSize: Dimens.pt24,
  //                         color: const Color(0xFF8A8785))),
  //                 SizedBox(height: Dimens.pt5)
  //               ],
  //               Container(
  //                   width: Dimens.pt88,
  //                   height: Dimens.pt45,
  //                   alignment: Alignment.center,
  //                   decoration: BoxDecoration(
  //                       color: const Color(0xFF2C2A29),
  //                       borderRadius: BorderRadius.circular(Dimens.pt45),
  //                       border: isDone
  //                           ? null
  //                           : Border.all(color: AppColors.primaryColor)),
  //                   child: Text(isDone ? "完成" : "前往",
  //                       style: TextStyle(
  //                           fontSize: Dimens.pt24,
  //                           color: isDone
  //                               ? const Color(0xFFADB5BD)
  //                               : AppColors.primaryColor))),
  //             ],
  //           )
  //         ])),
  //   );
  // }
}
