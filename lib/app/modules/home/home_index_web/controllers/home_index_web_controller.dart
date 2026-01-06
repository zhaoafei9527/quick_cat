// 🐦 Flutter imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/ads_type.dart';
import 'package:acgn_client/app/data/share_key.dart';
import 'package:acgn_client/app/dialog/announce_dialog.dart';
import 'package:acgn_client/app/model/home/config_model_model.dart';
import 'package:acgn_client/app/model/home/user_info_model.dart';
import '../../../../dialog/advertise_dialog.dart';
import '../../../../notifier/bus_events.dart';

class HomeIndexWebController extends GetxController
    with GetTickerProviderStateMixin {
  final count = 0.obs;
  RxBool initOk = false.obs;
  RxBool endDrawLoading = false.obs;
  RxInt currentTabIndex = 0.obs;
  int currentCategoryId = 0; // 当前分类ID
  MediaType currentType = MediaType.comic; // 当前分类类型
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? tabController; // 首页主分类
  late TabController postCategoryTab; // 漫画二级分类
  late TabController videoCategoryTab; // 视频库二级分类
  late TabController shortCategoryTab; // 抖音二级分类
  late TabController cartoonCategoryTab; // 动漫二级分类
  late TabController novelCategoryTab; // 小说二级分类


  RxList<TopicList> topicList = <TopicList>[].obs; // 话题列表
  List<String> cateList = ["吃瓜", "视屏", "抖音", "影院", "小说"];
  RxList<Advertise> gameAdList = <Advertise>[].obs;
  RxList<MediaCategory> postCategory = <MediaCategory>[].obs; // 吃瓜分类数据
  RxList<MediaCategory> videoCategory = <MediaCategory>[].obs; // 视频库分类数据
  RxList<MediaCategory> shortCategory = <MediaCategory>[].obs; // 短视频分类数据
  RxList<MediaCategory> cartoonCategory = <MediaCategory>[].obs; // 动漫分类数据
  RxList<MediaCategory> novelCategory = <MediaCategory>[].obs; // 小说分类数据


  Rx<UserInfo> userInfo = UserInfo().obs;

  @override
  void onInit() async {
    super.onInit();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = await shareKeys.getUserInfo();
    tabController = TabController(length: cateList.length, vsync: this);
    tabController?.addListener(() {
      currentTabIndex.value = tabController!.index;
      if (tabController!.index == 0) {
        currentType = MediaType.post;
      } else if (tabController!.index == 1) {
        currentType = MediaType.videoLong;
      } else if (tabController!.index == 2) {
        currentType = MediaType.videoShort;
      } else if (tabController!.index == 3) {
        currentType = MediaType.cartoon;
      } else if (tabController!.index == 4) {
        currentType = MediaType.novel;
      }
    });
    postCategory.value = shareKeys.postCategory;
    postCategoryTab = TabController(length: postCategory.length, vsync: this);

    videoCategory.value = shareKeys.mediaCategory;
    videoCategoryTab = TabController(length: videoCategory.length, vsync: this);

    shortCategory.value = shareKeys.dMediaCategory;
    shortCategoryTab =
        TabController(length: shortCategory.length, vsync: this);

    cartoonCategory.value = shareKeys.cartoonCategory;
    cartoonCategoryTab =
        TabController(length: cartoonCategory.length, vsync: this);
    novelCategory.value = shareKeys.novelCategory;
    novelCategoryTab = TabController(length: novelCategory.length, vsync: this);


    initOk.value = true;
    // 检查并弹出公告弹窗
    var announce = await showAnnounceDialog(Get.context!);
    List<Advertise> adsList =
        await LocalAdsStore().where(AdsType.homePopUpsAdsCome) ?? [];
    gameAdList.value =
        await LocalAdsStore().where(AdsType.homeGameIconAds) ?? [];
    for (Advertise item in adsList) {
      await showAdvertiseDialog(Get.context!, item);
    }

    update();
  }

  void changeTabIndex(int index) {
    currentTabIndex.value = index;
    tabController?.animateTo(index);
  }

  void openEndDrawer(int id, MediaType type) async {
    currentType = type;
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeEndDrawer();
    } else {
      scaffoldKey.currentState?.openEndDrawer();
      endDrawLoading.value = true;
      CategoryTopics? model =
          await ApiRes.getTopicOfCategory(id: id, type: type);
      endDrawLoading.value = false;
      if (model != null) {
        topicList.value = model.list ?? [];
      } else {
        topicList.value = [];
      }
    }
  }

  @override
  void onReady() async {
    // 切换配置 监听 并更换本地系统配置
    eventBus.on(EventsBusKey.subUpdateVpnInfo)?.listen((event) async {});
    super.onReady();
  }
}
