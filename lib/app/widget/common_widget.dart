// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import '../../r.dart';
import '../../utils/dimens.dart';
import '../../utils/text_util.dart';
import '../model/home/config_model_model.dart';
import '../views/round_under_line_tab_indicator.dart';

/// 获取加载中的widget
Widget getLoadingWidget({double? size, Color? color}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return Center(
    child: CupertinoActivityIndicator(
      radius: size ?? 16,
      color: theme.getColor(ThemeColor.primary),
    ),
  );
}

Widget buildCommonEmptyView(String? text) {
  ThemeManager theme = Get.find<ThemeManager>();
  return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        Image.asset(R.assetsImgIconSerchEmpty,
            width: Dimens.pt200, height: Dimens.pt200),
        Text(text ?? "什么也没找到～",
            style: TextStyle(
                fontSize: Dimens.pt26,
                color: theme.getColor(ThemeColor.textGrey)))
      ]));
}

enum GetToastType { success, error, warning }

SnackbarController showGetToast(title, content,
    {GetToastType? type = GetToastType.success, double? radius}) {
  return Get.snackbar(
    title ?? "", // 标题
    content ?? "", // 消息文本
    snackPosition: SnackPosition.TOP,
    // Snackbar 的位置
    backgroundColor: Colors.blue,
    // 背景颜色
    borderRadius: radius ?? 20,
    // 边框圆角
    margin: EdgeInsets.all(Dimens.pt15),
    // 边距
    colorText: Colors.white,
    // 文本颜色
    duration: const Duration(seconds: 3),
    // 显示时长
    isDismissible: true,
    // 是否可以通过滑动来关闭
    dismissDirection: DismissDirection.horizontal,
    // 关闭方向
    forwardAnimationCurve: Curves.easeOutBack, // 显示动画
  );
}

/// 获取空Widget
Widget getEmptyWidget({String? img, String? emptyText}) {
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    // Column(children: [
    //   ImageLoader.withP(img ?? ImgAssets.ICON_DATA_EMPTY, width: Dimens.pt180)
    //       .load(),
    // ]),
    Container(
        alignment: Alignment.center,
        child: Text(emptyText ?? "暂无数据",
            style: TextStyle(
                fontSize: Dimens.pt28, color: const Color(0xFFB9BABA))))
  ]);
}

/// 构建一个APP内所有大致一样的TabBar
Widget buildCommonTabBar(
    {double? distance,
    TabController? controller,
    List<Widget>? tabs,
    double? fontSize,
    Color? fontColor,
    Color? boxColor,
    Color? unselectedLabelColor,
    EdgeInsetsGeometry? padding,
    TabAlignment? alignment,
    bool? isScrollable,
    bool? boxMode,
    double? insetsWidth,
    double? insets}) {
  ThemeManager theme = Get.find<ThemeManager>();
  boxMode ??= false;
  return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: TabBar(
          controller: controller,
          isScrollable: isScrollable ?? true,
          tabs: tabs ?? [],
          labelStyle: TextStyle(fontSize: fontSize ?? Dimens.pt36),
          labelColor: fontColor ?? AppColors.textColorWhite,
          indicatorWeight: Dimens.pt10,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
          unselectedLabelStyle: TextStyle(fontSize: fontSize ?? Dimens.pt36),
          unselectedLabelColor:
              unselectedLabelColor ?? AppColors.textColorWhite,
          dividerColor: Colors.transparent,
          tabAlignment: alignment ?? TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          indicator: boxMode
              ? BoxDecoration(
                  color: boxColor ?? theme.getColor(ThemeColor.primary),
                  borderRadius: BorderRadius.circular(Dimens.pt8))
              : RoundUnderlineTabIndicator(
                  insets:
                      EdgeInsets.symmetric(horizontal: insets ?? Dimens.pt10),
                  borderSide: BorderSide(
                      width: insetsWidth ?? Dimens.pt4,
                      color: boxColor ?? theme.getColor(ThemeColor.primary)),
                  wantToWith: Dimens.pt6)));
}

AppBar buildAppBar(
    {String? title, bool? center, List<Widget>? actions, Color? titleColor}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    leading: GestureDetector(
      onTap: () => Get.back(),
      child: Icon(Icons.arrow_back_ios_rounded,
          size: Dimens.pt20, color: Colors.black),
    ),
    title: Text(title ?? "",
        style: TextStyle(
            fontSize: Dimens.pt16,
            color: titleColor ?? Colors.black,
            fontWeight: FontWeight.w700)),
    centerTitle: center ?? true,
    actions: actions,
  );
}

class LoadingView extends StatelessWidget {
  final Widget? child;
  final bool? loading;
  final Color? backgroundColor;
  final Color? loadingColor;
  final String? loadingText;
  final double? loadingSize;
  final double? opacity;

  const LoadingView({
    super.key,
    this.child,
    this.loading,
    this.backgroundColor,
    this.loadingColor,
    this.loadingText,
    this.loadingSize,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Stack(alignment: Alignment.center, children: [
      if (!(loading ?? false)) child ?? Container(),
      if (loading ?? false)
        Container(
            width: double.infinity,
            height: double.infinity,
            color: backgroundColor ?? Colors.black.withOpacity(opacity ?? 0.7),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  CupertinoActivityIndicator(
                      radius: loadingSize ?? 16,
                      color:
                          loadingColor ?? theme.getColor(ThemeColor.primary)),
                  if (loadingText != null) ...[
                    SizedBox(height: 20),
                    Text(loadingText!,
                        style: TextStyle(
                            color: theme.getColor(ThemeColor.bg),
                            fontSize: Dimens.pt28))
                  ]
                ])))
    ]);
  }
}

Widget getLoadingView(
    {double size = 12, Color? color, bool showLoading = true}) {
  return Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    CupertinoActivityIndicator(
        radius: size, color: color ?? AppColors.primaryRaised),
    SizedBox(width: Dimens.pt10),
    if (showLoading)
      Text("loading···",
          style: TextStyle(fontSize: Dimens.pt24, color: Colors.white))
  ]));
}

Widget buildPayTypeWidget(PaymentType? paymentType,
    {double? width,
    double? height,
    int? price = 0,
    double? fontSize,
    bool? isBuy,
    bool? isAds,
    bool? isChapter}) {
  ThemeManager theme = Get.find<ThemeManager>();
  // 根据不同的支付类型返回不同的Widget
  double w = width ?? Dimens.pt58;
  double h = height ?? Dimens.pt32;
  paymentType ??= PaymentType.freePaymentType;
  if (isAds ?? false) {
    return Container(
        width: w,
        height: h,
        alignment: Alignment.center,
        color: theme.getColor(ThemeColor.textGrey),
        child: Text("广告",
            style: TextStyle(
                fontSize: fontSize ?? Dimens.pt22,
                color: theme.getColor(ThemeColor.primary))));
  }
  switch (paymentType) {
    case PaymentType.freePaymentType:
      return Container(
          width: w,
          height: h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: theme.getColor(ThemeColor.spring),
              borderRadius: BorderRadius.circular(Dimens.pt12)
          ),
          child: Text("免费",
              style: TextStyle(
                  fontSize: fontSize ?? Dimens.pt22,
                  color: theme.getColor(ThemeColor.bg))));
    case PaymentType.vipPaymentType:
      return Container(
          width: w,
          height: h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.mainRed,
              borderRadius: BorderRadius.circular(Dimens.pt12)
          ),
          child: Text("VIP",
              style: TextStyle(
                  fontSize: fontSize ?? Dimens.pt22, color: Colors.white)));
    case PaymentType.coinPaymentType:
      return Container();
  }
}

Widget outlineButton({
  bool isBorder = false,
  bool isDisabled = false,
  bool isRadius = true,
  Color background = Colors.transparent, // 默认背景颜色为透明
  double width = 200.0, // 设置默认宽度为200.0逻辑像素
  double height = 50.0, // 设置默认高度为50.0逻辑像素
  required VoidCallback onPressed, // 按钮点击回调函数
  required Widget child, // 按钮内部的Widget
}) {
  return SizedBox(
    width: width,
    height: height,
    child: OutlinedButton(
      onPressed: isDisabled ? null : onPressed, // 根据isDisabled决定是否禁用按钮
      style: OutlinedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.textColore62 : background,
        // 如果按钮禁用，则使用灰色背景，否则使用传入的背景颜色
        shape: isRadius
            ? RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30), // 如果isRadius为true，则设置圆角
              )
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // 如果isRadius为false，则没有圆角
              ),
        side: isBorder
            ? BorderSide(
                color: isDisabled ? Colors.grey : Colors.white,
                width: 1.0) // 如果isBorder为true，则根据是否禁用设置边框颜色
            : BorderSide.none, // 如果isBorder为false，则没有边框
      ),
      child: child, // 使用传入的子Widget
    ),
  );
}

const TextStyle defaultTextStyle = TextStyle(
  color: Colors.black, // 默认文本颜色
  fontWeight: FontWeight.w700,
);

// strongText 函数返回一个具有默认样式的 Text widget
Widget strongText({
  required String text, // 要显示的文字
  TextStyle? style, // 可选的样式覆盖
  TextOverflow? overflow,
}) {
  // 合并 defaultTextStyle 和 style，使得外部可以覆盖默认样式
  TextStyle effectiveStyle = defaultTextStyle.merge(style);
  return Text(
    text,
    style: effectiveStyle,
    overflow: overflow ?? TextOverflow.clip, // 默认情况下使用
  );
}

class CustomCell extends StatelessWidget {
  final String? imagePath; // 添加一个用于图片路径的字段
  final String title;
  final String? title2;
  final String? copyUrl;
  final double height;
  final double imageWidth;
  final double margin;
  final double padding;
  final Color bgColor;
  final TextStyle? style;
  final String? subtitle;
  final double borderRadius;
  final BorderSide? topBorder;
  final BorderSide? rightBorder;
  final BorderSide? bottomBorder;
  final BorderSide? leftBorder;
  final VoidCallback? onTap;

  const CustomCell({
    super.key,
    this.style,
    this.height = 60.0,
    this.imageWidth = 22,
    this.imagePath,
    required this.title,
    this.title2,
    this.copyUrl,
    this.subtitle,
    this.bgColor = Colors.transparent, // 默认背景颜色为透明色
    this.margin = 0,
    this.padding = 0,
    this.borderRadius = 0,
    this.topBorder,
    this.rightBorder,
    this.bottomBorder =
        const BorderSide(width: 1.0, color: AppColors.textColore62),
    this.leftBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: margin, bottom: margin),
        child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.1),
            // 微妙的水波颜色
            highlightColor: Colors.white.withOpacity(0.05),
            // 微妙的高亮颜色
            borderRadius: BorderRadius.circular(6),
            child: Container(
                height: height,
                decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border(
                      top: topBorder ?? BorderSide.none,
                      right: rightBorder ?? BorderSide.none,
                      bottom: bottomBorder ?? BorderSide.none,
                      left: leftBorder ?? BorderSide.none,
                    )),
                child: Padding(
                    padding: EdgeInsets.only(left: padding, right: padding),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: icon + title
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (imagePath != null) ...[
                                  Image.asset(
                                    imagePath!,
                                    width: imageWidth,
                                  ),
                                  // 使用 '!' 来断言 imagePath 非 null
                                  const SizedBox(width: 8.0)
                                  // 间隔
                                ],
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: Dimens.pt160,
                                          child: strongText(
                                            text: title,
                                            style: const TextStyle(
                                                color: Color(0xFF000000)),
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                      if (title2 != null) ...[
                                        SizedBox(
                                            width: Dimens.pt160,
                                            child: strongText(
                                                text: title2!,
                                                style: const TextStyle(
                                                    color: Color(0xFF000000)),
                                                overflow:
                                                    TextOverflow.ellipsis))
                                      ]
                                    ])
                              ]),
                          // Right side: subtitle + arrow icon
                          Row(children: [
                            if (subtitle != null) ...[
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                    fontSize: 14.0,
                                    color: AppColors.textColore62),
                              ),
                              const SizedBox(width: 4.0)
                            ],
                            if (copyUrl != null) ...[
                              GestureDetector(
                                onTap: () async {
                                  final clipboardData =
                                      ClipboardData(text: "$copyUrl");
                                  await Clipboard.setData(clipboardData);

                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(SnackBar(
                                          content: Text("addText_text14".tr)));
                                },
                                child: Container(
                                    width: Dimens.pt68,
                                    height: Dimens.pt28,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white,
                                            width: Dimens.pt1),
                                        borderRadius:
                                            BorderRadius.circular(Dimens.pt45)),
                                    child: Center(
                                        child: Text('contactUs_text2'.tr,
                                            style: const TextStyle(
                                              color: Color(0xFF000000),
                                            )))),
                              ),
                            ],
                            if (copyUrl == null) ...[
                              const Icon(Icons.arrow_forward_ios,
                                  size: 16.0, color: AppColors.textColore62)
                            ]
                          ])
                        ])))));
  }
}

Widget commonAvatar({String? path, double size = 50}) {
  return ClipOval(
      child: ImageLoader.withP(
              path ??
                  "https://p3-pc.douyinpic.com/aweme/100x100/aweme-av…-legacy_f8e0000f879790dcb662.jpeg?from=2956013662",
              width: size,
              height: size)
          .load());
}

Widget centerButtonModel(String image, String title,
    {VoidCallback? onClick, Color? color}) {
  return GestureDetector(
      onTap: onClick,
      child: SizedBox(
          width: Dimens.pt40,
          height: Dimens.pt38,
          child: Column(children: [
            if (TextUtil.isNotEmpty(image))
              Image.asset(image,
                  color: color,
                  width: Dimens.pt24,
                  height: Dimens.pt24,
                  fit: BoxFit.fill),
            const Spacer(),
            Text(
              title ?? '',
              style: TextStyle(
                  fontSize: Dimens.pt10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGreyColor),
            )
          ])));
}

Widget buildCommentInputView({Function? onTap}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Container(
          width: screen.screenWidth,
          height: Dimens.pt68,
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt16),
          color: theme.getColor(ThemeColor.bgGrey),
          child: Row(children: [
            Text("我怀疑你想发评论,但是我没有证据",
                style: TextStyle(
                    fontSize: Dimens.pt22, color: const Color(0xFF505050))),
            const Spacer(),
            Image.asset(R.assetsImgIconSend,
                width: Dimens.pt68,
                color: Get.find<ThemeManager>().getColor(ThemeColor.textGrey))
          ])));
}

/// text高度套件
Widget textHeightWidget(
    {Widget? child, double? height, AlignmentGeometry? alignment}) {
  return Container(
      height: height ?? Dimens.pt25,
      alignment: alignment ?? Alignment.centerLeft,
      child: child ?? Container());
}

/// 获取水平分割线
Widget getHengLine(
    {double w = 0,
    double h = .5,
    Color? color,
    double paddingTop = 0,
    double paddingBottom = 0,
    double paddingLeft = 0,
    double paddingRight = 0}) {
  if (w <= 0) w = double.infinity;
  return Container(
      margin: EdgeInsets.only(
          top: paddingTop,
          bottom: paddingBottom,
          left: paddingLeft,
          right: paddingRight),
      height: h,
      width: w,
      color: color ?? AppColors.divideColor);
}

Widget buildTextInput(
  TextEditingController controller, {
  bool? enabled,
  double? height,
  double? radius,
  int? maxLength,
  bool? autofocus,
  Function(String)? onChanged,
  Function(String)? onSubmitted,
  Color? textColor, // 内容字体颜色
  double? fontSize, // 内容字体大小
  int? maxLines, // 最大行数
  Widget? suffixIcon, // 结尾图片
  String? hintText, // place holder
  Color? hintColor, // place holder颜色
  Color? fillColor, // 填充颜色
  Widget? prefixIcon, // 最前面的图片
  TextInputAction? textInputAction,
  TextInputType? keyboardType,
  EdgeInsetsGeometry? contentPadding,
}) {
  return TextField(
      autofocus: autofocus ?? false,
      maxLength: maxLength ?? 20,
      enabled: enabled,
      maxLines: maxLines ?? 1,
      textInputAction: textInputAction ?? TextInputAction.done,
      keyboardType: keyboardType ?? TextInputType.text,
      cursorColor: AppColors.primaryColor,
      textAlign: TextAlign.left,
      controller: controller,
      style: TextStyle(
          color: textColor ?? AppColors.primaryColor,
          fontSize: fontSize ?? Dimens.pt14),
      onChanged: (text) => onChanged?.call(text),
      onSubmitted: (text) => onSubmitted?.call(text),
      decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintText: hintText ?? '',
          counterText: '',
          contentPadding: contentPadding ?? EdgeInsets.all(Dimens.pt10),
          suffixIconConstraints: BoxConstraints(maxHeight: Dimens.pt20),
          hintStyle: TextStyle(
              color: hintColor ?? const Color(0xFFD9D9D9),
              fontSize: Dimens.pt22,
              fontWeight: FontWeight.w600),
          filled: false,
          fillColor: fillColor ?? Colors.red,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius ?? (height ?? 0) / 2),
              borderSide: const BorderSide(color: AppColors.transparent)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius ?? (height ?? 0) / 2),
              borderSide: const BorderSide(color: AppColors.transparent)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius ?? (height ?? 0) / 2),
              borderSide: const BorderSide(color: AppColors.transparent))));
}

class TimerPeriodicWidget extends StatefulWidget {
  final int timeOut;
  final Widget Function(BuildContext context, int time) builder;

  const TimerPeriodicWidget(
      {this.timeOut = 30, super.key, required this.builder});

  @override
  State<TimerPeriodicWidget> createState() => _TimerPeriodicWidgetState();
}

class _TimerPeriodicWidgetState extends State<TimerPeriodicWidget> {
  int defaultTimeOut = 30;
  late Timer timer;

  @override
  void initState() {
    defaultTimeOut = widget.timeOut;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (time) {
      if (defaultTimeOut > 0) {
        setState(() => defaultTimeOut -= 1);
      } else {
        timer.cancel();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, defaultTimeOut);
  }
}
