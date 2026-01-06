// 🐦 Flutter imports:
import 'package:acgn_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:

// 🌎 Project imports:
import 'package:acgn_client/r.dart';
import 'package:acgn_client/utils/dimens.dart';
import 'package:get/get.dart';
import '../../../themes/app_colors.dart';

class SearchBarView extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool? enabled;
  final VoidCallback? onBack;

  const SearchBarView(
      {super.key,
      this.controller,
      this.onSubmitted,
      this.enabled,
      this.onBack,
      this.onChanged});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchBarView> {
  var inputText = '';

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return Column(children: [
      Row(children: [
        GestureDetector(
            onTap: () => widget.onBack?.call(),
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: Dimens.pt0),
                child: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: Dimens.pt42))),
        SizedBox(width: Dimens.pt15),
        Expanded(
            child: Stack(children: [
          Container(
              height: Dimens.pt64,
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.circular(Dimens.pt30),
              )),
          Container(
              height: Dimens.pt64,
              alignment: Alignment.center,
              child: Row(children: [
                SizedBox(width: Dimens.pt32),
                Image.asset(R.assetsImgIconSearchEs, width: Dimens.pt35),
                Expanded(
                    child: TextField(
                        enabled: widget.enabled ?? true,
                        maxLength: 20,
                        maxLines: 1,
                        minLines: 1,
                        controller: widget.controller,
                        textInputAction: TextInputAction.search,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white, fontSize: Dimens.pt28),
                        onChanged: (text) {
                          inputText = text;
                          widget.onChanged?.call(text);
                        },
                        onSubmitted: (text) {
                          if (widget.onSubmitted == null) return;
                          widget.onSubmitted?.call(text);
                        },
                        decoration: InputDecoration(
                            hoverColor: const Color(0xFF6A6A6A),
                            suffixIconConstraints:
                                BoxConstraints(maxHeight: Dimens.pt22),
                            hintText: "输入关键字搜索更多内容",
                            counterText: '',
                            hintStyle: TextStyle(
                                color: Color(0xFFA3A3A7),
                                fontSize: Dimens.pt24),
                            contentPadding: EdgeInsets.only(left: Dimens.pt8),
                            filled: true,
                            fillColor: Colors.transparent,
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17.5),
                                borderSide: const BorderSide(
                                    color: Colors.transparent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17.5),
                                borderSide: const BorderSide(
                                    color: Colors.transparent)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(17.5),
                                borderSide: const BorderSide(
                                    color: Colors.transparent)))))
              ]))
        ])),
        SizedBox(width: Dimens.pt15),
        GestureDetector(
            onTap: () =>
                widget.onSubmitted?.call(widget.controller?.text ?? ""),
            child: SizedBox(
                height: Dimens.pt39,
                child: Text("搜索",
                    style:
                        TextStyle(color: Colors.white, fontSize: Dimens.pt32))))
      ])
    ]);
  }
}
