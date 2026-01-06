// 🎯 Dart imports:
import 'dart:ui' as ui;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:

// import 'log.dart';

///  note this;
///  1，对于竖屏操作，这里我们只考虑宽适配，相当于操作16:9->4:3；
///  2，不考虑高按照宽的比例缩放，高按照高的比例所犯(16:9->4:3伸缩严重)；
///  3，布局中控件/字体中有固定大小的，统一乘以宽的缩放比例，剩余的用弹性布局填充；
///  4，使用之前，请确保_init()函数已经调用；
///  5，布局应该减少相对布局，使用居中布局，方便UI居中显示，和不同宽的两边留白；
///  6, 水平(宽)适配，每个页面应该支持尽量支持高可以滑动 SafeArea + SingleChildScrollView；
///  7，对于没有使用bottomItemBar的页面，如果页面底部有要交互的UI，请加上SafeArea包裹(适应全面屏幕)
///
///class 表示Screen和与之相关的SafeArea

var screen = _Screen();

class _Screen {
  MediaQueryData _mediaQueryData = MediaQueryData.fromView(ui.window);
  double _screenWidth = .0;
  double _screenHeight = .0;

  /// 设计尺寸
  double designW = 750.0; //DP
  double designH = 812.0; //DP

  var hRate = 1.0; //水平缩放比例
  var vRate = 1.0; //竖直缩放比例，暂时没用
  var paddingLeft = 0.0;
  var paddingRight = 0.0;

  /// 一般为状态栏高度
  var paddingTop = 0.0;

  /// 一般为底部操作栏高度
  var paddingBottom = 0.0;

  /// 水平安全区域
  var safeHorizontal = 0.0;

  /// 垂直安全区域
  var safeVertical = 0.0;

  /// 底部导航栏高度 源码里面写的就是50 dp
  double bottomNavBarH = kBottomNavigationBarHeight + 20;

  bool _initing = false;

  /// 屏幕像素密度
  double devicePixelRatio = 1.0;

  ///设置一倍基准设计尺寸
  void setDesignWH({double width = 360.0, double height = 720.0}) {
    designW = width;
    designH = height;
  }

  /// context != null 强制刷
  void init() {
    if (_initing) return;
    _initing = true;
    _mediaQueryData = MediaQueryData.fromView(ui.window);
    // l.d("screen", 'call init() after', saveFile: true);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    paddingLeft = _mediaQueryData.padding.left;
    paddingTop = _mediaQueryData.padding.top;
    paddingRight = _mediaQueryData.padding.right;
    paddingBottom = _mediaQueryData.padding.bottom;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;

    safeHorizontal = paddingLeft + paddingRight;
    safeVertical = paddingTop + paddingBottom;

    if (_screenWidth > 0.1) {
      hRate = (_screenWidth - safeHorizontal) / designW;
      vRate = (_screenHeight - safeVertical) / designH;
    }
    // _displayHeight = _screenHeight - paddingBottom - bottomNavBarH;
    // l.d("screen",
    //     'screenWidth:$_screenWidth  screenHeight:$_screenHeight safeH:$safeHorizontal denisty:$devicePixelRatio source:${(_screenHeight * devicePixelRatio).round()}*${(_screenWidth * devicePixelRatio).round()} paddingTop:$paddingTop  rate:$hRate',
    //     saveFile: true);

    _initing = false;
  }

  double get screenWidth {
    init();
    return _screenWidth;
  }

  double get screenHeight {
    init();
    return _screenHeight;
  }

  /// @return realDP
  double getWidth(double dp) {
    init();
    return hRate * dp;
  }

  /// @return realDP 暂时使用水平适配宽
  double getHeight(double dp) {
    init();
    return vRate * dp;
  }

  ///返回字体
  double getFont(double design) => design;
// double getFont(double design) {
//   _init();
//   return hRate * design;
// }

// double get displayHeight {
//   init();
//   return _displayHeight;
// }
}
