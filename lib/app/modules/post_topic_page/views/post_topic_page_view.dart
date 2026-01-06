// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import '../../../../utils/dimens.dart';
import '../../../themes/app_colors.dart';
import '../../../widget/common_app_bar.dart';
import '../../../widget/post_item.dart';
import '../controllers/post_topic_page_controller.dart';

class PostTopicPageView extends GetView<PostTopicPageController> {
  const PostTopicPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<PostTopicPageController>(
        builder: (PostTopicPageController logic) {
      return Scaffold(
          backgroundColor: AppColors.bgColor,
          appBar: getCommonAppBar(logic.title.isNotEmpty ? logic.title : "专题详情",
              bgColor: AppColors.appBarColor),
          body: PullRefreshView(
              controller: logic.pullRefreshController,
              onRefresh: () => logic.loadData(),
              onLoading: () => logic.loadMoreData(),
              child: CustomScrollView(slivers: [
                SliverList(
                    delegate: SliverChildBuilderDelegate((c, index) {
                  return Column(children: [
                    PostItem(postBrief: logic.postList[index]),
                    Container(
                        height: Dimens.pt30,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent))),
                  ]);
                }, childCount: logic.postList.length))
              ])));
    });
  }
}
