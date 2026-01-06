// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:photo_view/photo_view.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import '../../utils/dimens.dart';
import '../../utils/screen.dart';
import '../themes/app_colors.dart';

Future showImageViewerDialog(BuildContext context,
    {List<String>? images, bool? showNum = true}) {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
      overlays: SystemUiOverlay.values);
  int actionIndex = 0;
  return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: AppColors.bgColor,
      builder: (context) {
        return Dialog(
            backgroundColor: AppColors.bgColor,
            insetPadding: EdgeInsets.symmetric(horizontal: Dimens.pt15),
            child: Container(
              width: screen.screenWidth,
              height: screen.screenHeight / 1.4,
              color: AppColors.bgColor,
              padding: EdgeInsets.symmetric(
                  vertical: Dimens.pt15, horizontal: Dimens.pt20),
              child: StatefulBuilder(builder: (c1, setState) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if ((showNum ?? false) && (images?.length ?? 0) > 0)
                        Text("${actionIndex + 1}/${images?.length ?? 0}",
                            style: TextStyle(
                                fontSize: Dimens.pt24,
                                color: const Color(0xFFFDF6F2))),
                      Expanded(
                          child: PageView.builder(
                              scrollDirection: Axis.horizontal,
                              onPageChanged: (index) =>
                                  setState(() => actionIndex = index),
                              itemBuilder: (c, index) {
                                return PhotoView(
                                    backgroundDecoration: const BoxDecoration(
                                        color: AppColors.bgColor),
                                    imageProvider:
                                        ImageLoader.withP(images?[index])
                                            .loadMemory());
                              },
                              itemCount: images?.length ?? 0))
                    ]);
              }),
            ));
      });
}
