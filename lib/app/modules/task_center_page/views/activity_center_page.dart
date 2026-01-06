// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/utils/screen.dart';
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
        appBar: getCommonAppBar("活动中心", actions: [
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
                          onTap: () => AppPages.jumpRouter( path: logic.activityList[index].jumpUrl),
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
                                Text(logic.activityList[index].title ?? "",
                                    style: TextStyle(
                                        fontSize: Dimens.pt28,
                                        color: Colors.white))
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
