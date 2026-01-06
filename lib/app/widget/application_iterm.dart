// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:

// 🌎 Project imports:
import 'package:quick_cat_client/app/model/home/topic_list_model.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import '../../utils/brower_util.dart';

class ApplicationIterm extends StatelessWidget {
  final AppTopicInfo? mediaInfo;
  final VoidCallback? onTap;

  const ApplicationIterm(AppTopicInfo this.mediaInfo, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => openBrowser(mediaInfo?.link ?? ''),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ImageLoader.withP(mediaInfo?.cover,
                  radius: Dimens.pt20,
                  fit: BoxFit.fitHeight,
                  height: Dimens.pt80,
                  width: Dimens.pt80)
              .load(),
          SizedBox(height: Dimens.pt7),
          SizedBox(
            width: Dimens.pt80,
            child: Text(mediaInfo?.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: Dimens.pt14,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          )
        ]));
  }
}
