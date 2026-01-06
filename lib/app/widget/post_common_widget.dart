// 🐦 Flutter imports:
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/model/post_list_model.dart';
import 'package:acgn_client/app/themes/app_colors.dart';
import 'package:acgn_client/conf/api_res.dart';
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/common_util.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:get/get.dart';

Widget buildEmojiIconView(
    {String? emoji,
    Function(bool, int)? onTap,
    bool isTapEd = false,
    int number = 0}) {
  ThemeManager theme = Get.find<ThemeManager>();
  return StatefulBuilder(builder: (context, setState) {
    return GestureDetector(
        onTap: () {
          isTapEd = !isTapEd;
          setState(() => number = isTapEd ? number + 1 : number - 1);
          onTap?.call(isTapEd, number);
        },
        child: Container(
            margin: EdgeInsets.only(right: Dimens.pt12),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
                horizontal: Dimens.pt24, vertical: Dimens.pt11),
            decoration: BoxDecoration(
              color: theme
                  .getColor(isTapEd ? ThemeColor.textYellow : ThemeColor.bgGrey)
                  .withOpacity(.5),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(emoji ?? "", width: Dimens.pt36),
              SizedBox(width: Dimens.pt10),
              Text(getShowWatchNumberStr(number),
                  style: TextStyle(
                      fontSize: Dimens.pt22,
                      color: theme
                          .getColor(isTapEd ? ThemeColor.textYellow : ThemeColor.primary)))
            ])));
  });
}

Widget buildPostEmojiView(PostBase? base) {
  EmojiInfoModel? emoji = base?.realEmoji;
  bool requesting = false;
  Future<void> tapTap(bool? status, type) async {
    if (!requesting) {
      requesting = true;
      await ApiRes.addCollect(
          type: type,
          collectType: MediaType.post,
          objectId: base?.id,
          flag: status);
      requesting = false;
    }
  }

  return Row(children: [
    buildEmojiIconView(
        emoji: R.assetsImgIconPostEmoji1,
        isTapEd: emoji?.isFlushedFace ?? false,
        number: emoji?.flushedFace ?? 0,
        onTap: (bool status, int number) {
          emoji?.isFlushedFace = status;
          emoji?.flushedFace = number;
          tapTap(status, ActionType.TypeFlushedFace);
        }),
    buildEmojiIconView(
        emoji: R.assetsImgIconPostEmoji2,
        isTapEd: emoji?.isTearsJoy ?? false,
        number: emoji?.tearsJoy ?? 0,
        onTap: (bool status, int number) {
          emoji?.isTearsJoy = status;
          emoji?.tearsJoy = number;
          tapTap(status, ActionType.TypeTearsJoy);
        }),
    buildEmojiIconView(
        emoji: R.assetsImgIconPostEmoji3,
        isTapEd: emoji?.isFury ?? false,
        number: emoji?.fury ?? 0,
        onTap: (bool status, int number) {
          emoji?.isFury = status;
          emoji?.fury = number;
          tapTap(status, ActionType.TypeFury);
        }),
    buildEmojiIconView(
        emoji: R.assetsImgIconPostEmoji4,
        isTapEd: emoji?.isLike ?? false,
        number: emoji?.like ?? 0,
        onTap: (bool status, int number) {
          emoji?.isLike = status;
          emoji?.like = number;
          tapTap(status, ActionType.TypeLikes);
        }),
    buildEmojiIconView(
        emoji: R.assetsImgIconPostEmoji5,
        isTapEd: emoji?.isJoker ?? false,
        number: emoji?.joker ?? 0,
        onTap: (bool status, int number) {
          emoji?.isJoker = status;
          emoji?.joker = number;
          tapTap(status, ActionType.TypeJoker);
        }),
  ]);
}
