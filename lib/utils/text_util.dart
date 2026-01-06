import 'package:get/get.dart';

/// 文本处理工具类
class TextUtil {
  ///特殊字符验证
  static bool isSpecialChar(String str) {
    if (str.isEmpty) return false;
    return RegExp(
            r"[_`~!@#$%^&*()+=|{}':;',\[\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]|\n|\r|\t|\s")
        .hasMatch(str);
  }

  ///手机号验证
  static bool isChinaPhoneLegal(String str) {
    if (str.isEmpty) return false;
    return RegExp(r"^1[3-9]\d{9}$").hasMatch(str);
  }

  ///短信验证码验证
  static bool isSMSCode(String str) {
    if (str.isEmpty) return false;
    return RegExp(r"^\d{6}$").hasMatch(str);
  }

  ///字符串截断
  static String truncate(String value, int remain) {
    if (value.isEmpty) return '';
    return ((value ?? '').length >= remain)
        ? ('${value.substring(0, remain)}...')
        : value ?? '';
  }

  static bool isEmpty(String text) {
    return (text.isEmpty);
  }

  static bool isNotEmpty(String text) {
    return (text.isNotEmpty);
  }

  ///验证手机号11位
  static bool isPhone(String str) {
    if (TextUtil.isEmpty(str)) {
      return false;
    }
    RegExp exp = RegExp(r'^1\d{10}$');
    return exp.hasMatch(str);
  }

  ///邮箱验证
  static bool isEmail(String str) {
    if (TextUtil.isEmpty(str)) {
      return false;
    }
    return RegExp(r"^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$")
        .hasMatch(str);
  }

  static bool isNumeric(String str) {
    if (str.isEmpty) return false;
    try {
      double.parse(str);
      return true;
    } on FormatException {
      return false;
    }
  }

  static bool isChinese(String str) {
    RegExp reg = RegExp(r"[\u4e00-\u9fa5]+");
    return reg.hasMatch(str);
  }

  static int getIntArgument(key) {
    int argument = 0;
    if (Get.arguments != null && Get.arguments[key] != null) {
      var read = Get.arguments?[key];
      if (read.runtimeType == int) {
        argument = read;
      } else if (read.runtimeType == String) {
        argument = int.tryParse(read) ?? 0;
      }
    }
    return argument;
  }
}
