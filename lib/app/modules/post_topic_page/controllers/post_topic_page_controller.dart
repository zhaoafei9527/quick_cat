// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/conf/api_res.dart';
import '../../../model/post_list_model.dart';
import '../../../views/pull_refresh_view.dart';

class PostTopicPageController extends GetxController {
  String title = "";
  final pageNum = 0.obs;

  int topicId = 0;
  RxBool initOk = false.obs;
  RxList<PostBrief> postList = <PostBrief>[].obs;
  PullRefreshController pullRefreshController = PullRefreshController();

  @override
  void onInit() {
    super.onInit();
    if ((Get.arguments?['topicId'] ?? 0) > 0) {
      topicId = Get.arguments?['topicId'];
      title = Get.arguments?['title'] ?? "";
    }
    loadData();
  }

  loadData() async {
    List<PostBrief>? model = await _getNetData(pageNum: 1);
    if ((model ?? []).isNotEmpty) {
      postList.value = model ?? [];
    } else {
      pageNum.value = 1;
    }
    pullRefreshController.requestSuccess(
        isFirstPage: true, isEmpty: (model ?? []).isEmpty);
    initOk.value = true;
  }

  void loadMoreData() async {
    var page = pageNum.value += 1;
    List<PostBrief>? model = await _getNetData(pageNum: page);
    if (model != null) {
      pageNum.value = page;
      postList.addAll(model);
      pullRefreshController.requestSuccess(
          isFirstPage: false, hasMore: model.length >= 10);
    } else {
      pageNum.value = 1;
      pullRefreshController.requestFail(isFirstPage: false);
    }
  }

  Future<List<PostBrief>?> _getNetData({int? pageNum}) async {
    List<PostBrief>? posts;

    PostBriefResp? model = await ApiRes.getPostListOfTopic(
        topicId: topicId, pageNum: pageNum ?? 1);
    posts = model?.list ?? [];
    return posts;
  }


}
