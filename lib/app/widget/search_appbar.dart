// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/dimens.dart';
import '../../r.dart';
import '../../utils/screen.dart';
import '../themes/app_colors.dart';

// ignore_for_file: import_of_legacy_library_into_null_safe

///搜索appBar
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final VoidCallback? onCancel;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool disable;
  final bool hideBack;
  final bool showLogo;
  final Color? bgColor;
  final Color? fillColor;
  final String? hintText;
  final bool showPaddingTop;
  final Widget? actions;
  final double searchHeight;
  final double? radius;

  // enable 为false是点击文本输入区域回调
  final VoidCallback? onDisableClick;

  const SearchAppBar(
      {super.key,
      this.controller,
      this.onSubmitted,
      this.disable = false,
      this.onChanged,
      this.bgColor,
      this.fillColor,
      this.hintText,
      this.hideBack = false,
      this.showLogo = false,
      this.onBack,
      this.onCancel,
      this.actions,
      this.onDisableClick,
      this.searchHeight = 38,
      this.showPaddingTop = true,
      this.radius});

  @override
  _SearchAppBarState createState() => _SearchAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(searchHeight + Dimens.pt8 + Dimens.pt10);
}

class _SearchAppBarState extends State<SearchAppBar> {
  var inputText = '';
  bool isClear = false;

  @override
  void initState() {
    super.initState();
    inputText = widget.controller?.text ?? '';
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.clear();
  }

  Widget _getInput() {
    return Container(
        height: widget.searchHeight,
        alignment: Alignment.center,
        child: TextField(
            autofocus: false,
            maxLength: 20,
            enabled: !widget.disable,
            textInputAction: TextInputAction.search,
            cursorColor: AppColors.textColorb4,
            textAlign: TextAlign.left,
            controller: widget.controller,
            style: TextStyle(
                color: AppColors.textColorWhite,
                fontSize: Dimens.pt12,
                fontWeight: FontWeight.w600),
            onChanged: (text) {
              inputText = text;
              widget.onChanged?.call(text);
              setState(() => isClear = text.isNotEmpty);
            },
            onSubmitted: (text) {
              if (widget.onSubmitted == null) return;
              widget.onSubmitted!(text);
            },
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.pt13),
                child: Image.asset(R.assetsImgIconSearch, width: Dimens.pt10),
              ),
              suffixIcon: widget.actions ?? const SizedBox(),
              hintText: widget.hintText ?? '',
              counterText: '',
              suffixIconConstraints: BoxConstraints(maxHeight: Dimens.pt20),
              hintStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: Dimens.pt14,
                  fontWeight: FontWeight.w400),
              contentPadding: EdgeInsets.only(left: Dimens.pt16),
              filled: true,
              fillColor: widget.fillColor ?? AppColors.shadowGrey,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      widget.radius ?? widget.searchHeight / 2),
                  borderSide: const BorderSide(color: AppColors.transparent)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      widget.radius ?? widget.searchHeight / 2),
                  borderSide: const BorderSide(color: AppColors.transparent)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      widget.radius ?? widget.searchHeight / 2),
                  borderSide: const BorderSide(color: AppColors.transparent)),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: widget.bgColor ?? AppColors.appBarColor,
        margin: EdgeInsets.only(top: Dimens.pt10 + screen.paddingTop),
        padding:
            EdgeInsets.symmetric(vertical: Dimens.pt5, horizontal: Dimens.pt10),
        height: (widget.searchHeight),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          GestureDetector(
              onTap: () {
                if (widget.onBack == null) {
                  Get.back();
                } else {
                  widget.onBack?.call();
                }
              },
              child: Container(
                  margin: EdgeInsets.only(right: Dimens.pt18),
                  child: Icon(Icons.arrow_back_ios_rounded,
                      size: Dimens.pt16, color: Colors.white))),
          Expanded(
              child: widget.disable
                  ? GestureDetector(
                      onTap: widget.onDisableClick, child: _getInput())
                  : _getInput()),
        ]));
  }
}
