// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// 🌎 Project imports:
import '../../utils/dimens.dart';
import '../themes/app_colors.dart';
import '../widget/common_widget.dart';

enum PULL_REQUEST_CODE {
  REQUESTING, //请求中
  REQUEST_SUCCESS, //请求成功
  REQUEST_FAIL, //请求失败
  REQUEST_DATA_EMPTY, //数据为空
}

class PullRefreshView extends StatefulWidget {
  final PullRefreshController? controller;
  final Widget? child;

  // final VoidCallback retryOnTap; //请求失败重试事件
  final VoidCallback? onRefresh;
  final VoidCallback? onLoading;
  final bool enablePullUp;
  final bool enablePullDown;
  final String? emptyText;
  final Widget? emptyView;
  final String? noDataText;

  const PullRefreshView(
      {super.key,
      @required this.controller,
      @required this.child,
      // this.retryOnTap,
      this.onRefresh,
      this.onLoading,
      this.noDataText,
      this.enablePullUp = true,
      this.enablePullDown = true,
      this.emptyText,
      this.emptyView});

  @override
  _PullRefreshViewState createState() => _PullRefreshViewState();
}

class _PullRefreshViewState extends State<PullRefreshView> {
  VoidCallback? listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.controller != null) {
      widget.controller?.code.addListener(listener ?? () {});
    }
  }

  @override
  void dispose() {
    widget.controller?.code.removeListener(listener ?? () {});
    super.dispose();
  }

  @override
  void initState() {
    listener = () {
      setState(() {});
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Visibility(
          visible: widget.controller?.requestCode ==
                  PULL_REQUEST_CODE.REQUEST_SUCCESS ||
              widget.controller?.requestCode ==
                  PULL_REQUEST_CODE.REQUEST_DATA_EMPTY,
          child: SmartRefresher(
              physics: (!widget.enablePullDown && !widget.enablePullUp)
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              enablePullDown: widget.enablePullDown,
              enablePullUp: widget.enablePullUp,
              header: WaterDropHeader(
                  waterDropColor: AppColors.thridTextColor99,
                  complete: Text("完成加载",
                      style: const TextStyle(
                          color: AppColors.thridTextColor99, fontSize: 14)),
                  refresh: Text("加载中……",
                      style: const TextStyle(
                          color: AppColors.thridTextColor99, fontSize: 14)),
                  failed: Text("加载失败了 刷新试试～",
                      style: const TextStyle(
                          color: AppColors.thridTextColor99, fontSize: 14))),
              // footer: ClassicFooter(
              //     loadingText: "loading……",
              //     canLoadingText: "松开加载更多...",
              //     noDataText: widget.noDataText ?? "已经全部加载完成",
              //     idleText: "上拉加载更多",
              //     failedText: "加载失败了 刷新试试～",
              //     textStyle: const TextStyle(
              //         color: AppColors.thridTextColor99,
              //         fontSize: 14,
              //         decoration: TextDecoration.none,
              //         fontWeight: FontWeight.normal)),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  TextStyle textStyle = const TextStyle(
                      color: AppColors.thridTextColor99,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal);
                  if (mode == LoadStatus.idle) {
                    body = const Text("上拉加载更多");
                  } else if (mode == LoadStatus.loading) {
                    body = Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(
                              radius: Dimens.pt26,
                              color: AppColors.thridTextColor99),
                          SizedBox(width: Dimens.pt10),
                          Text("loading...", style: textStyle)
                        ]);
                  } else if (mode == LoadStatus.failed) {
                    body = Text("加载失败，请重试！", style: textStyle);
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("释放加载更多", style: textStyle);
                  } else {
                    body = Text("没有更多数据了", style: textStyle);
                  }
                  return SizedBox(
                    height: 60.0,
                    child: Center(child: body),
                  );
                },
              ),
              controller: widget.controller!.refreshController,
              onRefresh: () {
                widget.onRefresh?.call();
              },
              onLoading: () {
                widget.onLoading?.call();
              },
              child: (widget.controller?.requestCode ==
                      PULL_REQUEST_CODE.REQUEST_DATA_EMPTY)
                  ? (widget.emptyView ?? const SizedBox())
                  : widget.child)),
      //请求中
      Visibility(
          visible:
              widget.controller?.requestCode == PULL_REQUEST_CODE.REQUESTING,
          child: getLoadingWidget(size: 20, color: const Color(0xFF565454))),

      ///请求失败
      Visibility(
          visible:
              widget.controller?.requestCode == PULL_REQUEST_CODE.REQUEST_FAIL,
          child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(children: <Widget>[
                    SizedBox(height: Dimens.pt6),
                    const Text("加载失败了 刷新试试～",
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFFababab))),
                    Visibility(
                        visible: widget.onRefresh != null,
                        child: InkWell(
                            onTap: () {
                              if (widget.onRefresh != null) {
                                widget.controller?.requesting();
                                widget.onRefresh?.call();
                              }
                            },
                            child: Container(
                                padding: const EdgeInsets.all(10),
                                child: const Text("点击重试",
                                    style: TextStyle(color: Colors.blue))))),
                    const SizedBox(height: 150)
                  ]))))
    ]);
  }
}

class PullRefreshController {
  late ValueNotifier<PULL_REQUEST_CODE> code;

  // bool isFirstPage = false;
  late RefreshController refreshController;

  PullRefreshController({bool isRequest = true}) {
    refreshController = RefreshController();
    if (isRequest) {
      code = ValueNotifier(PULL_REQUEST_CODE.REQUESTING);
    } else {
      code = ValueNotifier(PULL_REQUEST_CODE.REQUEST_SUCCESS);
    }
  }

  PULL_REQUEST_CODE get requestCode => code.value;

  //请求失败
  requestFail({@required bool? isFirstPage}) {
    if (isFirstPage ?? false) {
      _refreshFail();
    } else {
      _loadMoreFail();
    }
  }

  _refreshFail() {
    if (refreshController.isRefresh) {
      refreshController.refreshFailed();
    }
    code.value = PULL_REQUEST_CODE.REQUEST_FAIL;
  }

  _loadMoreFail() {
    if (refreshController.isLoading) {
      refreshController.loadFailed();
    }
    code.value = PULL_REQUEST_CODE.REQUEST_SUCCESS;
  }

  /// 请求成功
  /// [isFirstPage] :`true` must set [isEmpty],`false` must set [hasMore]
  requestSuccess({@required bool? isFirstPage, bool? isEmpty, bool? hasMore}) {
    if (isFirstPage ?? false) {
      if (null == isEmpty && null != hasMore) {
        isEmpty = !hasMore;
      }
      isEmpty ??= false;
      _refreshSuc(isEmpty: isEmpty, hasMore: hasMore ?? true);
    } else {
      if (null == hasMore && null != isEmpty) {
        hasMore = !isEmpty;
      }
      assert(null != hasMore, "加载成功必须设置hasMore字段");
      _loadMoreSuc(hasMore: hasMore ?? false);
    }
  }

  _refreshSuc({bool isEmpty = false,bool? hasMore}) {
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted(resetFooterState: true);
    }
    if(!(hasMore??false)){
      refreshController.loadNoData();
    }
    if (isEmpty) {
      code.value = PULL_REQUEST_CODE.REQUEST_DATA_EMPTY;
      refreshController.loadNoData();
    } else {
      code.value = PULL_REQUEST_CODE.REQUEST_SUCCESS;
    }
  }

  _loadMoreSuc({bool hasMore = true}) {
    // if (refreshController.isLoading) {
    //   refreshController.loadComplete();
    // }
    if (hasMore) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
    code.value = PULL_REQUEST_CODE.REQUEST_SUCCESS;
  }

  // //数据为空
  // requestDataEmpty({@required bool isFirstPageNum}) {
  //   isFirstPage = isFirstPageNum;
  //   code?.value = PULL_REQUEST_CODE.REQUEST_DATA_EMPTY;
  //   if (!isFirstPage) {
  //     refreshController.loadNoData();
  //   }
  // }

  //请求中
  requesting() {
    code.value = PULL_REQUEST_CODE.REQUESTING;
  }
}
