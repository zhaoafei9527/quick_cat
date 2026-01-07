// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../r.dart';
import '../../../../utils/dimens.dart';
import '../../../routes/app_pages.dart';
import '../../../themes/app_colors.dart';
import '../controllers/activity_center_controller.dart';

class ActivityCenterPageView extends GetView<ActivityCenterController> {
  const ActivityCenterPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: getCommonAppBar("福利活动", actions: [
          GestureDetector(
              onTap: () => Get.toNamed(Routes.MESSAGE_CENTER_PAGE),
              child:
                  Image.asset(R.assetsImgIconMineMessage, width: Dimens.pt35)),
          SizedBox(width: Dimens.pt25)
        ]),
        body: GetBuilder<ActivityCenterController>(builder: (logic) {
          return Column(children: [
            Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                    itemBuilder: (c, index) => GestureDetector(
                          onTap: () => AppPages.jumpRouter(
                              path: logic.activityList[index].jumpUrl),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ImageLoader.withP(
                                        logic.activityList[index].cover ?? "",
                                        height: Dimens.pt300,
                                        radius: Dimens.pt12,
                                        width: screen.screenWidth)
                                    .load(),
                                SizedBox(height: Dimens.pt10),
                                Row(
                                  children: [
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Dimens.pt10,
                                            vertical: Dimens.pt5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Dimens.pt6),
                                            border: Border.all(
                                                color: Color(0xFFFFCD82),
                                                width: Dimens.pt1)),
                                        child: Text("活动简介",
                                            style: TextStyle(
                                                fontSize: Dimens.pt20,
                                                color: Color(0xFFFFCD82)))),
                                    SizedBox(width: Dimens.pt10),
                                    Text(logic.activityList[index].title ?? "",
                                        style: TextStyle(
                                            fontSize: Dimens.pt24,
                                            color: Colors.white))
                                  ],
                                )
                              ]),
                        ),
                    separatorBuilder: (c, index) =>
                        SizedBox(height: Dimens.pt25),
                    itemCount: logic.activityList.length)),
            SizedBox(height: screen.bottomNavBarH)
          ]);
        }));
  }
}
