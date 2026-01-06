class BottomBarModel {
  String? title;
  String? icon;
  String? selectIcon;
  String? subIcon;
  String? selectSubIcon;
  bool? isShowNewMsg;

  BottomBarModel(
      {this.title,
      this.icon,
      this.selectIcon,
      this.subIcon,
      this.selectSubIcon,
      this.isShowNewMsg});

  BottomBarModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    icon = json['icon'];
    selectIcon = json['selectIcon'];
    subIcon = json['subIcon'];
    selectSubIcon = json['selectSubIcon'];
    isShowNewMsg = json['isShowNewMsg'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['title'] = title;
    data['icon'] = icon;
    data['selectIcon'] = selectIcon;
    data['subIcon'] = subIcon;
    data['selectSubIcon'] = selectSubIcon;
    data['isShowNewMsg'] = isShowNewMsg;
    return data;
  }
}
