// 🎯 Dart imports:

// 🐦 Flutter imports:

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../../../conf/api_res.dart';
import '../../../../utils/array_util.dart';
import '../../../model/msg_notify_list_model.dart';
import '../../../views/pull_refresh_view.dart';

class MessageCenterPageController extends GetxController {
  late PullRefreshController refreshController = PullRefreshController();
  late RxList<MsgNotifyModel> messageList = <MsgNotifyModel>[].obs;
  late int pageNum = 0;
  RxBool enterLoading = false.obs;
  RxInt count = 0.obs;


  @override
  void onReady() {
    onRefresh();
    super.onReady();
  }


  /// 加载数据
  void onRefresh() async {
    List<MsgNotifyModel>? model = await _getNetData(1);
    if (null == model) {
      refreshController.requestFail(isFirstPage: true);
    } else {
      pageNum = 1;
      bool isEmpty = ArrayUtil.isEmpty(model ?? []);
      refreshController.requestSuccess(isFirstPage: true, isEmpty: isEmpty);
      messageList.assignAll(model);
      update();
    }
  }

  /// 加载更多
  void onLoadMore() async {
    var number = pageNum + 1;
    List<MsgNotifyModel>? model = await _getNetData(number);
    if (null == model) {
      refreshController.requestFail(isFirstPage: false);
    } else {
      pageNum = number;
      refreshController.requestSuccess(
          isFirstPage: false, hasMore: ArrayUtil.isNotEmpty(model ?? []));
      messageList.addAll(model);
      update();
    }
  }

  Future<List<MsgNotifyModel>?> _getNetData(int? pageNum) async {
    List<MsgNotifyModel>? list;
    MsgNotifyListModel? response =
        await ApiRes.getSystemMessageList(type: 2, pageNum: pageNum);
    if (response != null) list = response.list ?? [];
    return list;
  }
}
