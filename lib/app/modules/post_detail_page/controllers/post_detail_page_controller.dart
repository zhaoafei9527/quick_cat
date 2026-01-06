// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/data/watch_record.dart';
import 'package:quick_cat_client/utils/text_util.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/conf/api_res.dart';
import '../../../data/ads_type.dart';
import '../../../model/home/config_model_model.dart';
import '../../../model/post_list_model.dart';

class PostDetailPageController extends GetxController {
  int id = 0;
  RxBool initOk = false.obs;
  RxBool imageViewer = false.obs;
  RxBool backing = false.obs;
  Rx<PostDetailsResp> post = PostDetailsResp().obs;

  @override
  void onInit() async {
    super.onInit();
    imageViewer.value = false;
    backing.value = false;

    id = TextUtil.getIntArgument("id");
    await getPostInfo();
    initOk.value = true;
  }


  /// Get flashlight status
  Future<Advertise?> getCommentAds() async {
    try {
      Advertise? ad = await LocalAdsStore().randomWhere(AdsType.commentsAds);
      return ad;
    } on PlatformException catch (e) {
      throw Exception(e.code);
    }
  }

  Future getPostInfo() async {
    PostDetailsResp? model = await ApiRes.getPostDetail(id: id);
    if (model != null) {
      post.value = model;
    }
  }
}
