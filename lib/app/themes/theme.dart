// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:acgn_client/utils/dimens.dart';
import 'app_colors.dart';

// ignore: avoid_classes_with_only_static_members
class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(secondary: Colors.black),
    disabledColor: Colors.grey.shade400,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: AppColors.primaryColor,
    splashColor: AppColors.primaryColor,
    highlightColor: AppColors.primaryColor,
    textTheme: TextTheme(
      displayLarge: TextStyle(
          fontSize: Dimens.pt16,
          fontWeight: FontWeight.bold,
          color: Colors.white),
      displayMedium: TextStyle(fontSize: Dimens.pt14, color: Colors.white),
      displaySmall: TextStyle(fontSize: Dimens.pt12, color: Colors.white),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryColor, // 光标颜色
      selectionColor: AppColors.primaryColor.withOpacity(0.5), // 选择文本的颜色
      selectionHandleColor: AppColors.primaryColor, // 选择手柄的颜色
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(scrolledUnderElevation: 0.0),
    colorScheme: const ColorScheme.dark(secondary: Colors.grey),
    disabledColor: Colors.grey.shade400,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
