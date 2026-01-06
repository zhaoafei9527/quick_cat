// 🐦 Flutter imports:
import 'package:acgn_client/app/model/envelope_model.dart';
import 'package:acgn_client/app/model/home/topic_list_model.dart';
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:acgn_client/app/widget/comic_topic_builder.dart';
import 'package:acgn_client/utils/time_util.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:acgn_client/app/data/enum.dart';
import 'package:acgn_client/app/views/page_pull_view.dart';
import 'package:acgn_client/app/widget/common_app_bar.dart';
import 'package:acgn_client/conf/api_res.dart';
import '../../../../utils/dimens.dart';
import '../../../widget/common_widget.dart';
import '../controllers/bill_record_controller.dart';

class BillRecordListView extends GetView<BillRecordController> {
  const BillRecordListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return GetX<BillRecordController>(builder: (BillRecordController logic) {
      return Scaffold(
          backgroundColor: theme.getColor(ThemeColor.bg),
          appBar: getCommonAppBar("流水记录"),
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
              // child: PagePullView<EnvelopeModel>(
              //     dataGetter: (int pageNum, int size) async {
              //       BillRecordDetailModel? model =
              //           await ApiRes.getBuyHistoryRecord(pageNum: pageNum);
              //       return model?.list ?? [];
              //     },
              //     emptyView: buildCommonEmptyView("宝贝,没有找到东西哦～"),
              //     widgetBuilder: (BuildContext context, List<dynamic> list,
              //         Widget? child) {
              //       return _buildListView(list.cast<EnvelopeModel>());
              //     })
          ));
    });
  }

  Widget _buildListView(List<EnvelopeModel> list) {
    ThemeManager theme = Get.find<ThemeManager>();
    return ListView.separated(
        itemBuilder: (context, index) {
          int price = (list[index].money ?? 0) ~/ 100;
          return Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text("订单编号：${list[index].id}",
                          style: TextStyle(
                              fontSize: Dimens.pt28,
                              color: theme.getColor(ThemeColor.primary))),
                      SizedBox(width: Dimens.pt25),
                      Text("复制",
                          style: TextStyle(
                              fontSize: Dimens.pt26,
                              color: theme.getColor(ThemeColor.textYellow)))
                    ]),
                    Text(TimeUtil.buildYYMMDDHHNN(list[index].createdAt ?? ""),
                        style: TextStyle(
                            fontSize: Dimens.pt22,
                            color: theme.getColor(ThemeColor.textGrey))),
                    SizedBox(height: Dimens.pt10),
                    Text(list[index].desc ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: Dimens.pt28,
                            color: theme.getColor(ThemeColor.primary))),
                  ]),
            ),
            SizedBox(width: Dimens.pt30),
            Text("-$price",
                style: TextStyle(
                    fontSize: Dimens.pt32,
                    fontWeight: FontWeight.w600,
                    color: theme.getColor(ThemeColor.textYellow)))
          ]);
        },
        separatorBuilder: (context, index) => getHengLine(
            paddingBottom: Dimens.pt25,
            paddingTop: Dimens.pt25,
            h: Dimens.pt2,
            color: theme.getColor(ThemeColor.bgGrey)),
        itemCount: list.length);
  }
}
