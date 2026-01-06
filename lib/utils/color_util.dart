// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/text_util.dart';

class ColorUtil {
  // 字符串转颜色
  static Color strToColor(String str, [Color defColor = Colors.black]) {
    if (TextUtil.isEmpty(str)) return defColor;
    str = str.replaceAll('#', '');
    str = str.replaceAll('0x', '');
    str = str.replaceAll('0X', '');
    if (str.length < 8) {
      str = 'FF$str';
    }
    var color = Color(int.tryParse(str, radix: 16) ?? defColor.value);
    return color;
  }
}
