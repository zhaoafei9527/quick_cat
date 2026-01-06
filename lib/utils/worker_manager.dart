// 📦 Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workmanager/workmanager.dart';

const String heartbeatTask = "heartbeatTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case heartbeatTask:
        // 执行网络检测
        var connectivityResult = await (Connectivity().checkConnectivity());
        bool isConnected = connectivityResult != ConnectivityResult.none;
        // 返回 true 表示任务完成
        return Future.value(true);
      default:
        return Future.value(false);
    }
  });
}
