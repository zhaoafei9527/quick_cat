// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../plugins_utils/ImageLoader/ImageLoader.dart';
import '../../utils/dimens.dart';
import '../model/home/topic_list_model.dart';
import '../routes/app_pages.dart';
import '../themes/app_colors.dart';

class RecommendIterm extends StatelessWidget {
  final MediaInfo? mediaInfo;
  final int index;
  final double? containerH;
  final double? maxWidth;
  final double? height;
  final VoidCallback? onTap;
  final bool isShowRankColor;

  const RecommendIterm(this.mediaInfo,
      {super.key,
      this.index = 0,
      this.containerH,
      this.maxWidth,
      this.height,
      this.onTap,
      this.isShowRankColor = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          Get.toNamed(Routes.MINI_DRAMA_PLAYER_PAGE,
              parameters: {"id": "${mediaInfo?.id}"});
        },
        child: SizedBox(
            height: Dimens.pt96,
            child: Row(children: [
              Stack(alignment: Alignment.bottomLeft, children: [
                ImageLoader.withP(mediaInfo?.coverImg,
                        radius: Dimens.pt4, width: Dimens.pt72)
                    .load(),
                Visibility(
                    visible: false,
                    child: Positioned(
                        top: Dimens.pt2,
                        right: Dimens.pt2,
                        child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.springColor,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(Dimens.pt2))),
                            width: Dimens.pt13,
                            height: Dimens.pt8,
                            alignment: Alignment.center,
                            child: Text('18+',
                                style: TextStyle(
                                    fontSize: Dimens.pt4,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700))))),
                Positioned(
                    left: Dimens.pt4,
                    bottom: Dimens.pt0,
                    child: Text((index.toString()),
                        style: TextStyle(
                            fontSize: Dimens.pt11,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w900)))
              ]),
              SizedBox(width: Dimens.pt12),
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(mediaInfo?.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: Dimens.pt11,
                            color: Colors.white,
                            height: 1.5,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: Dimens.pt2),
                  ]))
            ])));
  }
}
