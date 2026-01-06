import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:acgn_client/utils/logger_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

class MarqueeNotification {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 15), // 停留15秒
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // 创建动画控制器，时长为600ms（用于入场和退出动画）
    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 600),
    );

    // 入场动画：从右侧滑入
    final enterAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.bounceOut,
    ));

    // 退出动画：向左侧滑出
    final exitAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    ));

    // 控制当前是入场还是退出状态
    bool isEntering = true;

    // 创建OverlayEntry
    overlayEntry = OverlayEntry(
        builder: (context) => AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              List<String> text = message.split("^");
              return SlideTransition(
                  position: isEntering ? enterAnimation : exitAnimation,
                  child: SafeArea(
                      child: Align(
                          alignment: Alignment.topCenter,
                          child: GestureDetector(
                              onTap: () async {
                                if (text[1].isNotEmpty) {
                                  try{
                                    AppPages.jumpRouter(path: text[1]);
                                    // 切换到退出动画
                                    isEntering = false;
                                    // 重置并运行退出动画
                                    animationController.reset();
                                    animationController.forward().then((_) {
                                      // 退出动画完成后移除OverlayEntry并释放资源
                                      overlayEntry.remove();
                                      overlayEntry.dispose();
                                      // overlay.dispose();
                                      animationController.dispose();
                                    });
                                    FirebaseUtils.firebaseLogEvent(
                                      eventName: "FireworkNotification",
                                      routePath: Get.currentRoute,
                                    );
                                  }catch(e){
                                    log.i("_FireworkNotification","FireworkNotification:$e");
                                  }
                                }
                              },
                              child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Image.asset(R.assetsImgBgNotification,
                                        width: Dimens.pt650),
                                    Container(
                                        width: Dimens.pt650,
                                        height: Dimens.pt40,
                                        margin: EdgeInsets.only(
                                            bottom: Dimens.pt50),
                                        padding: EdgeInsets.only(
                                            left: Dimens.pt30,
                                            right: Dimens.pt140),
                                        child: Marquee(
                                            blankSpace: 20,
                                            velocity: 100,
                                            text: "${text[0]}${text[2]}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: Dimens.pt28)))
                                  ])))));
            }));

    // 插入OverlayEntry
    overlay.insert(overlayEntry);

    // 动画流程
    animationController.forward().then((_) {
      // 入场动画完成后，等待指定的持续时间（15秒）
      Future.delayed(duration, () {
        // 切换到退出动画
        isEntering = false;
        // 重置并运行退出动画
        animationController.reset();
        animationController.forward().then((_) {
          // 退出动画完成后移除OverlayEntry并释放资源
          overlayEntry.remove();
          overlayEntry.dispose();
          // overlay.dispose();
          animationController.dispose();
        });
      });
    });
  }
}
