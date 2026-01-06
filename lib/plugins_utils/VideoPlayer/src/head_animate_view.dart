// 🐦 Flutter imports:
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/ads_type.dart';
import 'package:acgn_client/app/model/home/config_model_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';

class HeadAnimateView extends StatefulWidget {
  const HeadAnimateView({super.key});

  @override
  State<HeadAnimateView> createState() => _HeadAnimateViewState();
}

class _HeadAnimateViewState extends State<HeadAnimateView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller1;
  late Advertise? advertise;
  bool isGameAds = true;
  bool adsInit = false;

  @override
  void initState() {
    super.initState();
    initAdsInfo();
    // 外圈
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _controller.repeat();

    // 图片
    _controller1 = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _controller1.forward();
    _controller1.addStatusListener((status) {
      if (mounted) {
        if (status == AnimationStatus.completed) {
          // 动画正向完成后，反向播放
          _controller1.reverse();
        } else if (status == AnimationStatus.dismissed) {
          // 动画反向回到起点后，继续正向播放
          _controller1.forward();
        }
      }
    });
  }

  initAdsInfo() async {
    advertise = await LocalAdsStore().randomWhere(AdsType.shortVideoAvatarAds);
    isGameAds = (advertise?.href ?? "").startsWith("game://");
    adsInit = true;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return adsInit
        ? GestureDetector(
            onTap: () {
              if (advertise != null) {
                AppPages.jumpRouter(path: advertise?.href, id: advertise?.id);
              }
            },
            child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                      height: Dimens.pt140,
                      width: Dimens.pt140,
                      color: Colors.transparent),
                  AnimatedBuilder(
                      animation: _controller,
                      builder: (context, __) {
                        return Container(
                            width: Tween(begin: Dimens.pt100, end: Dimens.pt130)
                                .evaluate(_controller),
                            height:
                                Tween(begin: Dimens.pt100, end: Dimens.pt130)
                                    .evaluate(_controller),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Tween(
                                        begin: Dimens.pt120, end: Dimens.pt130)
                                    .evaluate(_controller)),
                                border: Border.all(
                                    color: AppColors.textYellowColor,
                                    width: Tween(begin: 1.5, end: .2)
                                        .evaluate(_controller))));
                      }),
                  Container(
                      width: Dimens.pt100,
                      height: Dimens.pt100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimens.pt100),
                          border: Border.all(
                              color: AppColors.textYellowColor, width: 1.0))),
                  AnimatedBuilder(
                      animation: _controller1,
                      builder: (context, __) {
                        var a = Tween(begin: Dimens.pt95, end: Dimens.pt85)
                            .evaluate(_controller1);
                        return ImageLoader.withP(advertise?.cover ?? "",
                                width: a, height: a, radius: a)
                            .load();
                      }),
                  Positioned(
                      top: -Dimens.pt40,
                      child: Image.asset(
                          isGameAds
                              ? R.assetsImgTipShortHeadGame
                              : R.assetsImgTipShortHeadLine,
                          width: isGameAds ? Dimens.pt137 : Dimens.pt80))
                ]))
        : const SizedBox();
  }
}
