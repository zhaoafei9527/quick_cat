// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/logger_utils.dart';
import '../../conf/api_res.dart';
import '../../plugins_utils/HttpRequester/http_requester.dart';
import '../../r.dart';
import '../../utils/dimens.dart';
import '../../utils/screen.dart';
import '../model/home/topic_list_model.dart';
import '../themes/app_colors.dart';

class BuildTopicChanger extends StatefulWidget {
  final List<MediaInfo> mediaList;
  final int? id;
  final Widget Function(List<MediaInfo> m) changeWidgetBuilder;

  const BuildTopicChanger(this.mediaList,
      {super.key, this.id, required this.changeWidgetBuilder});

  @override
  State<BuildTopicChanger> createState() => _BuildTopicChangerState();
}

class _BuildTopicChangerState extends State<BuildTopicChanger> {
  List<MediaInfo> list = <MediaInfo>[];

  List<MediaInfo> get mediaList => widget.mediaList;

  Widget Function(List<MediaInfo> m) get changeWidgetBuilder =>
      widget.changeWidgetBuilder;

  @override
  void initState() {
    list = mediaList;
    super.initState();
  }

  void changeMediaList() async {
    int id = widget.id ?? 0;
    var response = await post<TopicList, TopicList>(ApiRes.changeTopic,
        decodeType: TopicList(), data: {"id": id});

    response.when(success: (TopicList? model) async {
      setState(() => list = model?.list ?? []);
    }, failure: (String msg, int code) {
      log.e("topic_changer", '切换失败: $msg');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      changeWidgetBuilder.call(list),
      SizedBox(height: Dimens.pt12),
      Container(
          width: screen.screenWidth,
          height: Dimens.pt42,
          padding: EdgeInsets.symmetric(horizontal: Dimens.pt56),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimens.pt21),
              color: const Color(0xFF404040),
              border: Border.all(color: Colors.black, width: Dimens.pt1 / 2)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () => changeMediaList(),
              child: Row(children: [
                Image.asset(R.assetsImgIconChange,
                    width: Dimens.pt12, color: AppColors.primaryRaised),
                SizedBox(width: Dimens.pt5),
                Text("addText_text13".tr,
                    style: TextStyle(
                        fontSize: Dimens.pt12, color: AppColors.primaryRaised))
              ]),
            ),
            Container(
                width: Dimens.pt1,
                height: Dimens.pt15,
                color: AppColors.primaryRaised),
            Text("addText_text15".tr,
                style: TextStyle(
                    fontSize: Dimens.pt12, color: AppColors.primaryRaised))
          ]))
    ]);
  }
}
