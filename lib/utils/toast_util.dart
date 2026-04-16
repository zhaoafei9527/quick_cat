// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/r.dart';
import '../app/data/enum.dart';
import 'dimens.dart';
import 'text_util.dart';

/// 显示统一的toast 无context
Future<bool?> showToast(
    {@required String? msg,
    Toast toastLength = Toast.LENGTH_LONG,
    ToastGravity gravity = ToastGravity.CENTER}) {
  if (TextUtil.isEmpty(msg ?? "")) return Future.value(false);
  return Fluttertoast.showToast(
      textColor: Colors.white,
      backgroundColor: const Color(0xFF333333).withOpacity(.9),
      msg: msg ?? "",
      fontSize: Dimens.pt28,
      gravity: gravity,
      webPosition: "center",
      toastLength: toastLength);
}

Future showTypeToast(
    {required String msg, ToastType toastType = ToastType.Error}) {
  final context = Get.overlayContext ?? Get.context;
  if (context == null) return Future.value();

  _typeToastTimer?.cancel();
  _typeToastEntry?.remove();

  final completer = Completer<void>();
  final overlay = Overlay.of(context, rootOverlay: true);

  final entry = OverlayEntry(
      builder: (_) => IgnorePointer(
          child: Material(
              type: MaterialType.transparency,
              child: Center(
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimens.pt40, vertical: Dimens.pt20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.8),
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dimens.pt16)),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Image.asset(
                          toastType == ToastType.SUCCESS
                              ? R.assetsImgIconSuccess
                              : R.assetsImgIconError,
                          color: toastType == ToastType.SUCCESS
                              ? AppColors.mainRed
                              : AppColors.textColorWhite,
                          width: Dimens.pt50,
                          height: Dimens.pt50,
                        ),
                        SizedBox(height: Dimens.pt15),
                        Text(msg,
                            style: TextStyle(
                              fontSize: Dimens.pt26,
                              color: toastType == ToastType.SUCCESS
                                  ? Colors.white
                                  : AppColors.textYellowColor,
                            ))
                      ]))))));

  _typeToastEntry = entry;
  overlay.insert(entry);
  _typeToastTimer = Timer(const Duration(seconds: 2), () {
    _typeToastEntry?.remove();
    _typeToastEntry = null;
    _typeToastTimer = null;
    if (!completer.isCompleted) {
      completer.complete();
    }
  });

  return completer.future;
}

OverlayEntry? _typeToastEntry;
Timer? _typeToastTimer;
