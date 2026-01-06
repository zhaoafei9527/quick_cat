// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/routes/app_pages.dart';
import 'package:acgn_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:acgn_client/utils/common_util.dart';
import 'package:acgn_client/utils/dimens.dart';
import '../../r.dart';
import '../../utils/time_util.dart';

class ShortVideoCover extends StatelessWidget {
  final MediaInfo? mediaInfo;
  final double? width;
  final VoidCallback? onTap;
  final bool? isPlayer;

  const ShortVideoCover(MediaInfo this.mediaInfo,
      {this.width, this.isPlayer, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          if (onTap != null) {
            onTap?.call();
          } else {
            if (mediaInfo?.isAds ?? false) {
              AppPages.jumpRouter(path: mediaInfo?.adsPath ,id:mediaInfo?.adsId);
            } else {
              Get.toNamed(Routes.SHORT_VIDEO_PLAYER,
                  arguments: {"id": "${mediaInfo?.id}"});
            }
          }
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildCover(),
          SizedBox(height: Dimens.pt10),
          Container(
            height: Dimens.pt40,
            alignment: Alignment.centerLeft,
            child: Text(mediaInfo?.title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: Dimens.pt28, color: (mediaInfo?.isAds ?? false)?const Color(0xFFFF6213):Colors.white)),
          ),
          if (!(mediaInfo?.isAds ?? false))
            Container(
              height: Dimens.pt30,
              alignment: Alignment.centerLeft,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text("收藏",
                    style: TextStyle(
                        fontSize: Dimens.pt22, color: const Color(0xFF8A8785))),
                SizedBox(width: Dimens.pt10),
                Text("${mediaInfo?.collects ?? 0}",
                    style: TextStyle(
                        fontSize: Dimens.pt22, color: const Color(0xFF8A8785))),
                const Spacer(),
                Image.asset(R.assetsImgIconCoverComment, width: Dimens.pt23),
                SizedBox(width: Dimens.pt10),
                Text("${mediaInfo?.comments ?? 0}",
                    style: TextStyle(
                        fontSize: Dimens.pt22, color: const Color(0xFF8A8785)))
              ]),
            )
          else
            Text(
                (mediaInfo?.desc ?? "").isNotEmpty
                    ? (mediaInfo?.desc ?? "")
                    : mediaInfo?.title ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Dimens.pt22, color: const Color(0xFF8A8785))),
        ]));
  }

  Widget buildCover() {
    double defaultWidth = width ?? Dimens.pt345;
    double defaultHeight = defaultWidth / 9 * 12;

    return Stack(alignment: Alignment.bottomCenter, children: [
      ImageLoader.withP(mediaInfo?.coverImg,
              height: defaultHeight, radius: Dimens.pt12, width: defaultWidth)
          .load(),
      Container(
          width: defaultWidth,
          height: Dimens.pt67,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.pt10, vertical: Dimens.pt10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Dimens.pt12),
                  bottomRight: Radius.circular(Dimens.pt12)),
              gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (!(mediaInfo?.isAds ?? false))
              Row(children: [
                Image.asset(R.assetsImgIconCoverPlay, width: Dimens.pt31),
                SizedBox(width: Dimens.pt5),
                Text(
                    getShowWatchNumberStr(mediaInfo?.watchTimes ?? 0, count: 1),
                    style:
                        TextStyle(fontSize: Dimens.pt22, color: Colors.white))
              ]),
            if (!(mediaInfo?.isAds ?? false))
              Row(children: [
                Text(TimeUtil.getHHNNSS(mediaInfo?.playTime ?? 0),
                    style:
                        TextStyle(fontSize: Dimens.pt22, color: Colors.white))
              ])
          ])),
      Positioned(
          top: 0,
          right: Dimens.pt30,
          child: (mediaInfo?.isAds ?? false)
              ? Image.asset(R.assetsImgTipCoverAds, width: Dimens.pt58)
              : Image.asset(
                  mediaInfo?.payType == 0
                      ? R.assetsImgTipCoverFree
                      : R.assetsImgTipCoverVip,
                  width: Dimens.pt58))
    ]);
  }
}
