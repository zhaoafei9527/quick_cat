import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';

class AiTagStringList extends BaseNetModel {
  @override
  AiTagStringList fromJson(Map<String, dynamic> json) {
    return AiTagStringList.fromJson(json);
  }

  int? count;
  List<AiCateGoryInfo>? list;

  AiTagStringList({this.count, this.list});

  AiTagStringList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <AiCateGoryInfo>[];
      json['list'].forEach((v) {
        list!.add(AiCateGoryInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiTFaceImageList extends BaseNetModel {
  @override
  AiTFaceImageList fromJson(Map<String, dynamic> json) {
    return AiTFaceImageList.fromJson(json);
  }

  int? count;
  List<AiCateGoryInfo>? list;

  AiTFaceImageList({this.count, this.list});

  AiTFaceImageList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <AiCateGoryInfo>[];
      json['list'].forEach((v) {
        list!.add(AiCateGoryInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiCateGoryInfo extends BaseNetModel {
  @override
  AiCateGoryInfo fromJson(Map<String, dynamic> json) {
    return AiCateGoryInfo.fromJson(json);
  }

  int? aiType;
  String? desc;
  List<String>? effectImgs;
  List<ChangeFaceImages>? changList;
  int? id;
  String? pic;
  int? price;
  String? title;
  bool? isMany;
  List<AiTagList>? tagList;
  bool? showGroup = false;

  AiCateGoryInfo(
      {this.aiType,
      this.desc,
      this.effectImgs,
      this.id,
      this.pic,
      this.price,
      this.title,
      this.isMany,
      this.changList,
      this.showGroup,
      this.tagList});

  AiCateGoryInfo.fromJson(Map<String, dynamic> json) {
    aiType = json['aiType'];
    desc = json['desc'];
    if (json['effectImgs'] != null) {
      effectImgs = <String>[];
      json['effectImgs'].forEach((v) {
        effectImgs!.add(v);
      });
    }
    id = json['id'];
    pic = json['pic'];
    price = json['price'];
    title = json['title'];
    isMany = json['isMany'];

    if (json['changList'] != null) {
      changList = <ChangeFaceImages>[];
      json['changList'].forEach((v) {
        changList!.add(ChangeFaceImages.fromJson(v));
      });
    }

    if (json['tagList'] != null) {
      tagList = <AiTagList>[];
      json['tagList'].forEach((v) {
        tagList!.add(AiTagList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['aiType'] = aiType;
    data['desc'] = desc;
    data['effectImgs'] = effectImgs;
    data['id'] = id;
    data['pic'] = pic;
    data['price'] = price;
    data['title'] = title;
    data['isMany'] = isMany;
    if (changList != null) {
      data['changList'] = changList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiTagList {
  String? tagEng;
  String? tagStr;

  AiTagList({this.tagEng, this.tagStr});

  AiTagList.fromJson(Map<String, dynamic> json) {
    tagEng = json['tagEng'];
    tagStr = json['tagStr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tagEng'] = tagEng;
    data['tagStr'] = tagStr;
    return data;
  }
}

class ChangeFaceImages {
  String? desc;
  String? title;
  int? id;
  int? categoryId;
  List<AiImageInfo>? AIImgs;

  ChangeFaceImages(
      {this.desc, this.title, this.id, this.categoryId, this.AIImgs});

  ChangeFaceImages.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    title = json['title'];
    id = json['id'];
    categoryId = json['categoryId'];
    if (json['AIImgs'] != null) {
      AIImgs = <AiImageInfo>[];
      json['AIImgs'].forEach((v) {
        AIImgs!.add(AiImageInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['desc'] = desc;
    data['title'] = title;
    data['id'] = id;
    data['categoryId'] = categoryId;
    if (AIImgs != null) {
      data['AIImgs'] = AIImgs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiImageInfo {
  int? height;
  String? img;
  int? price;
  int? width;

  AiImageInfo({this.height, this.img, this.price, this.width});

  AiImageInfo.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    img = json['img'];
    price = json['price'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['img'] = img;
    data['price'] = price;
    data['width'] = width;
    return data;
  }
}

class AiTaskListRespModel extends BaseNetModel {
  @override
  AiTaskListRespModel fromJson(Map<String, dynamic> json) {
    return AiTaskListRespModel.fromJson(json);
  }

  int? count;
  List<AiTaskRequestModel>? list;

  AiTaskListRespModel({this.count, this.list});

  AiTaskListRespModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      list = <AiTaskRequestModel>[];
      json['list'].forEach((v) {
        list!.add(AiTaskRequestModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiTaskRequestModel {
  AiTaskStatus? taskStatus;
  List<String>? aiImages; // ai 生成的图片列表
  AiTaskType? aiType;
  String? createdAt; // 创建时间,

  String? desc;
  String? finishAt; // 完成时间
  int? id; // 任务id

  String? image; // 上传的原图
  int? price;
  String? stencilPic; // 模版图片
  List<AiTagList>? tagList; // 标签列表
  int? userId; // 用户id

  AiTaskRequestModel(
      {this.desc,
      this.aiType,
      this.price,
      this.image,
      this.stencilPic,
      this.aiImages,
      this.taskStatus,
      this.tagList,
      this.createdAt,
      this.finishAt,
      this.id,
      this.userId});

  AiTaskRequestModel.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    aiType = AiTaskType.values[json['aiType'] ?? 0];
    price = json['price'];
    image = json['image'];
    stencilPic = json['stencilPic'];
    taskStatus = AiTaskStatus.values[json['AITaskStatus'] ?? 0];
    if (json['aiImages'] != null) {
      aiImages = <String>[];
      json['aiImages'].forEach((v) {
        aiImages!.add(v);
      });
    }
    if (json['tagList'] != null) {
      tagList = <AiTagList>[];
      json['tagList'].forEach((v) {
        tagList!.add(AiTagList.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    finishAt = json['finishAt'];
    id = json['id'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['desc'] = desc;
    data['aiType'] = aiType?.index;
    data['price'] = price;
    data['image'] = image;
    data['stencilPic'] = stencilPic;
    data['taskStatus'] = taskStatus?.index;
    if (aiImages != null) {
      data['aiImages'] = aiImages;
    }
    if (tagList != null) {
      data['tagList'] = tagList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
