// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/conf/config.dart';
import 'package:quick_cat_client/utils/array_util.dart';
import '../../../../utils/light_model.dart';
import '../../../../utils/text_util.dart';
import '../../../../utils/toast_util.dart';
import '../../../model/hot_search.dart';
import '../views/search_result_view.dart';

class SearchPageController extends GetxController
    with GetTickerProviderStateMixin {
  TextEditingController textEditingController = TextEditingController();
  RxBool isSearch = false.obs;
  RxBool initOk = false.obs;
  List<String> tabList = ["吃瓜", "视频", "抖阴", "动漫", "小说"];
  List<String> tagTabList = ["漫画", "动漫", "小说", "长视频", "短视频"];
  late TabController tabController;
  late TabController tagTabController;
  late TabController typeTabController;
  GlobalKey<SearchResultViewState> comicKey = GlobalKey();
  GlobalKey<SearchResultViewState> novelKey = GlobalKey();
  GlobalKey<SearchResultViewState> cartoonKey = GlobalKey();
  GlobalKey<SearchResultViewState> longVideoKey = GlobalKey();
  GlobalKey<SearchResultViewState> shortVideoKey = GlobalKey();
  GlobalKey<SearchResultViewState> postKey = GlobalKey();

  List<String> recommendType = ["今日吃瓜", "本周最热", "当月最火"];
  RxInt recommendIndex = 0.obs;

  RxList<String> historyWords = <String>[].obs;
  RxList<MediaInfo>? mediaRankList = <MediaInfo>[].obs;
  RxList<HotSearchResultModel>? hotSearchKeys = <HotSearchResultModel>[].obs;
  RxMap<MediaType, List<String>> hotSearchTagMap =
      <MediaType, List<String>>{}.obs;
  List<MediaType> mediaTypeList = [
    MediaType.post,
    MediaType.videoLong,
    MediaType.videoShort,
    MediaType.cartoon,
    MediaType.novel
  ];
  late List<GlobalKey<SearchResultViewState>> searchKeyList;

  @override
  void onInit() async {
    tabController = TabController(length: tabList.length, vsync: this);
    tagTabController = TabController(length: tagTabList.length, vsync: this);
    typeTabController = TabController(length: tagTabList.length, vsync: this);
    typeTabController.addListener(() {
      if (typeTabController.indexIsChanging) return;
      recommendIndex.value = typeTabController.index;
    });
    searchKeyList = [
      postKey,
      longVideoKey,
      shortVideoKey,
      cartoonKey,
      novelKey
    ];
    await getHistoryLocalData();
    await getHotSearchNetData();
    initOk.value = true;
    tabController.addListener(() {
      if (tabController.indexIsChanging) return;
      autoSearch();
    });
    update();
    super.onInit();
  }

  Future getHotSearchNetData({pageNum}) async {
    HotSearchModel? model = await ApiRes.getHotSearchApi();
    hotSearchTagMap.value = model?.tagTypeMap ?? {};
  }

  autoSearch() {
    var index = tabController.index;
    var text = textEditingController.text;

    if (searchKeyList[index].currentState?.keyWord == text) {
      if (ArrayUtil.isEmpty(
          searchKeyList[index].currentState?.mediaList ?? [])) {
        searchKeyList[index].currentState?.refresh();
      }
    } else {
      searchKeyList[index].currentState?.search(text);
    }
  }

  void searchData({String? searchKey}) async {
    if ((searchKey ?? "").isNotEmpty) {
      textEditingController.text = searchKey!;
    }
    var text = textEditingController.text;
    if (TextUtil.isEmpty(text)) {
      showToast(msg: '请输入搜索内容');
      return;
    }
    isSearch.value = true;
    _addOneHistory(text);

    var index = tabController.index;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchKeyList[index].currentState?.search(text);
    });
  }

  void deleteOneHistory(String text) {
    if (TextUtil.isNotEmpty(text)) {
      historyWords.removeWhere((e) => e == text);
      lightKV.setStringList(AppConfig.KEY_SEARCH_HISTORYS, historyWords);
      historyWords.refresh();
    }
  }

  void clearHistory() {
    historyWords.clear();
    lightKV.remove(AppConfig.KEY_SEARCH_HISTORYS);
  }

  void _addOneHistory(String text) {
    if (TextUtil.isNotEmpty(text)) {
      historyWords.removeWhere((e) => e == text);
      if (historyWords.length >= 8) historyWords.removeLast();
      historyWords.insert(0, text);
      lightKV.setStringList(AppConfig.KEY_SEARCH_HISTORYS, historyWords);
    }
  }

  getHistoryLocalData() async {
    List<String>? list = [];
    list = await lightKV.getStringList(AppConfig.KEY_SEARCH_HISTORYS) ?? [];
    historyWords.value = list;
  }
}
