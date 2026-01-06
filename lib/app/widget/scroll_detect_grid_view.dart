// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:

class ScrollListenAutoLoadNeed extends StatefulWidget {
  Widget? child;
  double? rowHeight;
  int? crossAxisCount;
  Function(List<int>)? onChange;

  ScrollListenAutoLoadNeed({super.key, this.child, this.rowHeight,
    this.onChange,
    this.crossAxisCount});

  @override
  State<ScrollListenAutoLoadNeed> createState() =>
      _ScrollListenAutoLoadNeedState();
}

class _ScrollListenAutoLoadNeedState extends State<ScrollListenAutoLoadNeed> {

  double get rowHeight => widget.rowHeight ?? 0.0;

  int get crossAxisCount => widget.crossAxisCount ?? 1;

  List<int> _tempList = [0, 1];

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          if (rowHeight <= 0) return false;
          double scrollOffset = scrollNotification.metrics.pixels;
          // 可视区域高度
          double viewportHeight = scrollNotification.metrics.viewportDimension;
          // 计算当前可见的“行”区间
          final double topRow = scrollOffset / rowHeight; // 顶部行索引(浮点)
          final double bottomRow =
              (scrollOffset + viewportHeight) / rowHeight; // 底部行索引(浮点)
          // 向下取整/向上取整，得到完整行索引范围
          final int startRowIndex = topRow.floor();
          final int endRowIndex = bottomRow.ceil();
          // 再根据列数 crossAxisCount，推算成 item 索引
          final int startItemIndex = startRowIndex * crossAxisCount;
          final int endItemIndex = endRowIndex * crossAxisCount - 1;
          if (startItemIndex != _tempList[0] && endItemIndex != _tempList[1]) {
            widget.onChange?.call([startItemIndex, endItemIndex]);
          }
          _tempList = [startItemIndex, endItemIndex];
        }
        return false;
      },
      child: widget.child ?? const SizedBox(),
    );
  }
}
