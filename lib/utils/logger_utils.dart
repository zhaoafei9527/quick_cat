library;

// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:date_format/date_format.dart' as fmt;
import 'package:logger/logger.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/misc_util.dart';

// global log class
final log = _Log._();

/// 日志工具类，
class _Log {
  // // 获取文档目录的路径
  IOSink? fileSink;
  IOSink? crashSink;
  String? logPath;

  bool enablePrintLog = true;

  /// 全局控制，是否允许打印log

  /// 允许写日志文件
  bool enableWriteFile = true;

  Future initLogFile() async {
    // Directory appDocDir = await getExternalStorageDirectory();

    // if (Platform.isIOS || Platform.isMacOS) {
    //   dir = await getTemporaryDirectory();
    // } else {
    //   dir = await getExternalStorageDirectory();
    // }
    if (kIsWeb) return;
    // enablePrintLog = Config.DEBUG;
    var dir = await MiscUtil.getCommonDir();

    ///判斷是 Release or debug
    enablePrintLog = !kReleaseMode;
    // enablePrintLog = true;
    var path = dir?.path;
    var dataStr =
        fmt.formatDate(DateTime.now(), [fmt.yyyy, "_", fmt.mm, "_", fmt.dd]);
    final logFile = File('$path/log_$dataStr.txt');
    debugPrint(
        'begin logger print:$enablePrintLog write:$enableWriteFile savePath:${logFile.path}');
    fileSink = logFile.openWrite(mode: FileMode.append);
    final crashFile = File('$path/log_crash_$dataStr.txt');
    logPath = '$path/log_$dataStr.txt';
    crashSink = crashFile.openWrite(mode: FileMode.append);
  }

  var printer = MyPrinter();

  _Log._() {
    _logger = Logger(
      filter: ProductionFilter(),
      output: LimitedLogOutput(maxLines: 1),
      printer: SimplePrinter(colors: true),
    );
    initLogFile();
    Logger.level = Level.verbose;
  }

  Logger? _logger;

  Future<String> readLogFile() async {
    String log = "";

    return log;
  }

  void v(String tag, dynamic message,
      {dynamic error, StackTrace? stackTrace, bool saveFile = false}) {
    if (enablePrintLog) {
      _logger?.v('$tag#: $message', error: error, stackTrace: stackTrace);
    }
    if (enableWriteFile && saveFile && !kIsWeb) {
      var newMsg = printer.stringifyMessage('$tag#: $message');
      fileSink?.write('$newMsg\n');
    }
  }

  void d(String tag, dynamic message,
      {dynamic error, StackTrace? stackTrace, bool saveFile = false}) {
    if (enablePrintLog) {
      _logger?.d('$tag#: $message', error: error, stackTrace: stackTrace);
    }
    if (enableWriteFile && saveFile && !kIsWeb) {
      var newMsg = printer.stringifyMessage('$tag#: $message');
      fileSink?.write('$newMsg\n');
    }
  }

  void i(String tag, dynamic message,
      {dynamic error, StackTrace? stackTrace, bool saveFile = true}) {
    if (enablePrintLog) {
      _logger?.i('$tag#: $message', error: error, stackTrace: stackTrace);
    }
    if (enableWriteFile && saveFile && !kIsWeb) {
      var newMsg = printer.stringifyMessage('$tag#: $message');
      fileSink?.write('$newMsg\n');
    }
  }

  void w(String tag, dynamic message,
      {dynamic error, StackTrace? stackTrace, bool saveFile = true}) {
    if (enablePrintLog) {
      _logger?.w('$tag#: $message', error: error, stackTrace: stackTrace);
    }
    if (enableWriteFile && saveFile && !kIsWeb) {
      var newMsg = printer.stringifyMessage('$tag#: $message');
      fileSink?.write('$newMsg\n');
    }
  }

  void e(String tag, dynamic message,
      {dynamic error, StackTrace? stackTrace, bool saveFile = true}) {
    // if (enablePrintLog) _logger.w('$tag#: $message', error, stackTrace);
    if (true) {
      _logger?.e('$tag#: $message', error: error, stackTrace: stackTrace);
    }
    // if (enableWriteFile && saveFile && null != fileSink) {
    if (saveFile && !kIsWeb) {
      var newMsg = printer.stringifyMessage('$tag#: $message');
      fileSink?.write('$newMsg\n');
    }
  }

  void writeCrash(dynamic message, {dynamic error, StackTrace? stackTrace}) {
    if (!kIsWeb) {
      var newMsg = printer.stringifyMessage(message);
      fileSink?.write('$newMsg\n');
      crashSink?.write('$newMsg\n error:$error\n stack:$stackTrace\n');
    }
  }

  void wtf(dynamic message,
      {dynamic error, StackTrace? stackTrace, bool saveFile = true}) {
    _logger?.wtf(message, error: error, stackTrace: stackTrace);
    if (saveFile && !kIsWeb) {
      var newMsg = printer.stringifyMessage(message);
      fileSink?.write('$newMsg\n');
    }
  }
}

class MyPrinter extends SimplePrinter {
  // @override
  // void log(LogEvent event) {
  //   var messageStr = stringifyMessage(event.message);
  //   var errorStr = event.error != null ? "  ERROR: ${event.error}" : "";
  //   println("${levelPrefixes[event.level]}  $messageStr$errorStr");
  // }
  MyPrinter() : super(printTime: true);

  String stringifyMessage(dynamic msg) {
    // if (msg is Map || msg is Iterable) {
    //   return JsonEncoder.withIndent(null).convert(msg);
    // } else {
    // return (_getTime() + msg.toString());
    return msg.toString();
    // }
  }

  String _getTime() {
    var now = DateTime.now();
    var h = _twoDigits(now.hour);
    var min = _twoDigits(now.minute);
    var sec = _twoDigits(now.second);
    var ms = _threeDigits(now.millisecond);

    return "[$h:$min:$sec.$ms] ";
  }

  String _threeDigits(int n) {
    if (n >= 100) return "$n";
    if (n >= 10) return "0$n";
    return "00$n";
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}

class LimitedLogOutput extends LogOutput {
  final int maxLines;
  final List<String> _logBuffer = [];

  LimitedLogOutput({this.maxLines = 4});

  @override
  void output(OutputEvent event) {
    // 添加新的日志行
    for (var line in event.lines) {
      // 移除 ANSI 颜色代码
      String cleanLine = line.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');
      _logBuffer.add(cleanLine);
    }

    // 如果超出最大行数，移除最旧的日志
    while (_logBuffer.length > maxLines) {
      _logBuffer.removeAt(0);
    }

    // 输出当前最新一条日志
    if (kDebugMode) {
      if (_logBuffer.isNotEmpty) {
        print(_logBuffer.last);
      } else {
        print("No logs available.");
      }
    }
    // 输出当前缓冲区中的所有日志
    // for (var line in _logBuffer) {
    //   if (kDebugMode) {
    //     print(line);
    //   }
    // }
  }
}
