// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import '../../../../utils/dimens.dart';
import '../controllers/message_center_page_controller.dart';

class SystemMessagePageView extends GetView<MessageCenterPageController> {
  const SystemMessagePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<MessageCenterPageController>(
        builder: (MessageCenterPageController logic) {
      logic.count.value;
      ThemeManager theme = Get.find<ThemeManager>();
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("系统消息"),
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              child: _buildSystemMessage()));
    });
  }

  Widget _buildSystemMessage() {
    ThemeManager theme = Get.find<ThemeManager>();
    MessageCenterPageController logic = Get.find<MessageCenterPageController>();

    return Center(
        child: PullRefreshView(
      controller: logic.refreshController,
      onRefresh: () => logic.onRefresh(),
      onLoading: () => logic.onLoadMore(),
      child: ListView.separated(
          itemBuilder: (c, index) {
            String textFromBackend =
                logic.messageList[index].content ?? ""; // 假设后端返回的是这种形式
            String formattedText = textFromBackend.replaceAll('\\n', '\n');
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(logic.messageList[index].title ?? "",
                      style: TextStyle(
                          fontSize: Dimens.pt32,
                          color:  theme.getColor(ThemeColor.primary),
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: Dimens.pt25),
                  Container(
                      padding: EdgeInsets.all(Dimens.pt25),
                      color:  theme.getColor(ThemeColor.bgGrey),
                      child: Text(formattedText,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: Dimens.pt24,
                              color: const Color(0xFF8A8785))))
                ]);
          },
          separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
          itemCount: logic.messageList.length),
    ));
  }
}
