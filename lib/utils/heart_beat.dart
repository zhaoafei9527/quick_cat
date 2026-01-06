// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/logger_utils.dart';

void main() {
  // 创建 Heartbeat 实例并启动
  Heartbeat heartbeat = Heartbeat();
  heartbeat.start();

  // 为了示例，运行 2 分钟后停止心跳检测
  Timer(Duration(minutes: 2), () {
    heartbeat.stop();
    print('Heartbeat stopped.');
  });
}

class Heartbeat {
  Timer? _timer;

  void start({int? time, Function? beatFunc}) {
    _timer = Timer.periodic(Duration(seconds: time ?? 30), (Timer timer) async {
      try {
        log.i("Heartbeat_start", 'Heartbeat at ${DateTime.now()}');
        await beatFunc?.call();
        log.i("Heartbeat_start", 'Heartbeat completed at ${DateTime.now()}');
      } catch (e) {
        log.i("Heartbeat_start", 'Heartbeat error: $e');
      }
    });
  }

  // 停止心跳检测
  void stop() {
    _timer?.cancel();
  }

  // 心跳检测逻辑
  Future<void> performHeartbeat() async {}
}
