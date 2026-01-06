// 📦 Package imports:
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import 'package:acgn_client/utils/text_util.dart';

/// 时间工具类
class TimeUtil {
  ///获取年月日时分
  static String buildYYMMDDHHNN(String timeStr, {String sp = '-'}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(const Duration(hours: 8));
    }
    return formatDate(date, [yyyy, sp, mm, sp, dd, " ", HH, ":", nn]);
  }

  ///获取月日时分
  static String buildMMDDHHNN(String timeStr, {String sp = '/'}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(const Duration(hours: 8));
    }
    return formatDate(date, [mm, sp, dd, " ", HH, ":", nn]);
  }

  ///年月日时间格式 sp'-' 分隔符
  static String buildYYMMDD(String timeStr,
      {bool showYear = true, String sp = '-'}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(const Duration(hours: 8));
    }
    return formatDate(date, [
      if (showYear) ...[yyyy, sp],
      mm,
      sp,
      dd
    ]);
  }

  ///年月日时间格式 sp'年-月-日' 分隔符
  static String buildYYMMDDToNormal(String timeStr, {bool showYear = true}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(Duration(hours: 8));
    }
    return formatDate(date, [
      if (showYear) ...[yyyy, '年'],
      mm,
      '月',
      dd,
      '日'
    ]);
  }

  ///年月日时间格式 sp'.' 分隔符
  static String buildYYMMDDPunctuate(String timeStr,
      {bool showYear = true, String sp = '/'}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(Duration(hours: 8));
    }
    return formatDate(date, [
      if (showYear) ...[yyyy, sp],
      mm,
      sp,
      dd
    ]);
  }

  ///年月日时间格式 sp'/' 分隔符
  static String buildYYMMDDPunctuate2(String timeStr,
      {bool showYear = true, String sp = '/', String sd = ' '}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(Duration(hours: 8));
    }
    return formatDate(date, [
      mm,
      sd,
      sp,
      sd,
      dd,
      sd,
      // if (showYear) ...[sp],
      // if (showYear) ...[sd],
      // if (showYear) ...[yyyy],
    ]);
  }

  /// 年月日时间格式(中文分割符)
  /// [buildYYMMDD]的相似函数 [sp] 是`年月日`
  static String buildChineseYYMMDD(String timeStr, {bool showYear = true}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(Duration(hours: 8));
    }
    return formatDate(date, [
      if (showYear) ...[yyyy, "年"],
      mm,
      "月",
      dd,
      "日"
    ]);
  }

  ///比较两时间是否是同一天
  static bool isSameDay(String time1, String time2) {
    if (TextUtil.isEmpty(time1) || TextUtil.isEmpty(time2)) {
      return true;
    }
    var date1 = DateTime.parse(time1 ?? '');
    if (date1.isUtc) {
      date1 = date1.add(Duration(hours: 8));
    }
    var date2 = DateTime.parse(time2 ?? '');
    if (date2.isUtc) {
      date2 = date2.add(Duration(hours: 8));
    }
    return date1.difference(date2).inDays == 0;
  }

  ///时间格式 时分秒
  static String buildHHNNSS(String timeStr, {String sp = ':'}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(Duration(hours: 8));
    }
    return formatDate(date, [HH, sp, nn, sp, ss]);
  }

  static String formatTimeOfSeconds(int seconds, {String format = "HH:mm:ss"}) {
    Duration duration = Duration(seconds: seconds);
    DateTime dateTime = DateTime(0).add(duration);
    return DateFormat(format).format(dateTime);
  }

  ///时间格式 时分
  static String buildHHNN(String timeStr, {String sp = ':'}) {
    if (TextUtil.isEmpty(timeStr)) {
      return '';
    }
    var date = DateTime.parse(timeStr ?? '');
    if (date.isUtc) {
      date = date.add(Duration(hours: 8));
    }
    return formatDate(date, [HH, sp, nn]);
  }

  ///刚刚，多少分钟前，多少小时前，一天前，两天前，三天前
  static String showDateBefore(String time) {
    if (TextUtil.isEmpty(time)) return "刚刚";
    var curSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    var oldSeconds = DateTime.parse(time).millisecondsSinceEpoch / 1000;
    var diff = curSeconds - oldSeconds;
    if (diff < 60) return "刚刚";
    if (diff < 3600) return '${diff ~/ 60}分钟前';
    if (diff < 86400) return '${diff ~/ 3600}小时前';
    if (diff < 86400 * 7) return '${diff ~/ 86400}天前';
    if (diff < 86400 * 28) return '${diff ~/ (86400 * 7)}周前';
    return '1月前';
  }

  static int showDateAfter(String time) {
    int day = 0;
    var curSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    var newSeconds = DateTime.parse(time).millisecondsSinceEpoch / 1000;
    var diff = newSeconds - curSeconds;
    day = (diff / 60 / 60 / 24) ~/ 1;
    if (day == 0) day = 1;
    return day;
  }

  // 获取不含天数的小时
  static String getTotalHH(int seconds) {
    var hour = seconds ~/ 3600;
    return _formatTime(hour);
  }

  /// 获取时间(天)
  static String getDD(int seconds) => _formatTime(seconds ~/ 86400);

  /// 获取时间(时)
  static String getHH(int seconds) {
    var hour = seconds ~/ 3600;
    return _formatTime(hour % 24);
  }

  /// 获取时间(分)
  static String getNN(int seconds) {
    var minutes = seconds ~/ 60;
    return _formatTime(minutes % 60);
  }

  /// 获取时间(秒)
  static String getSS(int seconds) {
    var ss = seconds % 60;
    return _formatTime(ss);
  }

  /// 构建时分秒`00:00:00`
  static String getHHNNSS(int seconds, {String sp = ':'}) {
    seconds = seconds ?? 0;
    if (seconds == null && seconds == 0) {
      return "00:00:00";
    }
    int hour = seconds ~/ 3600;
    int minute = (seconds ~/ 60) % 60;
    int second = seconds % 60;
    return _formatTime(hour) +
        sp +
        _formatTime(minute) +
        sp +
        _formatTime(second);
  }

  /// 构建分秒`00:00`
  static String getNNSS(int seconds, {String sp = ':'}) {
    int minute = seconds ~/ 60;
    int second = seconds % 60;
    return _formatTime(minute) + sp + _formatTime(second);
  }

  /// 对数字进行补零操作
  /// 数字格式化，将 0~9 的时间转换为 00~09
  static String _formatTime(int timeNum) {
    return timeNum < 10 ? "0$timeNum" : timeNum.toString();
  }

  /// 金额 分转元 11000 = 110.00
  static String amountConversion(int amount) {
    var minutes = (amount / 100).toStringAsFixed(2);
    return minutes;
  }

  /// 支付类型
  static String paymentType(String type) {
    if (type == 'alipay') {
      return "支付宝";
    } else if (type == 'qq') {
      return "QQ钱包";
    } else if (type == 'wxpay') {
      return "微信";
    } else if (type == 'ecny') {
      return "数字人民币";
    } else if (type == 'unionpay') {
      return "银行卡";
    } else if (type == 'usdt') {
      return "USDT";
    }
    return "";
  }

  /// 提现状态类型
  static String withdrawalStatusType(int type) {
    if (type == 0) {
      return "未知";
    } else if (type == 1) {
      return "提现中";
    } else if (type == 2) {
      return "提现成功";
    } else if (type == 3) {
      return "提现失败";
    } else if (type == 4) {
      return "提现拒绝";
    } else if (type == 5) {
      return "重新上分处理中";
    }
    return "";
  }

  /// 充值状态类型
  static String topUpStatusType(int type) {
    if (type == 0) {
      return "未知";
    } else if (type == 1) {
      return "未知";
    } else if (type == 2) {
      return "充值中";
    } else if (type == 3) {
      return "充值成功";
    } else if (type == 4) {
      return "充值失败";
    } else if (type == 5) {
      return "未知";
    }
    return "";
  }

  /// 支付类型
  static String tranType(int type) {
    if (type == 56) {
      return "充值";
    } else if (type == 57) {
      return "充值赠送";
    } else if (type == 58) {
      return "转运金";
    } else if (type == 59) {
      return "流水返利";
    } else if (type == 60) {
      return "会员红包";
    } else if (type == 61) {
      return "排行榜";
    } else if (type == 62) {
      return "注册";
    } else if (type == 63) {
      return "抽奖";
    } else if (type == 64) {
      return "提现";
    } else if (type == 65) {
      return "提现成功";
    } else if (type == 66) {
      return "提现失败";
    } else if (type == 67) {
      return "提现成功";
    } else if (type == 68) {
      return "提现失败";
    } else if (type == 69) {
      return "首存";
    } else if (type == 70) {
      return "人工";
    } else if (type == 71) {
      return "绑定手机";
    } else if (type == 72) {
      return "福利中心";
    }
    return "";
  }
}
