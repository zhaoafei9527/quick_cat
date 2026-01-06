// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class FaqList extends BaseNetModel {
  @override
  FaqList fromJson(Map<String, dynamic> json) {
    return FaqList.fromJson(json);
  }

  List<FeedbackList>? feedbackList;

  FaqList({this.feedbackList});

  FaqList.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      feedbackList = <FeedbackList>[];
      json['list'].forEach((v) {
        feedbackList?.add(FeedbackList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (feedbackList != null) {
      data['list'] = feedbackList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FeedbackList {
  String? content;
  String? title;
  Function(int)? onTap;

  FeedbackList({this.content, this.title, this.onTap});

  FeedbackList.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    title = json['title'];
    onTap = json['onTap'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['content'] = content;
    data['title'] = title;
    data['onTap'] = onTap;
    return data;
  }
}
