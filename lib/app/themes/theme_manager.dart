import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

enum ThemeModes {
  dark, // 深色主题
  light, // 浅色主题
}

// 颜色键枚举
enum ThemeColor {
  bg, // 背景色
  appBar, // 导航栏色
  navBg, // 底栏背景
  primary, // 主色调
  textGrey, // 灰色文字
  textBlack, // 黑色文字
  textYellow, // 黄色文字
  bgGrey, // 灰色背景
  raised, // 按钮色
  filter, // 过滤器色
  spring, // 春天色
  red, // 红色
  shadow, // 阴影色
  slider, // 滑块色
  divide, // 分隔线色
}

// 调用 // 在任何地方都可以这样切换主题
// ThemeManager.to.switchTheme(1); // 切换到第二个主题

class ThemeManager extends GetxController {
  static ThemeManager get to => Get.find();

  // 当前主题索引
  final _currentThemeIndex = 0.obs;

  int get currentThemeIndex => _currentThemeIndex.value;

  // 主题颜色列表
  final List<Map<ThemeColor, Color>> _themes = [
    {
      ThemeColor.bg: AppColors.bgColor,
      ThemeColor.appBar: AppColors.appBarColor,
      ThemeColor.navBg: AppColors.navBgColor,
      ThemeColor.primary: AppColors.primaryColor,
      ThemeColor.textGrey: AppColors.textGreyColor,
      ThemeColor.textBlack: AppColors.textBlackColor,
      ThemeColor.textYellow: AppColors.textYellowColor,
      ThemeColor.bgGrey: AppColors.bgGreyColor,
      ThemeColor.raised: AppColors.primaryRaised,
      ThemeColor.filter: AppColors.filterColor,
      ThemeColor.spring: AppColors.springColor,
      ThemeColor.red: AppColors.mainRed,
      ThemeColor.shadow: AppColors.shadowGrey,
      ThemeColor.slider: AppColors.sliderActive,
      ThemeColor.divide: AppColors.divideColor,
    },
    {
      ThemeColor.bg: AppColors.bgColor1,
      ThemeColor.appBar: AppColors.appBarColor1,
      ThemeColor.navBg: AppColors.appBarColor1,
      ThemeColor.primary: AppColors.primaryColor1,
      ThemeColor.textGrey: AppColors.textGreyColor1,
      ThemeColor.textBlack: AppColors.textColorWhite,
      ThemeColor.bgGrey: AppColors.bgGreyColor1,
      ThemeColor.textYellow: AppColors.textYellowColor1,
      ThemeColor.raised: AppColors.primaryRaised1,
      ThemeColor.filter: AppColors.filterColor1,
      ThemeColor.spring: AppColors.springColor1,
      ThemeColor.red: AppColors.mainRed1,
      ThemeColor.shadow: AppColors.shadowGrey1,
      ThemeColor.slider: AppColors.sliderActive1,
      ThemeColor.divide: AppColors.divideColor,
    },
  ];

  // 获取当前主题颜色
  Map<ThemeColor, Color> get currentTheme => _themes[_currentThemeIndex.value];

  ThemeModes get getCurrentTheme {
    // 返回当前主题的颜色键
    return ThemeModes.values[_currentThemeIndex.value];
  }

  // 切换主题
  void switchTheme(int index) {
    if (index >= 0 && index < _themes.length) {
      _currentThemeIndex.value = index;
    }
  }

  // 获取指定主题的颜色
  Color getColor(ThemeColor colorKey) {
    return currentTheme[colorKey] ?? Colors.transparent;
  }

  // 获取带透明度的颜色
  Color getColorWithOpacity(ThemeColor colorKey, double opacity) {
    return getColor(colorKey).withOpacity(opacity);
  }

  // 获取渐变色
  LinearGradient getGradient(ThemeColor colorKey, {double opacity = 1.0}) {
    return LinearGradient(
      colors: [
        getColor(colorKey).withOpacity(opacity),
        getColor(colorKey).withOpacity(opacity * 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
