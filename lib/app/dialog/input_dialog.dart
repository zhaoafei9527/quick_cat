// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/r.dart';
import 'package:quick_cat_client/utils/dimens.dart';
import '../../utils/screen.dart';
import '../widget/text_field.dart';

class InputDialog {
  static Future<InputWidget?> show(
    BuildContext? context,
    String? prefix,
    String? initText,

  ) async {
    return Navigator.of(context!)
        .push(InputOverlay(prefix: prefix ?? "", initText: initText ?? ""));
  }
}

class InputOverlay extends ModalRoute<InputWidget> {
  final String? prefix;
  final String? initText;

  @override
  Duration get transitionDuration => Durations.medium2;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => const Color(0x01000000);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  InputOverlay({this.prefix, this.initText});

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return InputWidget();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }
}

class InputWidget extends StatefulWidget {
  String? prifix;
  String? text;
  bool? send;
  double? horizontal = Dimens.pt30;

  InputWidget({this.text, this.send, this.prifix, this.horizontal, super.key});

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  FocusNode focusNode = FocusNode();
  TextEditingController textField = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);

    return Scaffold(
        backgroundColor: Colors.black.withOpacity(.3),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontal ?? Dimens.pt25),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
                child: GestureDetector(
                    onTapDown: (_) {
                      var text = textField.text.trim() ?? "";
                      InputWidget inputState =
                          InputWidget(text: text, send: false);
                      Navigator.pop(context, inputState);
                    },
                    child: Container(color: Colors.transparent))),
            SafeArea(
                child: Container(
                    width: screen.screenWidth,
                    height: Dimens.pt68,
                    margin: EdgeInsets.only(bottom: Dimens.pt25),
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimens.pt30, vertical: Dimens.pt10),
                    decoration: BoxDecoration(
                        color: const Color(0xFF262637),
                        borderRadius: BorderRadius.circular(Dimens.pt8)),
                    child: Row(children: [
                      Expanded(
                          child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: Dimens.pt30),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF5F5F8B),
                                      width: Dimens.pt1),
                                  borderRadius:
                                      BorderRadius.circular(Dimens.pt45)),
                              child: GetCommonTextField(
                                  focusNode: focusNode,
                                  controller: textField,
                                  maxLength: 20,
                                  hintStyle: TextStyle(
                                      fontSize: Dimens.pt22,
                                      color: Color(0xFF787979)),
                                  textStyle: TextStyle(
                                      fontSize: Dimens.pt22,
                                      color: Colors.white),
                                  hintText: "只有VIP才可以发表评论哦!",
                                  onSubmitted: (String text) {
                                    var text = textField.text.trim();
                                    InputWidget inputState =
                                        InputWidget(text: text, send: true);
                                    Navigator.pop(context, inputState);
                                  }))),
                      SizedBox(width: Dimens.pt30),
                      GestureDetector(
                          onTap: () {
                            var text = textField.text.trim();
                            InputWidget inputState =
                                InputWidget(text: text, send: true);
                            Navigator.pop(context, inputState);
                          },
                          child: Container(
                              width: Dimens.pt80,
                              height: Dimens.pt45,
                              decoration: BoxDecoration(
                                  color: Color(0xFF4A4A6D),
                                  borderRadius:
                                      BorderRadius.circular(Dimens.pt8)),
                              child: Center(
                                  child: Text("发送",
                                      style: TextStyle(
                                          fontSize: Dimens.pt24,
                                          color: Colors.white)))))
                    ])))
          ]),
        ));
  }
}
