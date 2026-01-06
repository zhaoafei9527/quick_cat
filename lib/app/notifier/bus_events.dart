// 🎯 Dart imports:
import 'dart:async';

EventBus eventBus = EventBus();

class EventsBusKey {
  static String homeVideoPause = "bus_home_video_pause";
  static String subUpdateUserInfo = "bus_update_user_info";
  static String subUpdateVpnInfo = "bus_update_vpn_info";
}

class BusType {
  final String name;
  final Map<String, dynamic>? arguments;

  BusType(this.name, {this.arguments});
}

class EventBus {
  final StreamController _streamController;

  StreamController get streamController => _streamController;

  EventBus({bool sync = false})
      : _streamController = StreamController.broadcast(sync: sync);

  EventBus.customController(StreamController controller)
      : _streamController = controller;

  Stream? on(String name) {
    Stream? controller;
    if ((name ?? "").isNotEmpty) {
      controller =
          streamController.stream.where((event) => event.name == name).cast();
    }

    return controller;
  }

  void emit(BusType event) {
    streamController.add(event);
  }

  void destroy() {
    _streamController.close();
  }
}
