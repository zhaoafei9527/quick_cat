// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/array_util.dart';
import 'pull_refresh_view.dart';

typedef AsyncListValueGetter<V> = Function(int pageNum, int pageSize);
typedef PageDataCountGetter<V> = int Function(List<V> pageList);

class PagePullView<V> extends StatefulWidget {
  /// 数据获取器，规定null为失败，为有意义的值，[]为成功且有意义
  final AsyncListValueGetter<V> dataGetter;
  final PageDataCountGetter<V>? pageDataCountGetter;

  final ValueWidgetBuilder<List<V>> widgetBuilder;
  final Widget? emptyView;
  final bool? enablePullDown;
  final bool? enablePullUp;

  const PagePullView(
      {super.key,
      required this.dataGetter,
      this.pageDataCountGetter,
      this.emptyView,
      this.enablePullDown,
      this.enablePullUp,
      required this.widgetBuilder});

  @override
  PagePullViewState<V> createState() => PagePullViewState<V>();
}

class PagePullViewState<V> extends State<PagePullView<V>>
    with AutomaticKeepAliveClientMixin {
  int pageNum = 1;
  PullRefreshController controller = PullRefreshController(isRequest: true);
  List<V> list = [];

  int _pageDataCount(List<V> pageList) =>
      widget.pageDataCountGetter?.call(pageList) ?? pageList.length;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PullRefreshView(
        emptyView: widget.emptyView,
        controller: controller,
        enablePullDown: widget.enablePullDown ?? true,
        enablePullUp: widget.enablePullUp ?? true,
        onRefresh: refresh,
        onLoading: loadMore,
        child: widget.widgetBuilder.call(context, list, null));
  }

  Future refresh() async {
    var mediaList = await widget.dataGetter.call(1, 10);
    if (mediaList == null) {
      controller.requestFail(isFirstPage: true);
      return;
    }
    final pageList = mediaList as List<V>;
    controller.requestSuccess(
        isFirstPage: true,
        isEmpty: ArrayUtil.isEmpty(pageList),
        hasMore: (_pageDataCount(pageList) >= 10));
    pageNum = 1;
    if (mounted) {
      setState(() => list = pageList);
    }
  }

  Future loadMore() async {
    var page = pageNum + 1;
    var mediaList = await widget.dataGetter.call(page, 10);
    if (mediaList == null) {
      controller.requestFail(isFirstPage: false);
      return;
    }
    final pageList = mediaList as List<V>;
    controller.requestSuccess(
        isFirstPage: false, hasMore: _pageDataCount(pageList) >= 10);

    pageNum = page;
    if (mounted) {
      setState(() => list.addAll(pageList));
    }
  }

  @override
  bool get wantKeepAlive => true;
}
