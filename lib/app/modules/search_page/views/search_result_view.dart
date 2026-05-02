// 🎯 Dart imports:
import 'dart:math' hide log;

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/widget/comic_topic_builder.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
import 'package:quick_cat_client/utils/common_util.dart';
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
    // 禁止惯性滚动触发 load more，避免一屏未铺满时连续请求多页、重复插广告
    return RefreshConfiguration(
        enableBallisticLoad: false,
        child: PullRefreshView(
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
            child: _getPage()));
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

  AdsType _searchListMediaAdsType() {
    final t = widget.searchType;
    if (t == MediaType.videoLong || t == MediaType.cartoon) {
      return AdsType.longVideoListAds;
    }
    return AdsType.shortVideoListAds;
  }

  Future<void> _insertRandomSearchAd(List<MediaInfo> list) async {
    if (list.isEmpty) return;
    final ad = await getAdsMediaInfo(_searchListMediaAdsType());

    if (ad == null) return;
    list.insert(Random().nextInt(list.length + 1), ad);
  }

  Future<void> _insertRandomSearchAdPost(List<PostBrief> list) async {
    if (list.isEmpty) return;
    final ad = await getAdsPostInfo(AdsType.melonListAds);
    if (ad == null) return;
    list.insert(Random().nextInt(list.length + 1), ad);
  }

  Future refresh() async {
    MediaList? model = await _getNetData(1);
    if (!mounted) return;
    pageNum = 1;
    MediaType searchType = widget.searchType;
    if (model == null) return controller.requestFail(isFirstPage: true);
    List<MediaInfo> videoList = List<MediaInfo>.from(model.mediaList ?? []);
    List<MediaInfo> comicList = List<MediaInfo>.from(model.comicsList ?? []);
    List<MediaInfo> novelList = List<MediaInfo>.from(model.novelList ?? []);
    List<PostBrief> postsList = List<PostBrief>.from(model.postList ?? []);
    if (searchType == MediaType.videoLong ||
        searchType == MediaType.videoShort ||
        searchType == MediaType.cartoon) {
      final firstHasMore = videoList.length >= AppConfig.PAGE_SIZE;
      final emptyOrganic = videoList.isEmpty;
      await _insertRandomSearchAd(videoList);
      if (!mounted) return;
      controller.requestSuccess(
          isFirstPage: true,
          isEmpty: emptyOrganic,
          hasMore: firstHasMore);
      setState(() => mediaList = videoList);
    } else if (searchType == MediaType.comic) {
      final firstHasMore = comicList.length >= AppConfig.PAGE_SIZE;
      final emptyOrganic = comicList.isEmpty;
      await _insertRandomSearchAd(comicList);
      if (!mounted) return;
      controller.requestSuccess(
          isFirstPage: true,
          isEmpty: emptyOrganic,
          hasMore: firstHasMore);
      setState(() => mediaList = comicList);
    } else if (searchType == MediaType.novel) {
      final firstHasMore = novelList.length >= AppConfig.PAGE_SIZE;
      final emptyOrganic = novelList.isEmpty;
      await _insertRandomSearchAd(novelList);
      if (!mounted) return;
      controller.requestSuccess(
          isFirstPage: true,
          isEmpty: emptyOrganic,
          hasMore: firstHasMore);
      setState(() => mediaList = novelList);
    } else if (searchType == MediaType.post) {
      final firstHasMore = postsList.length >= AppConfig.PAGE_SIZE;
      final emptyOrganic = postsList.isEmpty;
      await _insertRandomSearchAdPost(postsList);
      if (!mounted) return;
      controller.requestSuccess(
          isFirstPage: true,
          isEmpty: emptyOrganic,
          hasMore: firstHasMore);
      setState(() => postList = postsList);
    }
  }

  Future _loadMore() async {
    var page = pageNum + 1;
    var model = await _getNetData(page);
    if (model == null) return controller.requestFail(isFirstPage: true);
    MediaType searchType = widget.searchType;
    List<MediaInfo> videoList = List<MediaInfo>.from(model.mediaList ?? []);
    List<MediaInfo> comicList = List<MediaInfo>.from(model.comicsList ?? []);
    List<MediaInfo> novelList = List<MediaInfo>.from(model.novelList ?? []);
    List<PostBrief> postsList = List<PostBrief>.from(model.postList ?? []);
    pageNum = page;
    if (searchType == MediaType.videoLong ||
        searchType == MediaType.videoShort ||
        searchType == MediaType.cartoon) {
      final hasMore = videoList.length >= AppConfig.PAGE_SIZE;
      if (videoList.isEmpty) {
        if (!mounted) return;
        controller.requestSuccess(isFirstPage: false, hasMore: false);
        setState(() {});
        return;
      }
      await _insertRandomSearchAd(videoList);
      if (!mounted) return;
      mediaList ??= [];
      mediaList!.addAll(videoList);
      controller.requestSuccess(isFirstPage: false, hasMore: hasMore);
      setState(() {});
    } else if (searchType == MediaType.comic) {
      final hasMore = comicList.length >= AppConfig.PAGE_SIZE;
      if (comicList.isEmpty) {
        if (!mounted) return;
        controller.requestSuccess(isFirstPage: false, hasMore: false);
        setState(() {});
        return;
      }
      await _insertRandomSearchAd(comicList);
      if (!mounted) return;
      mediaList ??= [];
      mediaList!.addAll(comicList);
      controller.requestSuccess(isFirstPage: false, hasMore: hasMore);
      setState(() {});
    } else if (searchType == MediaType.novel) {
      final hasMore = novelList.length >= AppConfig.PAGE_SIZE;
      if (novelList.isEmpty) {
        if (!mounted) return;
        controller.requestSuccess(isFirstPage: false, hasMore: false);
        setState(() {});
        return;
      }
      await _insertRandomSearchAd(novelList);
      if (!mounted) return;
      mediaList ??= [];
      mediaList!.addAll(novelList);
      controller.requestSuccess(isFirstPage: false, hasMore: hasMore);
      setState(() {});
    } else if (searchType == MediaType.post) {
      final hasMore = postsList.length >= AppConfig.PAGE_SIZE;
      if (postsList.isEmpty) {
        if (!mounted) return;
        controller.requestSuccess(isFirstPage: false, hasMore: false);
        setState(() {});
        return;
      }
      await _insertRandomSearchAdPost(postsList);
      if (!mounted) return;
      postList ??= [];
      postList!.addAll(postsList);
      controller.requestSuccess(isFirstPage: false, hasMore: hasMore);
      setState(() {});
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
