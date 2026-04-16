// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:quick_cat_client/conf/api_res.dart';

// import 'package:fvp/fvp.dart' as fvp;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart' as path_provider;

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/fijk_player.dart';
import 'package:quick_cat_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import 'package:quick_cat_client/utils/isolate_manager.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/light_model.dart';
import 'app/data/common_binding.dart';
import 'app/data/pubspec.dart';
import 'app/modules/home/home_game_page/controllers/game_web_view_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/theme.dart';
import 'firebase_options.dart';
import 'generated/locales.g.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final playerManager = FIJKPlayerManager();
    final cacheManager = M3u8CacheManager();
    switch (state) {
      case AppLifecycleState.resumed:
        // 重新获取用户信息
        unawaited(ApiRes.getUpdateUserInfo());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(playerManager.pauseForAppLifecycle());
        cacheManager.pauseAll();
        // 后台时、重新调用退出游戏接口，确保游戏状态正确
        if (Get.isRegistered<GameWebViewPageController>()) {
          final game = Get.find<GameWebViewPageController>();
          unawaited(game.exitGame());
        }
        break;
      case AppLifecycleState.detached:
        unawaited(playerManager.disposeForAppExit());
        cacheManager.stopAll();
        unawaited(cacheManager.stopProxy());
        if (Get.isRegistered<GameWebViewPageController>()) {
          final game = Get.find<GameWebViewPageController>();
          unawaited(game.exitGame());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> main() async {
  // 确保 Flutter 环境初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化路径提供器
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();

  // 确保路径提供器初始化完成后再初始化 Hive
  await LightModel.init(appDocumentDir.path);

  // 先初始化 Firebase（确保插件使用到的 Context 正确）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 使用 runZonedGuarded 捕获 zone 内的所有异常
  runZonedGuarded(() async {
    // 设置全局错误页面（例如 widget 渲染异常时）
    ErrorWidget.builder = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      Zone.current.handleUncaughtError(details.exception, details.stack!);
      return Container(color: Colors.transparent);
    };

    // 设置 FlutterError 处理器
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
      log.e("ERROR", '${details.exception}');
    };

    // 设置平台错误处理（Android、iOS 层面的异常）
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint("PlatformDispatcher error: $error");
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // 设置web中重定向路由
    if (kIsWeb) {
      String href = html.window.location.href;
      List<String> path = href.split("#");
      if (path.isNotEmpty && path.length > 1) {
        String currentRoute = path[1];
        if (currentRoute != Routes.SPLASH_PAGE) {
          html.window.location.href = "${path[0]}#${Routes.SPLASH_PAGE}";
        }
      }
    }
    // // 视频优化 启用硬件解码器，支持 Dolby Vision
    // if (GetPlatform.isAndroid) {
    //   fvp.registerWith(options: {
    //     'platforms': ['android'], // 限制为 Android
    //     'fastSeek': true, // 启用快速定位
    //     'player': {
    //       'avio.reconnect': '1', // 启用网络重连
    //       'avio.reconnect_delay_max': '5', // 最大重连延迟 5 秒
    //       'buffer': '1000+500000', // 初始 1KB，最大 500KB 缓冲
    //       'demux.buffer.ranges': '4', // 缓冲范围
    //     }
    //   });
    // }
    FijkLog.setLevel(FijkLogLevel.Silent);
    // 预热 Isolate
    await IsolateManager().start();

    // 配置 EasyLoading（可自定义相关样式）
    setEasyLoadingOption();

    // 固定竖屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 启动应用
    runApp(
      AppLifecycleHandler(
        child: GetMaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: AppPages.INITIAL,
          initialBinding: CommonBinding(),
          getPages: AppPages.routes,
          theme: AppTheme.dark,
          builder: EasyLoading.init(),
          showPerformanceOverlay: false,
          debugShowCheckedModeBanner: Pubspec.debug,
          defaultTransition: Transition.cupertino,
          translationsKeys: AppTranslation.translations,
          locale: const Locale('zh', 'CN'),
          fallbackLocale: const Locale('zh', 'TW'),
        ),
      ),
    );
  }, (error, stack) {
    String currentRoute = Get.currentRoute;
    log.e("ERROR", 'Unhandled error on route $currentRoute: $error',
        stackTrace: stack, saveFile: true);
    log.writeCrash(error, stackTrace: stack);
  });
}

void setEasyLoadingOption() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..backgroundColor = AppColors.divideColor
    ..progressColor = AppColors.primaryColor
    ..indicatorColor = AppColors.primaryColor
    ..textColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}
