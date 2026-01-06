// 🐦 Flutter imports:
import 'package:flutter/widgets.dart';

// 📦 Package imports:
import 'package:card_swiper/card_swiper.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/model/home/user_info_model.dart';
import 'package:acgn_client/r.dart';
import '../../../../conf/api_res.dart';
import '../../../model/vip_card_list_model.dart';

class UserTermsPageController extends GetxController {
  final count = 0.obs;
  RxInt actionIndex = 0.obs;
  RxBool initOk = false.obs;
  SwiperController swiperController = SwiperController();
  ScrollController tipScrollController = ScrollController();
  List<String> logoList = [];
  List<Map<String, dynamic>> levelCardInfo = [];
  List<Map<String, dynamic>> levelAllInterests = [];
  late List<String> envelope;
  List<int> growthList = [0, 50, 50, 1500, 9000, 50000, 300000, 800000];

  late List<String> datingTitle;
  late List<String> datingDesc;

  var userInfo = UserInfo().obs;
  var vipCardData = <CardInfoList>[].obs;
  RxList<RightDataList> rights = <RightDataList>[].obs;

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKey = Get.find<ShareKeys>();
    userInfo.value = await shareKey.getUserInfo(); // Load user info
    count.value = 2;
    // levelCardInfo = [
    //   {"name": "赌怪", "value": "50.00"},
    //   {"name": "赌霸", "value": "1000.00"},
    //   {"name": "赌魔", "value": "9000.00"},
    //   {"name": "赌圣", "value": "50000.00"},
    //   {"name": "赌侠", "value": "300000.00"},
    //   {"name": "赌神", "value": "800000.00"},
    // ];
    // envelope = ["1.8", "1.8", "3.8", "5.8", "8.8", "12.8", "18.8"];
    // datingTitle = ["", "", "", "超嫩嫩模1次", "高端嫩模3次", "十八线明星7天"];
    // datingDesc = ["", "", "",  "全国空降,包夜1次", "全国空降,包夜3次", "全球伴游7天！"];
    // levelAllInterests = [
    //   {"icon": R.assetsImgIconVipFreeAds, "title": "免广告", "desc": "免除片头广告"},
    //   {"icon": R.assetsImgIconVipShock, "title": "震动模式", "desc": "让您身临其境体验快感"},
    //   {"icon": R.assetsImgIconVipMedal, "title": "勋章一枚", "desc": "用户名后缀显示"},
    //   {"icon": R.assetsImgIconVipId, "title": "炫彩ID", "desc": "用户名变色"},
    //   {"icon": R.assetsImgIconVipBarrage, "title": "炫彩弹幕", "desc": "弹幕变色"},
    //   {"icon": R.assetsImgIconVipDating, "title": "", "desc": ""},
    //   {"icon": R.assetsImgIconVipBirth, "title": "生日礼金", "desc": "生日礼物大红包"},
    //   {"icon": R.assetsImgIconVipEnvelope, "title": "元", "desc": "每天红包,每天都能领取"},
    // ];
    // print("执行");
    VipCardList? model = await ApiRes.getVipCardList();
    if (model != null) {
      vipCardData.value = model.cardInfoList ?? [];
      if ((model.rightDataList ?? []).isNotEmpty) {
        rights.value = model.rightDataList??[];
      }
    }
    initOk.value = true;
    update();
  }

  void increment() => count.value++;
}
