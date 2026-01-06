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
import '../themes/app_colors.dart';

class SearchVideoCover extends StatelessWidget {
  final MediaInfo? mediaInfo;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool? isPlayer;

  const SearchVideoCover(MediaInfo this.mediaInfo,
      {this.width, this.height, this.isPlayer, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          Get.toNamed(Routes.MINI_DRAMA_PLAYER_PAGE,
              parameters: {"id": "${mediaInfo?.id}"});
          // 如果在播放器内跳转 重新处理堆栈
          // if(result) Get.offNamed(Routes.VIDEO_PLAYER_PAGE);
        },
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          buildCover(),
          SizedBox(width: Dimens.pt15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Icon(Icons.remove_red_eye,
                      size: Dimens.pt22, color: Colors.white),
                  SizedBox(width: Dimens.pt5),
                  Text(
                      getShowWatchNumberStr(mediaInfo?.watchTimes ?? 0,
                          count: 1),
                      style:
                          TextStyle(fontSize: Dimens.pt14, color: Colors.white))
                ]),
                SizedBox(height: Dimens.pt3),
                Text(mediaInfo?.title ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: Dimens.pt15,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: Dimens.pt10),
                // Text(
                //     (mediaInfo?.coverType ?? []).isNotEmpty
                //         ? mediaInfo?.genres![0] ?? ""
                //         : "影片类型",
                //     style: TextStyle(
                //         fontSize: Dimens.pt14,
                //         color: AppColors.textColore62,
                //         fontWeight: FontWeight.w700)),
                SizedBox(height: Dimens.pt10),
                Text(mediaInfo?.desc ?? "暂无影片简介",
                    style: TextStyle(
                        fontSize: Dimens.pt14,
                        color: AppColors.textColore62,
                        fontWeight: FontWeight.w700))
              ]))
        ]));
  }

  Widget buildCover() {
    double defaultWidth = width ?? Dimens.pt125;
    double height = (defaultWidth / 3) * 4;

    return Stack(alignment: Alignment.center, children: [
      Stack(alignment: Alignment.center, children: [
        ImageLoader.withP(
          mediaInfo?.coverImg,
          radius: Dimens.pt3,
          fit: BoxFit.cover,
          width: defaultWidth,
          height: height,
        ).load(),
      ])
    ]);
  }
}
