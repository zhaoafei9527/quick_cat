// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/utils/array_util.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'pull_refresh_view.dart';

typedef AsyncListValueGetter<V> = Function(int pageNum, int pageSize);

class PagePullView<V> extends StatefulWidget {
  /// 数据获取器，规定null为失败，为有意义的值，[]为成功且有意义
  final AsyncListValueGetter<V> dataGetter;

  final ValueWidgetBuilder<List<V>> widgetBuilder;
  final Widget? emptyView;
  final bool? enablePullDown;
  final bool? enablePullUp;

  const PagePullView(
      {super.key,
      required this.dataGetter,
      this.emptyView,
      this.enablePullDown,
      this.enablePullUp,
      required this.widgetBuilder});

  @override
  PagePullViewState<V> createState() => PagePullViewState<V>();
}

class PagePullViewState<V> extends State<PagePullView>
    with AutomaticKeepAliveClientMixin {
  int pageNum = 1;
  PullRefreshController controller = PullRefreshController(isRequest: true);
  List<V> list = [];

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
    controller.requestSuccess(
        isFirstPage: true,
        isEmpty: ArrayUtil.isEmpty(mediaList),
        hasMore: (mediaList.length >= 10));
    pageNum = 1;
    if (mounted) {
      setState(() => list = mediaList as List<V>);
    }
  }

  Future loadMore() async {
    var page = pageNum + 1;
    var mediaList = await widget.dataGetter.call(page, 10);
    if (mediaList == null) {
      controller.requestFail(isFirstPage: false);
      return;
    }
    controller.requestSuccess(
        isFirstPage: false, hasMore: mediaList.length >= 10);

    pageNum = page;
    if (mounted) {
      setState(() => list.addAll(mediaList as List<V>));
    }
  }

  @override
  bool get wantKeepAlive => true;
}
