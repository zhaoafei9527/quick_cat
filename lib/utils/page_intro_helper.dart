// 🌎 Project imports:

/// 页面引导提示帮助类
mixin PageIntroHelper {
  /// 是否已经进入过页面
  // Future<bool> hasEntered() async {
  //   return (await lightKV
  //           .getBool("first_in_page_${this.runtimeType.toString()}")) ??
  //       false;
  // }
  //
  // Future setEntered(bool enter) {
  //   return lightKV.setBool(
  //       "first_in_page_${this.runtimeType.toString()}", enter);
  // }
}
