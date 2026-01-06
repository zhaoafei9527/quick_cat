// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/utils/array_util.dart';
import '../../../../data/ads_type.dart';
import '../../../../model/home/config_model_model.dart';
import '../../../../model/post_list_model.dart';
import '../../../../views/pull_refresh_view.dart';

class PostRecommendController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final int id;

  PostRecommendController(this.id);

  final count = 0.obs;
  var pageNum = 1.obs;
  RxBool initOk = false.obs;
  RxInt actionIndex = 0.obs;
  int sort = 0;
  TabController? tabController;
  List<String> tabList = ["最新更新", "最多评论", "最多收藏"];
  RxList<PostBrief> postList = <PostBrief>[].obs;
  RxList<PostTopicInfo> topicList = <PostTopicInfo>[].obs;
  PullRefreshController pullRefreshController = PullRefreshController();
  Advertise? gameAds = Advertise();

  @override
  void onInit() async {
    super.onInit();
    tabController = TabController(length: tabList.length, vsync: this);
    await loadData();
  }

  loadData() async {
    postList.value = [];
    PostBriefResp? model = await _getNetData(pageNum: 1);
    if ((model?.list ?? []).isNotEmpty) {
      postList.assignAll(model?.list ?? []);
    } else {
      pageNum.value = 1;
    }
    postList.refresh();
    pullRefreshController.requestSuccess(
        isFirstPage: true, isEmpty: (model?.list ?? []).isEmpty);
    initOk.value = true;
  }

  void loadMoreData() async {
    var page = pageNum.value += 1;
    PostBriefResp? model = await _getNetData(pageNum: page);
    if (model != null) {
      pageNum.value = page;
      postList.addAll((model.list ?? []));
      pullRefreshController.requestSuccess(
          isFirstPage: false, hasMore: (model.list ?? []).length >= 10);
    } else {
      pullRefreshController.requestFail(isFirstPage: false);
    }
    // postList.refresh();
  }

  Future<PostBriefResp?> _getNetData({int? pageNum}) async {
    PostBriefResp? model;
    if (id > 0) {
      model = await ApiRes.getPostList(
          data: {"id": id, "pageNum": pageNum, "sort": sort});
      topicList.value = model?.topicList ?? [];
      gameAds =
          await LocalAdsStore().randomWhere(AdsType.communityPopularTopicsAds);

      if (gameAds != null) {
        PostTopicInfo adData = PostTopicInfo(
          adsId: gameAds?.id ?? '',
          adsPath: gameAds?.href ?? '',
          name: gameAds?.title ?? '',
          cover: gameAds?.cover ?? '',
          count: 0,
        );
        if (ArrayUtil.indexExists(topicList, 2)) {
          topicList.insert(2, adData);
        }
      }
    }
    return model;
  }

  void increment() => count.value++;
}
