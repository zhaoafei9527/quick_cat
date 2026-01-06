// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/ads_type.dart';
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/home/config_model_model.dart';
import 'package:quick_cat_client/app/routes/app_pages.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/screen.dart';
import '../../utils/dimens.dart';
import '../model/home/topic_list_model.dart';
import '../views/comment_refresh_view.dart';

Future showCommentsDialog(BuildContext context, int postId,
    {int comments = 0,
    MediaInfo? mediaInfo,
    int? authorId,
    CommentType? type,
    VoidCallback? onComment}) {
  bool isFullScreen = false;
  bool getAdsAlready = false;
  int newComments = comments;
  ThemeManager theme = Get.find<ThemeManager>();
  return showModalBottomSheet(
      context: context,
      isDismissible: true,
      useSafeArea: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => FutureBuilder(
          future: getCommentAds(),
          builder: (context, snapshot) {
            Advertise? ads = snapshot.data;

            return StatefulBuilder(
                builder: (c1, setState) => AnimatedContainer(
                    duration: Durations.medium2,
                    height: isFullScreen
                        ? screen.screenHeight
                        : screen.screenHeight / 2,
                    color: theme.getColor(ThemeColor.bg),
                    padding: EdgeInsets.all(Dimens.pt25),
                    child: Column(children: [
                      Text("$newComments条评论",
                          style: TextStyle(
                              fontSize: Dimens.pt22,
                              color: theme.getColor(ThemeColor.primary))),
                      Expanded(
                          child: CommentRefreshView(
                              postId: postId,
                              comments: comments,
                              onComment: onComment,
                              showTitle: true,
                              type: type ?? CommentType.CT_Video,
                              onLoadCommentCount: (int? count) {
                                // setState(() => newComments = count ?? 0);
                              },
                              authorId: authorId)),
                      SizedBox(height: screen.paddingBottom)
                    ])));
          }));
}



/// Get flashlight status
Future<Advertise?> getCommentAds({AdsType? type}) async {
  try {
    Advertise? ad =
        await LocalAdsStore().randomWhere(type ?? AdsType.commentsAds);
    return ad;
  } on PlatformException catch (e) {
    throw Exception(e.code);
  }
}
