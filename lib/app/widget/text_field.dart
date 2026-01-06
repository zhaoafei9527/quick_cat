// 🐦 Flutter imports:
import 'package:quick_cat_client/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/utils/dimens.dart';
import 'package:get/get.dart';

class GetCommonTextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool? enabled;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final TextInputType? inputType;

  const GetCommonTextField(
      {super.key,
      this.controller,
      this.onSubmitted,
      this.enabled,
      this.maxLength,
      this.maxLines,
      this.minLines,
      this.focusNode,
      this.hintText,
      this.hintStyle,
      this.inputType,
      this.textStyle,
      this.onChanged});

  @override
  State<GetCommonTextField> createState() => _GetCommonTextFieldState();
}

class _GetCommonTextFieldState extends State<GetCommonTextField> {
  var inputText = '';

  @override
  Widget build(BuildContext context) {
    ThemeManager theme = Get.find<ThemeManager>();
    return TextField(
        focusNode: widget.focusNode,
        maxLength: widget.maxLength ?? 20,
        maxLines: widget.maxLines ?? 1,
        minLines: widget.minLines ?? 1,
        controller: widget.controller,
        keyboardType: widget.inputType ?? TextInputType.text,
        textInputAction: TextInputAction.done,
        textAlign: TextAlign.left,
        style: widget.textStyle ??
            TextStyle(color: Colors.white, fontSize: Dimens.pt28),
        onChanged: (text) {
          inputText = text;
          widget.onChanged?.call(text);
        },
        onSubmitted: (text) {
          if (widget.onSubmitted == null) return;
          widget.onSubmitted?.call(text);
        },
        decoration: InputDecoration(
            hoverColor: theme.getColor(ThemeColor.primary),
            suffixIconConstraints: BoxConstraints(maxHeight: Dimens.pt28),
            hintText: widget.hintText ?? "",
            counterText: '',
            hintStyle: widget.hintStyle ??
                TextStyle(
                    color: const Color(0xFF6A6A6A), fontSize: Dimens.pt28),
            contentPadding: EdgeInsets.only(left: Dimens.pt8),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.5),
                borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.5),
                borderSide: const BorderSide(color: Colors.transparent)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.5),
                borderSide: const BorderSide(color: Colors.transparent))));
  }
}
