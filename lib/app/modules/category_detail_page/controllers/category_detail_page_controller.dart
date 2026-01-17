import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryDetailPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TabController? sortTabController;
  MediaType mediaType = MediaType.comic; // 默认漫画专题
  List<String> sortList = ["综合排序", "最新上架", "最多观看", "最多收藏"];
  List<String> updateStatus = ["更新状态", "连载中", "完结"];
  List<String> payStatus = ["收费类型", "会员", "免费"];
  List<String> tabList = ["视频类型","视频", "抖阴", "动漫", "小说"];

  // List<String> comicType = ["全部", "韩漫", "日漫", "美漫", "大陆", "其他"];
  // List<Tag> yearList = [];
  // List<Tag> monthList = [];

  RxInt typeIndex = 0.obs;

  RxInt comicTypeIndex = 0.obs;
  RxInt updateStatusIndex = 0.obs;
  RxInt payStatusIndex = 0.obs;
  RxInt sortIndex = 0.obs;



  // 按分类选择的标签
  RxMap<int, Tag> tagTypeChooseId = <int, Tag>{}.obs;

  // 按照分类展示的标签列表
  RxMap<int, List<Tag>> showTagMapList = <int, List<Tag>>{}.obs;

  // 返回的标签列表数据
  Rx<CategoryTagModel> categoryTagModel = CategoryTagModel().obs;

  List<MediaType> typeSort = [
    MediaType.videoLong,
    MediaType.videoLong,
    MediaType.videoShort,
    MediaType.cartoon,
    MediaType.novel,
  ];

  @override
  void onInit() async {
    super.onInit();
    // getYearList();

    sortTabController = TabController(length: tabList.length, vsync: this);
    await getCategoryTagMapNetData();
  }

  Future<List<MediaInfo>> dataGetterFunction(MediaType type,
      {int? pageNum}) async {
    List<MediaInfo> mediaList = [];
    String apiPath = "tag/listByTagSort";
    switch (type) {
      case MediaType.comic:
        apiPath = "comicsTag/listById";
        break;
      case MediaType.novel:
        apiPath = "novelTag/listByTag";
        break;
      default:
        apiPath = "tag/listByTagSort";
        break;
    }
    int p = payStatusIndex.value;
    int? payType = p;
    if (p == 0) payType = null;
    if (p == 3) payType = 0;

    MediaList? model = await ApiRes.categorySearch(
        tagId: tagTypeChooseId[type.index]?.id ?? 0,
        contentType: type,
        pageNum: pageNum ?? 1,
        area: comicTypeIndex.value,
        sort: sortIndex.value,
        apiPath: apiPath,
        updateStatus: updateStatusIndex.value,
        payType: payType);
    if (model != null && (type == MediaType.comic || type == MediaType.novel)) {
      mediaList = model.list ?? [];
    } else if (model != null &&
        (type == MediaType.cartoon ||
            type == MediaType.videoLong ||
            type == MediaType.videoShort)) {
      mediaList = model.mediaList ?? [];
    }
    return mediaList;
  }

  void onTagTypeChange(int type, Tag tag) {
    tagTypeChooseId[type] = tag;
    // if (type == monthType && tagTypeChooseId[yearType] == null) {
    //   tagTypeChooseId[yearType] = yearList.first;
    // }
    tagTypeChooseId.refresh();
  }

  //
  // getYearList() {
  //   DateTime now = DateTime.now();
  //   int year = now.year;
  //   for (int i = 1; i <= 12; i++) {
  //     monthList.add(Tag(id: i, name: "$i月"));
  //   }
  //   for (int i = 0; i < 31; i++) {
  //     yearList.add(Tag(id: year - i, name: "${year - i}年"));
  //   }
  //   updateTagGroup(yearList, yearType);
  //   updateTagGroup(monthList, monthType);
  // }

  // 获取所有标签列表
  Future<void> getCategoryTagMapNetData() async {
    CategoryTagModel? model = await ApiRes.getCategoryTagMap();
    if (model != null) {
      categoryTagModel.value = model;
      for (int i = 0; i < typeSort.length; i++) {
        List<Tag> tagList = model.tagModel![typeSort[i]] ?? [];
        updateTagGroup(tagList, typeSort[i].index);
      }
    }
  }

  void updateTagGroup(List<Tag> tagList, int setType, {bool open = false}) {
    List<Tag> newTags = [];
    newTags = tagList.sublist(0, tagList.length);

    showTagMapList[setType] = [Tag(id: 0, name: "全部类型"), ...newTags];

    showTagMapList.refresh();
    // update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
