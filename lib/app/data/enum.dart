// TopicShowType Enum类
import 'package:flutter/material.dart';
import 'package:quick_cat_client/app/themes/app_colors.dart';

import '../model/game_model.dart';

enum TopicShowType {
  none, // 无意义
  fiveGrid, // 五宫格 showType = 1
  sixGridThree, // 六宫格竖向封面 *3 showType = 2
  sixGridTwo, // 六宫格封面 * 2 showType = 3
  nineGridThree, // 九宫格竖向封面 *3 showType = 4
  scrollHorizontal, // 横排滚动 showType = 5
  bigCoverList, // 大封面列表 showType = 6
  none1,
  none2,
  none3,
  none4,
  none5,
  none6,
  none7,
  none8,
  none9,
  none10,
  none11
}

enum ActionType {
  None, //  OperationType = 0
  Collect, //OperationType = 1 //收藏
  Like, //  OperationType = 2 //点赞
  StepOn, // OperationType = 3 //踩
  TypeLikes, //喜欢
  TypeTearsJoy, //笑哭
  TypeFury, //愤怒
  TypeFlushedFace, //脸红
  TypeJoker, //小丑
}

enum CommentType {
  CT_Invalid,
  CT_Video, // 1 视频
  CT_Post, // 2 帖子
  CT_Comic, // 3 漫画
  CT_Novel, // 4 漫画
  CT_Photo, // 5 写真
  CT_Preview, // 6新番预告
}

enum StartBtnDirect { left, right, up, down }

enum GoldTaskType {
  None,
  MT_BindMobileOrEmail, // 1.绑定手机或邮箱
  MT_InviteUser, // 2.邀请好友
  MT_SharePoster, // 3.分享有奖
  MT_Pay, // 4.充值消费
  MT_Login, // 5.连续登陆
  MT_AllDone, // 6.完成所有任务奖励
  MT_DailyCheckin, // 7.每日签到
  MT_Follow, // 7.关注
}

enum SortMediaType {
  None,
  MT_New, // 1.最新更新
  MT_Watch, // 2.最多观看
  MT_Commomet, // 3.最多评论
}

// 简约播放器 属性 1: 长视频 2：短视频
enum SimplePlayerType { none, simpleLong, simpleShort }

enum ToastType {
  None, // 无意义
  Error,
  SUCCESS
}

enum GameCategory {
  none, // 无意义
  gameCategoryBY, // 捕鱼
  gameCategorySX, // 真人视讯
  gameCategoryQP, // 棋牌
  gameCategoryDZ, // 电子游戏
  gameCategoryTY, // 体育
  gameCategoryCP, // 彩票
  gameCategoryHT, // 玩过
}

Map<GameCategory, CategoryInfoBean> gameCategoryToName = {
  GameCategory.gameCategoryBY: CategoryInfoBean(
      gameCategory: GameCategory.gameCategoryBY.index,
      title: "捕鱼",
      icon: "assets/img/icon_game_by.png",
      sleIcon: "assets/img/icon_game_by_sel.png"),
  GameCategory.gameCategorySX: CategoryInfoBean(
      gameCategory: GameCategory.gameCategorySX.index,
      title: "视讯",
      icon: "assets/img/icon_game_ss.png",
      sleIcon: "assets/img/icon_game_ss_sel.png"),
  GameCategory.gameCategoryQP: CategoryInfoBean(
      gameCategory: GameCategory.gameCategoryQP.index,
      title: "棋牌",
      icon: "assets/img/icon_game_qp.png",
      sleIcon: "assets/img/icon_game_qp_sel.png"),
  GameCategory.gameCategoryDZ: CategoryInfoBean(
      gameCategory: GameCategory.gameCategoryDZ.index,
      title: "电子",
      icon: "assets/img/icon_game_dz.png",
      sleIcon: "assets/img/icon_game_dz_sel.png"),
  GameCategory.gameCategoryTY: CategoryInfoBean(
      gameCategory: GameCategory.gameCategoryTY.index,
      title: "体育",
      icon: "assets/img/icon_game_ty.png",
      sleIcon: "assets/img/icon_game_ty_sel.png"),
  GameCategory.gameCategoryCP: CategoryInfoBean(
      gameCategory: GameCategory.gameCategoryCP.index,
      title: "彩票",
      icon: "assets/img/icon_game_cp.png",
      sleIcon: "assets/img/icon_game_cp_sel.png"),
  GameCategory.gameCategoryHT: CategoryInfoBean(
      gameCategory: GameCategory.gameCategoryHT.index,
      title: "玩过",
      icon: "assets/img/icon_game_wg.png",
      sleIcon: "assets/img/icon_game_wg_sel.png"),
};

enum WithdrawType {
  none, // 无意义
  bank, // 银行卡
  aliPay, // 支付宝
  weChat, // 微信
  usdt, // USDT
  bobi, // 波币
  gopay, // gopay
  okpay, // okpay
}



enum RecordType {
  none, // 无意义
  recordTypeShare, // 分享记录
  recordTypeEnterGame, // 进入游戏记录
}

enum ShareType {
  none, // 无意义
  showTypeLongMedia, // 短视频
  showTypeShortMedia, // 长视频
  showTypePost, // 帖子
  showTypeNovel, // 小说
}

enum TaskStatus {
  statusDoing, // 完成中
  statusDone, // 已完成
  statusFinish, // 已经领取
}

enum BillInfoType {
  none, // 无意义
  billTypeRecharge, // 充值详情
  billTypeWithdraw, // 提现详情
  billTypeGame // 游戏消费详情
}

// 编辑选择状态
enum EditStatusType {
  none, // 无状态 正常无编辑状态
  noSelect, // 未选择 编辑状态未选择
  selected, // 选择状态
}

// 支付状态
enum PaymentType {
  freePaymentType, // 免费
  vipPaymentType, // 会员
  coinPaymentType, // 金币
}

enum CategoryShowType {
  none, // 无意义
  topicShowType, // 专题
  bigListShowType, // 大列表
  aiShowType, // ai 推荐列表
}

enum MediaType {
  none, //  ContentType = 0  // 占位符，无意义
  videoLong, // ContentType = 1  // AV（长视频）
  videoShort, // ContentType = 2  // 小视频
  cartoon, // ContentType = 3  // 动漫
  waiWei, // ContentType = 4  // 上门 (帝王调教)
  post, // ContentType = 5  // 帖子（91免费视频交易）
  dating, // ContentType = 6  // 楼风
  actor, // ContentType = 7  // 女优
  comic, // ContentType = 8  // 漫画
  photo, // ContentType = 9  // 写真
  novel, // ContentType = 10 // 小说
  comicsMedia, // ContentType = 11 // 漫画视频
  comment, // ContentType = 12 // 评论
  darkWeb, // ContentType = 13 // 暗黑网
}

enum CoverType {
  none, // 无意义
  coverHorizontal, //  1: 横版封面
  coverVertical, // 2: 竖版封面
  coverWaterfall, // 3:瀑布流
}

enum TaskType {
  bindMobile, //绑定手机1
  saveCert, //保存账号凭证2
  watchComics, //阅读漫画3
  watchVideo, //观看视频4
  checkIn, //连续签到5
  comment, //发表评论6
  payCoin, //金币充值7
  inviteUser, //邀请好友8
  allDone, //完成所有新手任务9
}

enum AiTaskType {
  none, // 无意义
  aiChangeFace, // ai换脸
  aiOffClothes, // ai脱衣服
  aiGenerateGirl, // ai生成
  aiMakeup, // ai化妆
  aiHaircut, // ai换发型
  aiChangeSkinColor, // ai换肤色
}

enum AiTaskStatus {
  aiTaskWaiting, // ai任务已提交
  aiTaskDoing, // ai任务进行中
  aiTaskDone, // ai任务已完成
  aiTaskFailed, // ai任务失败
}

enum InviteReceiveStatus {
  none, // 无意义
  notInvite, // 未完成
  invited, // 已完成
  received, // 已领取
}

Color getInviteReceiveStatusTextColor(InviteReceiveStatus status) {
  switch (status) {
    case InviteReceiveStatus.notInvite:
      return const Color(0xFF020150); //  "未完成"
    case InviteReceiveStatus.invited:
      return Colors.white; // "已完成"
    case InviteReceiveStatus.received:
      return const Color(0xFF969291); //  "已领取"
    default:
      return const Color(0xFF000000); // Default to black
  }
}

Color getInviteReceiveStatusBgColor(InviteReceiveStatus status) {
  switch (status) {
    case InviteReceiveStatus.notInvite:
      return Colors.white; //  "未完成"
    case InviteReceiveStatus.invited:
      return AppColors.mainRed; // "已完成"
    case InviteReceiveStatus.received:
      return const Color(0xFFD4D4D4); //  "已领取"
    default:
      return const Color(0xFF000000); // Default to black
  }
}

String getInviteReceiveStatusDesc(InviteReceiveStatus status) {
  switch (status) {
    case InviteReceiveStatus.notInvite:
      return "未完成";
    case InviteReceiveStatus.invited:
      return "已完成";
    case InviteReceiveStatus.received:
      return "已领取";
    default:
      return "";
  }
}
