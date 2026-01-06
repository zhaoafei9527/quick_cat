// 🐦 Flutter imports:
import 'package:quick_cat_client/app/model/check_in_model.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/app/views/page_pull_view.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/time_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../../../r.dart';
import '../../../../utils/dimens.dart';
import '../controllers/weekly_check_in_controller.dart';

class RewardHistoryPage extends GetView<WeeklyCheckInController> {
  const RewardHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Scaffold(
        backgroundColor: theme.getColor(ThemeColor.bg),
        appBar: getCommonAppBar("兑换记录"),
        body: GetBuilder<WeeklyCheckInController>(builder: (logic) {
          return Container();
        }));
  }
}
