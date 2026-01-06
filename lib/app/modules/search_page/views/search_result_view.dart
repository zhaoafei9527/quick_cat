// 🎯 Dart imports:
import 'dart:math' hide log;

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/app/model/post_list_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/views/pull_refresh_view.dart';
import 'package:quick_cat_client/app/widget/long_video_cover.dart';
import 'package:quick_cat_client/app/widget/post_item.dart';
import 'package:quick_cat_client/app/widget/short_video_cover.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/conf/config.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/array_util.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/text_util.dart';

/// 搜索结果页面
class SearchResultView extends StatefulWidget {
  final MediaType searchType;

  const SearchResultView({super.key, required this.searchType});

  @override
  SearchResultViewState createState() => SearchResultViewState();
}

class SearchResultViewState extends State<SearchResultView>
    with AutomaticKeepAliveClientMixin {
  int pageNum = 1;
  PullRefreshController controller = PullRefreshController(isRequest: false);
  List<MediaInfo>? mediaList;
  List<PostBrief>? postList;
  List<Advertise>? adsListLong;
  List<Advertise>? adsListShort;
  String? keyWord;

  @override
  void initState() {
    super.initState();
    initAdsList();
    log.i("initState()", "${widget.searchType}");
  }

  initAdsList() async {
    adsListLong = await LocalAdsStore().where(AdsType.longVideoListAds) ?? [];
    adsListShort = await LocalAdsStore().where(AdsType.shortVideoListAds) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return PullRefreshView(
        controller: controller,
        onRefresh: refresh,
        onLoading: _loadMore,
        emptyView:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(R.assetsImgIconSerchEmpty,
              width: Dimens.pt200, height: Dimens.pt200),
          Text("sorry，小宝贝用尽全力也没有找到",
              style: TextStyle(
                  fontSize: Dimens.pt26, color: const Color(0xFF565454)))
        ]),
        child: _getPage());
  }

  Future search(String text) async {
    if (TextUtil.isEmpty(text)) return;
    text = text.trim();
    if (TextUtil.isEmpty(text)) return;
    keyWord = text;
    if (EasyLoading.isShow) await EasyLoading.dismiss();
    await EasyLoading.show(status: '请求中');
    await refresh();
    await EasyLoading.dismiss();
  }

  Future refresh() async {
    MediaList? model = await _getNetData(1);
    if (!mounted) return;
    pageNum = 1;
    MediaType searchType = widget.searchType;
    if (model == null) return controller.requestFail(isFirstPage: true);
    List<MediaInfo> videoList = model.mediaList ?? [];
    List<MediaInfo> comicList = model.comicsList ?? [];
    List<MediaInfo> novelList = model.novelList ?? [];
    List<PostBrief> postsList = model.postList ?? [];
    if (searchType == MediaType.videoLong ||
        searchType == MediaType.videoShort ||
        searchType == MediaType.cartoon) {
      controller.requestSuccess(
          isFirstPage: true, isEmpty: ArrayUtil.isEmpty(videoList));
      setState(() => mediaList = videoList);
    } else if (searchType == MediaType.comic) {
      controller.requestSuccess(
          isFirstPage: true, isEmpty: ArrayUtil.isEmpty(comicList));
      setState(() => mediaList = comicList);
    } else if (searchType == MediaType.novel) {
      controller.requestSuccess(
          isFirstPage: true, isEmpty: ArrayUtil.isEmpty(novelList));
      setState(() => mediaList = novelList);
    } else if (searchType == MediaType.post) {
      controller.requestSuccess(
          isFirstPage: true, isEmpty: ArrayUtil.isEmpty(postsList));
      setState(() => postList = postsList);
    }
  }

  Future _loadMore() async {
    var page = pageNum + 1;
    var model = await _getNetData(page);
    if (model == null) return controller.requestFail(isFirstPage: true);
    MediaType searchType = widget.searchType;
    List<MediaInfo> videoList = model.mediaList ?? [];
    List<MediaInfo> comicList = model.comicsList ?? [];
    List<MediaInfo> novelList = model.novelList ?? [];
    List<PostBrief> postsList = model.postList ?? [];
    pageNum = page;
    if (searchType == MediaType.videoLong ||
        searchType == MediaType.videoShort ||
        searchType == MediaType.cartoon) {
      controller.requestSuccess(
          isFirstPage: false, hasMore: videoList.length >= AppConfig.PAGE_SIZE);
      setState(() => mediaList?.addAll(videoList));
    } else if (searchType == MediaType.comic) {
      controller.requestSuccess(
          isFirstPage: false, hasMore: comicList.length >= AppConfig.PAGE_SIZE);
      setState(() => mediaList?.addAll(comicList));
    } else if (searchType == MediaType.novel) {
      controller.requestSuccess(
          isFirstPage: false, hasMore: novelList.length >= AppConfig.PAGE_SIZE);
      setState(() => mediaList?.addAll(novelList));
    } else if (searchType == MediaType.post) {
      controller.requestSuccess(
          isFirstPage: false, hasMore: postsList.length >= AppConfig.PAGE_SIZE);
      setState(() => postList?.addAll(postsList));
    }
  }

  Future<MediaList?> _getNetData(int pageNum) async {
    MediaList? mediaList;
    try {
      MediaList? model = await ApiRes.getSearchResultData(
          pageNum: pageNum, type: widget.searchType.index, content: keyWord);
      mediaList = model;
    } catch (e) {
      debugPrint(
          "search_result :_getNetData()...$keyWord ==> ${widget.searchType}$e");
    }
    return mediaList;
  }

  Widget _getPage() {
    if (widget.searchType == MediaType.post) {
      return _buildPostSearchView(postList);
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
        child: buildCommonMediaGrid(mediaList ?? [],
            mediaType: widget.searchType,
            paddingTop: Dimens.pt0, dataGetter: (int pageNum) async {
          List<MediaInfo> list = <MediaInfo>[];
          MediaList? model = await ApiRes.getSearchResultData(
              pageNum: pageNum,
              type: widget.searchType.index,
              content: keyWord);
          list = model?.mediaList ?? [];
          return list;
        }),
      );
    }
  }

  Widget _buildPostSearchView(List<PostBrief>? postList) {
    return ListView.separated(
        itemBuilder: (c, index) => PostItem(postBrief: postList![index]),
        separatorBuilder: (c, index) => SizedBox(height: Dimens.pt25),
        itemCount: postList?.length ?? 0);
  }

  @override
  bool get wantKeepAlive => true;
}
