import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cat_client/app/model/recharge_model.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';
import 'package:quick_cat_client/app/widget/common_app_bar.dart';
import 'package:quick_cat_client/app/widget/common_widget.dart';
import 'package:quick_cat_client/conf/api_res.dart';
import 'package:quick_cat_client/plugins_utils/ImageLoader/ImageLoader.dart';
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';

class WithdrawTypeView extends StatefulWidget {
  const WithdrawTypeView({super.key});

  @override
  State<WithdrawTypeView> createState() => _WithdrawTypeViewState();
}

class _WithdrawTypeViewState extends State<WithdrawTypeView> {
  late Future<WithdrawTypeListModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiRes.getWithdrawTypeList();
  }

  void _reload() {
    setState(() {
      _future = ApiRes.getWithdrawTypeList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getCommonAppBar("提现"),
        backgroundColor: AppColors.bgColor,
        body: FutureBuilder<WithdrawTypeListModel?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: getLoadingView());
              }
              if (snapshot.hasError) {
                return Center(
                    child: TextButton(
                        onPressed: _reload,
                        child: const Text("加载失败，点击重试",
                            style: TextStyle(color: Colors.white70))));
              }
              final list = snapshot.data?.list ?? [];
              if (list.isEmpty) {
                return Center(
                    child: TextButton(
                        onPressed: _reload,
                        child: const Text("暂无提现方式，点击刷新",
                            style: TextStyle(color: Colors.white70))));
              }
              return ListView(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.symmetric(horizontal: Dimens.pt25),
                  children: list
                      .map((e) => WithdrawTypeItem(
                          icon: e.icon,
                          title: e.name,
                          path: e.path,
                          wtype: e.wtype,
                          minNum: e.minNum,
                          maxNum: e.maxNum))
                      .toList());
            }));
  }
}

class WithdrawTypeItem extends StatelessWidget {
  final String? icon;
  final String? title;
  final String? path;
  final int? wtype;
  final int? minNum;
  final int? maxNum;

  const WithdrawTypeItem(
      {super.key,
      this.icon,
      this.title,
      this.path,
      this.wtype,
      this.minNum,
      this.maxNum});

  Widget _iconWidget() {
    final ic = icon;
    if (ic == null || ic.isEmpty) {
      return SizedBox(width: Dimens.pt60, height: Dimens.pt60);
    }
    return ImageLoader.withP(ic,
            width: Dimens.pt60, height: Dimens.pt60, fit: BoxFit.contain)
        .load();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (path != null && path!.isNotEmpty) {
            Get.toNamed(path!, parameters: {
              'wtype': '${wtype ?? 0}',
              'name': title ?? '',
              'icon': icon ?? '',
              'minNum': '${minNum ?? 0}',
              'maxNum': '${maxNum ?? 0}',
            });
          }
        },
        child: Container(
            height: Dimens.pt120,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Color(0xFF606060), width: Dimens.pt1))),
            child: Row(children: [
              _iconWidget(),
              SizedBox(width: Dimens.pt20),
              Expanded(
                  child: Text(title ?? "",
                      style: TextStyle(
                          fontSize: Dimens.pt28,
                          color: Colors.white,
                          fontWeight: FontWeight.w600))),
              Image.asset(R.assetsImgIconArrowRight, width: Dimens.pt30)
            ])));
  }
}
