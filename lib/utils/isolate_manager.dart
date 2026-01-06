// 🎯 Dart imports:
import 'dart:async';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/ImageLoader/src/decrypt_image.dart';

class IsolateManager {
  // 单例
  static final IsolateManager _instance = IsolateManager._internal();

  factory IsolateManager() => _instance;

  IsolateManager._internal();

  Isolate? _isolate;
  SendPort? _sendPort; // 用于给 Isolate 发消息
  final _responsePort = ReceivePort(); // 用于接收 Isolate 返回
  final _taskQueue = <Map<String, dynamic>>[]; // 任务队列
  bool _isProcessing = false; // 是否正在处理任务
  final _completers = <String, Completer>{};
  int _taskId = 0;

  bool get isReady => _sendPort != null;

  // 启动并预热 Isolate
  Future<void> start() async {
    if (kIsWeb) return;
    // 若已启动就不再重复
    if (_isolate != null) return;

    // 创建 Isolate 前，先监听本地接收端
    _responsePort.listen(_handleMessageFromIsolate);

    // spawn时，我们会把 _responsePort.sendPort 作为新 Isolate 的入口参数
    _isolate = await Isolate.spawn(
      _isolateEntry, // 新 Isolate 执行的方法
      _responsePort.sendPort, // 传给新 Isolate 的参数
    );

    // 等待 Isolate 初始化成功，会在 _handleMessageFromIsolate 中设置 _sendPort
    while (_sendPort == null) {
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  // 停止 Isolate（可选，若不需要可以不实现）
  Future<void> stop() async {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
  }

  // 发送任务到 Isolate 并等待结果
  Future<dynamic> sendRequest(Map<String, dynamic> request) {
    final completer = Completer();
    final taskId = _taskId++;
    _completers[taskId.toString()] = completer;

    // 将任务添加到队列
    _taskQueue.add({
      'id': taskId,
      'data': request,
    });

    // 如果没有正在处理的任务，开始处理
    if (!_isProcessing) {
      _processNextTask();
    }

    return completer.future;
  }

  // 处理下一个任务
  Future<void> _processNextTask() async {
    if (_taskQueue.isEmpty) {
      _isProcessing = false;
      return;
    }

    _isProcessing = true;
    final task = _taskQueue.removeAt(0);
    final taskId = task['id'];
    final data = task['data'];

    // 发送任务到 Isolate
    _sendPort?.send({
      'id': taskId,
      'data': data,
    });
  }

  // 处理从 Isolate 发回的消息
  void _handleMessageFromIsolate(dynamic message) {
    if (message is SendPort && _sendPort == null) {
      // 第一次消息通常是 Isolate 把它的 sendPort 发给我们
      _sendPort = message;
    } else if (message is Map) {
      final taskId = message['id'].toString();
      final result = message['result'];
      final completer = _completers.remove(taskId);

      if (completer != null) {
        completer.complete(result);
      }

      // 处理下一个任务
      _processNextTask();
    }
  }

  // >>>> 新 Isolate 中运行的入口函数 <<<<
  static void _isolateEntry(SendPort mainSendPort) {
    // 1. 先创建一个专用 ReceivePort，用来收主 Isolate 的任务
    final isolateReceivePort = ReceivePort();

    // 2. 把它的 sendPort 发送给主 Isolate，主 Isolate 就能给我们发任务了
    mainSendPort.send(isolateReceivePort.sendPort);

    // 3. 监听任务
    isolateReceivePort.listen((message) async {
      if (message is Map) {
        final taskId = message['id'];
        final data = message['data'] as Map<String, dynamic>;

        // 根据 data["action"] 或别的字段判断要执行什么逻辑
        final result = await _doTask(data);

        // 任务完成后发回结果
        mainSendPort.send({
          'id': taskId,
          'result': result,
        });
      }
    });
  }

  // 处理具体逻辑的函数（在 Isolate 中执行）
  static Future<dynamic> _doTask(Map<String, dynamic> data) async {
    // 这里你可以执行 CPU 密集型操作或耗时任务
    // 可以返回任意可序列化的数据
    return await decryptImage(data);
  }
}