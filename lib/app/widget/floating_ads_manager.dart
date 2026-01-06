import 'dart:math';

import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:quick_cat_client/utils/screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../r.dart';

enum FloatingAdPosition { left, right }

class FloatingAdsManager extends GetxService {
  final Map<FloatingAdPosition, OverlayEntry> _entries = {};
  final Set<FloatingAdPosition> _dismissed = {};
  bool _scheduledAttach = false;

  static FloatingAdsManager get to => Get.find<FloatingAdsManager>();

  void ensureFloatingAds(BuildContext context) {
    if (_dismissed.length == FloatingAdPosition.values.length) return;
    if (_scheduledAttach) return;
    _scheduledAttach = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _scheduledAttach = false;
      await _attachToOverlay(context);
    });
  }

  void dismiss(FloatingAdPosition side) {
    _dismissed.add(side);
    final entry = _entries.remove(side);
    entry?.remove();
    entry?.dispose();
  }

  OverlayState? _obtainOverlayState(BuildContext context) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay != null) return overlay;
    final overlayCtx = Get.overlayContext;
    if (overlayCtx != null) {
      return Overlay.maybeOf(overlayCtx, rootOverlay: true);
    }
    return null;
  }

  Future<Map<FloatingAdPosition, Advertise?>> _prepareAdsPair() async {
    final List<Advertise> adsList =
        await LocalAdsStore().where(AdsType.homeBreathingAds);
    if (adsList.isEmpty) {
      return {
        FloatingAdPosition.left: null,
        FloatingAdPosition.right: null,
      };
    }
    final shuffled = [...adsList]..shuffle(Random());
    final leftAd = shuffled.first;
    final rightAd = shuffled.length > 1 ? shuffled[1] : shuffled.first;
    if (shuffled.length > 1) {
      log.i("FloatingAdsManager", "左右浮窗广告随机选择: ${leftAd.id}, ${rightAd.id}");
    } else {
      log.i("FloatingAdsManager", "仅有一个呼吸灯广告，左右共用: ${leftAd.id}");
    }
    return {
      FloatingAdPosition.left: leftAd,
      FloatingAdPosition.right: rightAd,
    };
  }

  Future<void> _attachToOverlay(BuildContext context) async {
    final overlayState = _obtainOverlayState(context);
    if (overlayState == null) {
      ensureFloatingAds(context);
      return;
    }
    final adsPair = await _prepareAdsPair();
    for (final side in FloatingAdPosition.values) {
      if (_dismissed.contains(side) || _entries.containsKey(side)) continue;
      final ad = adsPair[side];
      if (ad == null) continue;
      final entry = OverlayEntry(
          builder: (_) => FloatingAdBubble(
              side: side, advertise: ad, onClose: () => dismiss(side)));
      _entries[side] = entry;
      overlayState.insert(entry);
    }
  }
}

class FloatingAdBubble extends StatefulWidget {
  final FloatingAdPosition side;
  final VoidCallback onClose;
  final Advertise advertise;

  const FloatingAdBubble(
      {super.key,
      required this.side,
      required this.advertise,
      required this.onClose});

  @override
  State<FloatingAdBubble> createState() => _FloatingAdBubbleState();
}

class _FloatingAdBubbleState extends State<FloatingAdBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: .9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRight = widget.side == FloatingAdPosition.right;
    return Positioned(
        left: isRight ? null : Dimens.pt25,
        right: isRight ? Dimens.pt25 : null,
        top: (screen.screenHeight / 2) + Dimens.pt100,
        child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(alignment: Alignment.topRight, children: [
              GestureDetector(
                onTap: () => AppPages.jumpRouter(
                    path: widget.advertise.href, id: widget.advertise.id),
                child: ImageLoader.withP(widget.advertise.cover,
                        width: Dimens.pt150,
                        height: Dimens.pt150,
                        radius: Dimens.pt12)
                    .load(),
              ),
              Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: GestureDetector(
                      onTap: widget.onClose,
                      child: Image.asset(R.assetsImgIconAdsClose,
                          width: Dimens.pt40, height: Dimens.pt40)))
            ])));
  }
}
