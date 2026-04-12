// 🐦 Flutter imports:
import 'package:quick_cat_client/app/model/ai_generate_model.dart';
import 'package:quick_cat_client/app/model/comic_chapter.dart';
import 'package:quick_cat_client/app/model/comic_info_model.dart';
import 'package:quick_cat_client/app/model/cut_info.dart';
import 'package:quick_cat_client/app/model/episode_preview.dart';
import 'package:quick_cat_client/plugins_utils/FirebaseUtils/firebse_utils.dart';
import 'package:quick_cat_client/utils/toast_util.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/enum.dart';
import 'package:quick_cat_client/app/model/activity_model.dart';
import 'package:quick_cat_client/app/model/bill_info_model.dart';
import 'package:quick_cat_client/app/model/check_in_model.dart';
import 'package:quick_cat_client/app/model/envelope_model.dart';
import 'package:quick_cat_client/app/model/home/pay_list_model.dart';
import 'package:quick_cat_client/app/model/home/qrcode_info_model.dart';
import 'package:quick_cat_client/app/model/home/qrmodel.dart';
import 'package:quick_cat_client/app/model/list_comment.dart';
import 'package:quick_cat_client/app/model/user_balance_model.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/HttpRequester.dart';
import 'package:quick_cat_client/plugins_utils/HttpRequester/http_requester.dart';
import 'package:quick_cat_client/utils/logger_utils.dart';
import 'package:get/get.dart' hide FormData;
import '../app/data/share_key.dart';
import '../app/model/barrages_model.dart';
import '../app/model/game_model.dart';
import '../app/model/home/bank_by_list_model.dart';
import '../app/model/home/banks_list_model.dart';
import '../app/model/home/config_model_model.dart';
import '../app/model/home/game_detail_model.dart';
import '../app/model/home/get_paid_url_model.dart';
import '../app/model/home/ie_detail_model_model.dart';
import '../app/model/home/payment_list_model.dart';
import '../app/model/home/services_model.dart';
import '../app/model/home/topic_list_model.dart';
import '../app/model/home/user_info_model.dart';
import '../app/model/home/video_play_model.dart';
import '../app/model/hot_search.dart';
import '../app/model/msg_notify_list_model.dart';
import '../app/model/post_list_model.dart';
import '../app/model/recharge_model.dart';
import '../app/model/task_center_model.dart';
import '../app/model/vip_card_list_model.dart';
import '../plugins_utils/HttpRequester/src/base_resp_bean.dart';

class ApiRes {
  static int pageSize = 10;

  static const conf = "/api/app/ping/config";

  static const customConfig = "/api/app/custom/getEndpoint";

  static const login = "/api/app/login/guest";

  static const logOut = "/api/app/user/logout";

  static const home = "/api/app/media/home";

  static const getNodes = "/api/app/node/list";

  static const getLines = "/api/app/node/getline";

  static const getGoldTask = "/api/app/mission/info";

  static const getReward = "/api/app/mission/reward";

  /// 专题详情
  static const topicDetail = "/api/app/media/topic/details";

  static const changeTopic = "/api/app/media/topic/change";

  static const play = "/api/app/media/play";

  static const getBarrage = "/api/app/bulletscreen/list";

  static const m3u8 = "/api/web/media/m3u8";

  static const h5m3u8 = "/api/app/media/h5/m3u8";

  static const getHotSearch = "/hotsearch/list2";

  /// 视频播放器下面的推荐视频
  static const videoLike = "/api/app/media/like";

  /// 获取推荐视频列表
  static const videoRecommend = "/api/app/media/recommend";

  /// 获取搜索推荐视频列表
  static const videoHotSearch = "/api/app/hotsearch/minidramas";

  /// 获取搜索视频列表
  static const videoSearch = "/api/app/search/minidramas";

  /// 短剧视频播放
  static const videoPlay = "/api/app/media/minidrama/play";

  static const register = "/api/app/login/bindMobile";

  static const sendCaptcha = "/api/app/login/captcha";

  static const sendEmailCaptcha = "/api/app/login/email/mailCaptcha";

  static const loginEmail = "/api/app/login/email/register";

  static const emailLogin = "/api/app/login/email/login";

  static const loginMobile = "/api/app/login/phone";

  static const qrcodeInfo = "/api/app/user/qrcode/info"; //二维码找回账号

  static const qrcodeObtain = "/api/app/user/qrcode"; //获取二维码

  static const collectList = "/api/app/media/collect/history"; //收藏列表

  static const operating = "/api/app/media/operating"; //添加收藏，接口

  static const cardList = "/api/app/card/list";

  static const submitPay = "/api/app/recharge/submit";

  static const getPayInfoList = "/api/app/gold/paytypeinfo"; //支付列表

  static const watchHistory = "/api/app/media/watch/history"; //播放历史记录列表

  static const faqList = "/api/app/faq/list"; //反馈列表

  static const feedbackAdd = "/api/app/feedback/add"; //用户反馈

  static const redeemcodeUse = "/api/app/redeemcode/use"; //使用兑换码

  static const messageList = "/api/app/message/list"; //使用兑换码

  static const sessionList = "/api/app/session/list"; //设备管理列表

  static const sessionRemove = "/api/app/session/remove"; //设备管理删除设备

  static const pullGoldRecord = "/api/app/trans/list";

  /// path /recharge/getRType 获取支付通道
  /// [id] 分类Id
  static Future<PaymentList?> getRechargePayment() async {
    PaymentList? model;
    String? path = "recharge/getRType";
    Map<String, dynamic> data = {};
    model = await _basePostNet<PaymentList>(
        BaseParams(PaymentList(), path: path, data: data));
    return model;
  }

  /// path recharge/getOnlineWaiter
  static Future<OnlineRecharge?> getOnlineRechargeList() async {
    OnlineRecharge? model;
    String? path = "recharge/getOnlineWaiter";
    Map<String, dynamic> data = {};
    model = await _basePostNet<OnlineRecharge>(
        BaseParams(OnlineRecharge(), path: path, data: data));
    return model;
  }

  /// path /gold/paytypeinfo 获取可充值金额列表
  /// [id] 分类Id
  static Future<PayList?> getGoldpaytyPeinfo({
    int? rechargeType,
  }) async {
    PayList? model;
    String? path = "gold/paytypeinfo";
    Map<String, dynamic> data = {};
    data["rechargeType"] = rechargeType;
    model = await _basePostNet<PayList>(
        BaseParams(PayList(), path: path, data: data));
    return model;
  }

  /// path /recharge/submit 获取支付链接
  /// [id] 分类Id
  static Future<GetPaidUrl?> getRechargeSubmit(
      {int? payAmount, int? payMode, int? productId, int? rchgUse}) async {
    GetPaidUrl? model;
    String? path = "recharge/submit";
    Map<String, dynamic> data = {};
    data["payAmount"] = payAmount;
    data["payMode"] = payMode;
    data["productId"] = productId;
    data["rchgUse"] = rchgUse;
    model = await _basePostNet<GetPaidUrl>(
        BaseParams(GetPaidUrl(), path: path, data: data));
    return model;
  }

  /// path /card/list 获取银行卡列表
  /// [id] 分类Id
  static Future<BanksList?> getBankList() async {
    BanksList? model;
    String? path = "banks/list";
    Map<String, dynamic> data = {};
    data["pageNum"] = 1;
    data["pageSize"] = 20;
    model = await _basePostNet<BanksList>(
        BaseParams(BanksList(), path: path, data: data));
    return model;
  }

  /// path /card/list 获取绑定银行卡列表
  /// [id] 分类Id
  static Future<BankByList?> getBankCardList() async {
    BankByList? model;
    String? path = "banks/getBankById";
    Map<String, dynamic> data = {};
    model = await _basePostNet<BankByList>(
        BaseParams(BankByList(), path: path, data: data));
    return model;
  }

  /// path /banks/bindBank 银行卡绑定
  /// [id] 分类Id
  static Future submitBindBankCard(
      {String? accountName,
      String? accountNo,
      String? bankBranch,
      String? bankCode,
      String? bankName,
      int? wtype,
      Function()? onSuccess,
      Function(String)? onError}) async {
    String? path = "banks/bindBank";
    Map<String, dynamic> data = {};
    data["accountName"] = accountName ?? "";
    data["accountNo"] = accountNo ?? "";
    data["bankBranch"] = bankBranch ?? "";
    data["bankCode"] = bankCode ?? "";
    data["bankName"] = bankName ?? "";
    if (wtype != null) data["wtype"] = wtype;
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onSuccess: (model) => onSuccess?.call(),
        onError: onError));
  }

  /// path /api/app/withdrawal/submitV2 提现
  /// [id] 分类Id
  static Future submitWithdrawal(
      {String? accountName,
      String? accountNo,
      String? bankBranch,
      String? bankCode,
      String? bankName,
      int? money,
      int? orderType,
      Function()? onSuccess,
      Function(String)? onError}) async {
    String? path = "withdrawal/submitV2";
    Map<String, dynamic> data = {};
    data["accountName"] = accountName ?? "";
    data["accountNo"] = accountNo ?? "";
    data["bankBranch"] = bankBranch ?? "";
    data["bankCode"] = bankCode ?? "";
    data["bankName"] = bankName ?? "";
    data["money"] = money ?? 0;
    data["orderType"] = orderType ?? 1;
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onSuccess: (model) => onSuccess?.call(),
        onError: onError));
  }

  /// path /api/app/comics/pay 漫画购买
  /// [id] 分类Id
  static Future buyComicOfId(
      {int? id, Function()? onSuccess, Function(String)? onError}) async {
    String? path = "comics/pay";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onSuccess: (model) => onSuccess?.call(),
        onError: onError));
  }

  /// path /api/app/novel/pay 小说购买
  /// [id] 分类Id
  static Future buyNovelOfId(
      {int? id, Function()? onSuccess, Function(String)? onError}) async {
    String? path = "novel/pay";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onSuccess: (model) => onSuccess?.call(),
        onError: onError));
  }

  /// path media/buyHistory 获取用户购买流水记录
  /// [pageNum] 页码
  static Future<BillRecordDetailModel?> getBuyHistoryRecord(
      {int? pageNum}) async {
    BillRecordDetailModel? model;
    String? path = "media/buyHistory";
    Map<String, dynamic> data = {};
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<BillRecordDetailModel>(
        BaseParams(BillRecordDetailModel(), path: path, data: data));
    return model;
  }

  /// path /card/list 获取VIP卡权益列表
  /// [id] 分类Id
  static Future<VipCardList?> getVipCardList() async {
    VipCardList? model;
    String? path = "card/list";
    Map<String, dynamic> data = {};
    model = await _basePostNet<VipCardList>(
        BaseParams(VipCardList(), path: path, data: data));
    return model;
  }

  /// path /custom/getEndpoint 获取在线客服
  /// [id] 分类Id
  static Future<ServicesModel?> getCustomServers() async {
    ServicesModel? model;
    String? path = "custom/getEndpoint";
    Map<String, dynamic> data = {};
    model = await _basePostNet<ServicesModel>(
        BaseParams(ServicesModel(), path: path, data: data));
    return model;
  }

  /// path wlgame/enterGame 获取某个账单详情
  /// [id] 分类Id
  static Future<BillDetailsInfo?> getBillInfo({int? id, int? billType}) async {
    BillDetailsInfo? model;
    String? path = "recharge/getBillDetail";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["billType"] = billType ?? 1;
    model = await _basePostNet<BillDetailsInfo>(
        BaseParams(BillDetailsInfo(), path: path, data: data));
    return model;
  }

  /// path game/enterGame 进入某个游戏
  /// [id] 分类Id
  static Future<GameListModel?> enterGame(
      {int? gamePlatform, String? gameType}) async {
    GameListModel? model;
    String? path = "game/enterGame";
    Map<String, dynamic> data = {};

    data["gamePlatform"] = gamePlatform ?? 0;
    data["gameType"] = gameType ?? "2";
    model = await _basePostNet<GameListModel>(
        BaseParams(GameListModel(), path: path, data: data));
    return model;
  }

  // path game/exitGame  // 退出游戏

  static Future exitGame({int gamePlatform = 1}) async {
    String? path = "game/enterGame";
    Map<String, dynamic> data = {};

    data["gamePlatform"] = gamePlatform;
    await _basePostNet(BaseParams(null, path: path, data: data));
  }

  /// path game/getList 获取游戏平台列表
  static Future<GamePlatformListModel?> getGamePlatformList() async {
    GamePlatformListModel? model;
    String? path = "game/getList";
    Map<String, dynamic> data = {};
    model = await _basePostNet<GamePlatformListModel>(
        BaseParams(GamePlatformListModel(), path: path, data: data));
    return model;
  }

  /// path wlgame/getList 获取与游戏列表
  /// [id] 分类Id
  static Future<GameListModel?> getGameList(
      {int? gameCategory, int? gamePlatform}) async {
    GameListModel? model;
    String? path = "wlgame/getList";
    Map<String, dynamic> data = {};
    data["gamePlatform"] = gamePlatform ?? 0;
    data["gameCategory"] = gameCategory ?? 0;
    model = await _basePostNet<GameListModel>(
        BaseParams(GameListModel(), path: path, data: data));
    return model;
  }

  /// path post/list 获取帖子详情
  /// [id] 帖子Id
  static Future<PostDetailsResp?> getPostDetail({int? id}) async {
    PostDetailsResp? model;
    String? path = "post/detail";
    model = await _basePostNet<PostDetailsResp>(
        BaseParams(PostDetailsResp(), path: path, data: {"id": id}));
    return model;
  }

  /// path post/list 根据主题ID获取帖子列表
  /// [topicId] 分类Id
  static Future<PostBriefResp?> getPostListOfTopic(
      {int? topicId, int? pageNum}) async {
    PostBriefResp? model;
    String? path = "post/listByPostId";
    Map<String, dynamic>? data = {};
    data["pageSize"] = pageSize;
    data["pageNum"] = pageNum;
    data["topicId"] = topicId;

    model = await _basePostNet<PostBriefResp>(
        BaseParams(PostBriefResp(), path: path, data: data ?? {}));
    return model;
  }

  /// path post/list 获取帖子列表
  /// [id] 分类Id
  static Future<PostBriefResp?> getPostList(
      {Map<String, dynamic>? data}) async {
    PostBriefResp? model;
    String? path = "post/list";
    data?["pageSize"] = pageSize;
    model = await _basePostNet<PostBriefResp>(
        BaseParams(PostBriefResp(), path: path, data: data ?? {}));
    return model;
  }

  /// path redeemcode/use 使用兑换码
  static Future useRedeemCode({
    String? code,
    Function(String)? onError,
    Function()? onSuccess,
  }) async {
    String? path = "redeemcode/use";
    Map<String, dynamic> data = {};
    data["code"] = code ?? "";
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onError: onError,
        onSuccess: (rep) => onSuccess?.call()));
  }

  /// path /user/getGameDetail 获取游戏记录
  static Future<GameDetail?> getGameDetailList(
      {int? pageNum, int? dayType}) async {
    GameDetail? model;
    String? path = "user/getGameDetail";
    Map<String, dynamic> data = {};
    data["dayType"] = dayType ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<GameDetail>(
        BaseParams(GameDetail(), path: path, data: data));
    return model;
  }

  /// path redeemcode/list 获取兑换码兑换记录
  static Future<RechargeModel?> getRedeemList({int? pageNum}) async {
    RechargeModel? model;
    String? path = "redeemcode/list";
    Map<String, dynamic> data = {};
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<RechargeModel>(
        BaseParams(RechargeModel(), path: path, data: data));
    return model;
  }

  /// path withdrawal/typeList 获取提现类型列表
  static Future<WithdrawTypeListModel?> getWithdrawTypeList(
      {int? pageNum, int? dayType}) async {
    WithdrawTypeListModel? model;
    String? path = "withdrawal/typeList";
    Map<String, dynamic> data = {};
    model = await _basePostNet<WithdrawTypeListModel>(
        BaseParams(WithdrawTypeListModel(), path: path, data: data));
    return model;
  }

  /// path withdrawal/getList 获取提现记录列表
  static Future<RechargeModel?> getWithdrawalList(
      {int? pageNum, int? dayType}) async {
    RechargeModel? model;
    String? path = "withdrawal/getList";
    Map<String, dynamic> data = {};
    data["dayType"] = dayType ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<RechargeModel>(
        BaseParams(RechargeModel(), path: path, data: data));
    return model;
  }

  /// path trans/recharge/list 获取收支记录列表
  static Future<IeDetailModel?> getIeDetailList(
      {int? pageNum, int? dayType, int? ieType, int? markType}) async {
    IeDetailModel? model;
    String? path = "user/ieDetail";
    Map<String, dynamic> data = {};
    data["dayType"] = dayType ?? 0;
    data["ieType"] = ieType ?? 0;
    data["markType"] = markType ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<IeDetailModel>(
        BaseParams(IeDetailModel(), path: path, data: data));
    return model;
  }

  /// path trans/recharge/list 获取充值记录列表
  static Future<RechargeModel?> getRechargeList(
      {int? pageNum, int? dayType}) async {
    RechargeModel? model;
    String? path = "trans/recharge/list";
    Map<String, dynamic> data = {};
    data["dayType"] = dayType ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<RechargeModel>(
        BaseParams(RechargeModel(), path: path, data: data));
    return model;
  }

  /// path user/isReceive 获取消息中心列表
  /// [type]   1.评论  2.通知  3.关注
  static Future<MsgNotifyListModel?> getSystemMessageList(
      {int? type, int? pageNum}) async {
    MsgNotifyListModel? model;
    String? path = "message/list";
    Map<String, dynamic> data = {};
    data["type"] = type ?? 1;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<MsgNotifyListModel>(
        BaseParams(MsgNotifyListModel(), path: path, data: data));
    return model;
  }

  ///  path checkin/setup 获取签到积分规则
  static Future<WelfareTaskCenter?> getCheckInRuleList() async {
    WelfareTaskCenter? model;
    String? path = "checkin/setup";
    Map<String, dynamic> data = {};
    model = await _basePostNet<WelfareTaskCenter>(
        BaseParams(WelfareTaskCenter(), path: path, data: data));
    return model;
  }

  ///  path checkin/page 签到任务积分
  static Future<WelfareTaskCenter?> getWelfareTasksList() async {
    WelfareTaskCenter? model;
    String? path = "checkin/page";
    Map<String, dynamic> data = {};
    model = await _basePostNet<WelfareTaskCenter>(
        BaseParams(WelfareTaskCenter(), path: path, data: data));
    return model;
  }

  /// path checkin/click 签到领取奖励
  static Future<CheckInModel?> checkInWeekly() async {
    CheckInModel? model;
    String? path = "checkin/click";
    Map<String, dynamic> data = {};
    model = await _basePostNet<CheckInModel>(
        BaseParams(CheckInModel(), path: path, data: data));
    return model;
  }

  /// path user/isReceive 获取活动中心列表
  static Future<ActivityModel?> getActivityList() async {
    ActivityModel? model;
    String? path = "activity/list";
    Map<String, dynamic> data = {};
    model = await _basePostNet<ActivityModel>(
        BaseParams(ActivityModel(), path: path, data: data));
    return model;
  }

  /// path sharegift/list 邀请有礼活动列表
  static Future<InvitedListModel?> getInvitedList() async {
    InvitedListModel? model;
    String? path = "sharegift/list";
    Map<String, dynamic> data = {};
    model = await _basePostNet<InvitedListModel>(
        BaseParams(InvitedListModel(), path: path, data: data));
    return model;
  }

  /// path sharegift/receive 邀请有礼领取奖励
  static Future getInvitedReceive() async {
    ActivityModel? model;
    String? path = "sharegift/receive";
    Map<String, dynamic> data = {};
    model = await _basePostNet(BaseParams(null, path: path, data: data));
    return model;
  }

  /// path user/vipRedEnv 签到领取红包
  static Future<EnvelopeModel?> checkInEnv() async {
    EnvelopeModel? model;
    String? path = "user/vipRedEnv";
    Map<String, dynamic> data = {};
    model = await _basePostNet<EnvelopeModel>(
        BaseParams(EnvelopeModel(), path: path, data: data));
    return model;
  }

  /// path user/isReceive 获取vip等级红包列表
  static Future<EnvelopeModel?> getEnvelopeList() async {
    EnvelopeModel? model;
    String? path = "user/isReceive";
    Map<String, dynamic> data = {};
    model = await _basePostNet<EnvelopeModel>(
        BaseParams(EnvelopeModel(), path: path, data: data));
    return model;
  }

  /// path checkin/clickV3 签到领取奖励
  static Future<CheckInModel?> checkInWeeklyV3() async {
    CheckInModel? model;
    String? path = "checkin/clickV3";
    Map<String, dynamic> data = {};
    model = await _basePostNet<CheckInModel>(
        BaseParams(CheckInModel(), path: path, data: data));
    return model;
  }

  /// path prize/redeem 兑换签到积分
  static Future redeemPoints({int? prizeId}) async {
    String? path = "prize/redeem";
    Map<String, dynamic> data = {};
    data["prizeId"] = prizeId ?? 0;
    await _basePostNet(BaseParams(null, path: path, data: data));
  }

  /// path prize/redeemhistory 签到奖品兑换记录
  // static Future<null?> getRewardRedemption({int? pageNum}) async {
  //   RewardRedemption? model;
  //   String? path = "prize/redeemhistory";
  //   Map<String, dynamic> data = {};
  //   data["pageNum"] = pageNum ?? 1;
  //   data["pageSize"] = pageSize;
  //   model = await _basePostNet<RewardRedemption>(
  //       BaseParams(RewardRedemption(), path: path, data: data));
  //   return model;
  // }

  /// path checkin/weekList 获取周签到列表数据 新版本
  static Future<CheckInModel?> getWeeklyCheckListV3() async {
    CheckInModel? model;
    String? path = "checkin/checkinListV3";
    Map<String, dynamic> data = {};
    model = await _basePostNet<CheckInModel>(
        BaseParams(CheckInModel(), path: path, data: data));
    return model;
  }

  /// path checkin/weekList 获取周签到列表数据
  static Future<CheckInModel?> getWeeklyCheckList() async {
    CheckInModel? model;
    String? path = "checkin/weekList";
    Map<String, dynamic> data = {};
    model = await _basePostNet<CheckInModel>(
        BaseParams(CheckInModel(), path: path, data: data));
    return model;
  }

  /// path bulletscreen/list 获取弹幕列表
  /// "[mediaId]": 11017, "[startAt]": second ?? 0, "size": 10
  static Future<List<DanmuMsgsBySecond>?> getBarrageList(
      {int? mediaId, int? startAt, int? size}) async {
    List<DanmuMsgsBySecond>? model;
    String? path = "bulletscreen/list";
    Map<String, dynamic> data = {};
    data["mediaId"] = mediaId ?? 0;
    data["startAt"] = startAt ?? 0;
    data["size"] = size ?? 30; // 一次请求全部3小时的
    model = await _basePostListNet<DanmuMsgsBySecond>(
        BaseParams(DanmuMsgsBySecond(), path: path, data: data));
    return model;
  }

  /// path /comment/list 获取评论
  /// [objectId] 视频id/帖子id
  /// [parentsId] 父评论id，如果设置则为子评论列表
  /// [objectType] ContentType 内容内型
  /// [pageNum] 页码
  static Future<ListComment?> getCommentsList(int? objectId,
      {int? parentsId,
      int? pageNum,
      CommentType? objectType,
      int? pageSize}) async {
    ListComment? model;
    String? path = "comment/list";
    Map<String, dynamic> data = {};
    data["objectId"] = objectId ?? 0;
    data["parentsId"] = parentsId ?? 0;
    data["objectType"] = objectType?.index ?? CommentType.CT_Video.index;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize ?? 10;
    model = await _basePostNet<ListComment>(
        BaseParams(ListComment(), path: path, data: data));
    return model;
  }

  /// path /bulletscreen/post 发送弹幕到视频
  /// "[content]": "", "[mediaId]": 0, "publishAt": 0
  static Future sendBarrageToVideo({
    int? mediaId,
    String? content,
    Function(String)? onError,
    Function()? onSuccess,
    int? publishAt,
  }) async {
    String? path = "bulletscreen/post";
    Map<String, dynamic> data = {};
    data["mediaId"] = mediaId ?? 0;
    data["publishAt"] = publishAt ?? 0;
    data["content"] = content ?? "";
    await _basePostNet(BaseParams(null,
        path: path,
        onError: onError,
        onSuccess: (rep) => onSuccess?.call(),
        data: data));
  }

  /// path /comment/add 添加评论
  /// [objectId] 视频id/帖子id
  /// [text] 评论的为本
  /// [parentsId] 父评论id，如果设置则为回复某人
  /// [replyId] 被回复人的id
  static Future<CommentModel?> addComment(
      {int? objectId,
      String? text,
      int? parentsId,
      CommentType? objectType,
      int? replyId,
      Function(String)? onError,
      Function(CommentModel)? onSuccess}) async {
    CommentModel? model;
    String? path = "comment/add";
    Map<String, dynamic> data = {};
    data["text"] = text ?? "";
    data["objectId"] = objectId ?? 0;
    data["parentsId"] = parentsId;
    data["objectType"] = objectType?.index ?? CommentType.CT_Video.index;
    data["replyId"] = replyId;
    model = await _basePostNet<CommentModel>(BaseParams(CommentModel(),
        path: path,
        data: data,
        onError: onError,
        onSuccess: (rep) => onSuccess?.call(rep)));
    return model;
  }

  /// path media/tag/details 获取收藏列表
  /// [location] 视频类型: 1.长视频 2.短视频
  /// [sort]  排序
  /// [tagId ] 标签ID
  static Future<MediaList?> getTagDetails(
      {int? location, int? sort, int? tagId, int? pageNum}) async {
    MediaList? model;
    String? path = "media/tag/details";
    Map<String, dynamic> data = {};
    data["location"] = location;
    data["sort"] = sort;
    data["tagId"] = tagId;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  // path hGame/list   获取HGame数据
  static Future<HGameResult?> getHGameList(
      {int? id, Function(String)? onError, int? flagRank}) async {
    HGameResult? model;
    Map<String, dynamic> data = {};
    String? path = "hGame/list";
    data["pageSize"] = pageSize;
    data["typeId"] = id ?? 0;
    data["flagRank"] = flagRank ?? 0;
    model = await _basePostNet<HGameResult>(BaseParams(HGameResult(),
        path: path, data: data ?? {}, onError: onError));
    return model;
  }

  // path hGame/click   HGame点击量上报
  static Future clickHGame(
      {int? id, Function(String)? onError, Function()? onSuccess}) async {
    String? path = "hGame/click";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    await _basePostNet(
        BaseParams(null, path: path, data: data, onError: onError));
  }

  /// path user/isReceive 获取高能涩游列表
  static Future<HGameResult?> getSeGameList(
      {int? pageNum, Function(String)? onError}) async {
    HGameResult? model;
    Map<String, dynamic> data = {};
    String? path = "/seGame/list";
    data["pageNum"] = pageNum;
    data["pageSize"] = pageSize;
    model = await _basePostNet<HGameResult>(BaseParams(HGameResult(),
        path: path, data: data ?? {}, onError: onError));
    return model;
  }

  // path hGame/click   SeGame点击量上报
  static Future clickSeGame(
      {int? id, Function(String)? onError, Function()? onSuccess}) async {
    String? path = "seGame/click";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    await _basePostNet(
        BaseParams(null, path: path, data: data, onError: onError));
  }

  /// path collect/list 获取收藏列表
  /// [collectType] 1.长视频  2.短视频  3动漫  4.上门  5.帖子  6.楼凤  7.女优  8.漫画  9.写真  10.小说
  /// [type]  1.收藏  2.点赞  3.踩
  static Future<MediaList?> getCollectList(
      {MediaType? collectType, ActionType? type, int? pageNum}) async {
    MediaList? model;
    String? path = "collect/list";
    Map<String, dynamic> data = {};
    data["pageSize"] = pageSize;
    data["pageNum"] = pageNum ?? 1;
    data["type"] = type?.index ?? ActionType.Collect.index;
    data["collectType"] = collectType?.index ?? MediaType.videoLong.index;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path media/pay/history 获取媒体购买记录
  /// [isSeller] true: true:我的出售 false:我的求购
  /// [type]  MediaType 视频类型
  /// [pageNum ] 页码
  static Future<MediaList?> getPayMediaHistory(
      {bool? isSeller, MediaType? type, int? pageNum}) async {
    MediaList? model;
    String? path = "media/pay/history";
    Map<String, dynamic> data = {};
    data["isSeller"] = isSeller ?? false;
    data["type"] = type?.index ?? MediaType.comic.index;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path user/invite/list 获取用户邀请列表
  static Future<InvitedList?> getUserInvitedList({int? pageNum}) async {
    InvitedList? model;
    String? path = "user/invite/list";
    Map<String, dynamic> data = {};
    data["pageSize"] = pageSize;
    data["pageNum"] = pageNum ?? 1;
    model = await _basePostNet<InvitedList>(
        BaseParams(InvitedList(), path: path, data: data));
    return model;
  }

  /// path /advertise/click 广告点击事件上报
  static Future clickAds(
      {String? id, Function(String)? onError, Function()? onSuccess}) async {
    Map<String, dynamic> data = {};
    data["id"] = id;
    String? path = "advertise/click";
    await _basePostNet(
        BaseParams(null, path: path, data: data, onError: onError));
  }

  /// path collect/del 批量删除收藏*
  /// 批量删除收藏
  /// int [type]  1.收藏  2.点赞  3.踩
  /// List<int>  [object_id] 对象ID
  static Future delCollect(
      {MediaType? collectType,
      List<int>? objectIds,
      Function(String)? onError,
      Function()? onSuccess}) async {
    Map<String, dynamic> data = {};
    data["collectType"] = collectType?.index ?? MediaType.comic.index;
    data["objectIds"] = objectIds ?? [];
    data["type"] = ActionType.Collect.index;
    String? path = "collect/del";
    await _basePostNet(
        BaseParams(null, path: path, data: data, onError: onError));
  }

  /// path /collect/add 添加收藏到收藏列表*
  //// [collectType] 1.长视频  2.短视频  3动漫  4.上门  5.帖子  6.楼凤  7.女优  8.漫画  9.写真  10.小说
  ///  [flag]  1.收藏  2.点赞  3.踩
  ///  [object_id] 对象ID
  static Future addCollect(
      {ActionType? type,
      MediaType? collectType,
      bool? flag,
      int? objectId,
      Function()? onSuccess,
      Function(String)? onError}) async {
    String? path = "collect/add";
    Map<String, dynamic> data = {};
    data["type"] = type?.index ?? ActionType.Collect.index;
    data["collectType"] = collectType?.index;
    data["flag"] = flag ?? true;
    data["object_id"] = objectId ?? 0;
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onSuccess: (model) => onSuccess?.call(),
        onError: onError));
  }

  /// path media/short/recommendV2 获取段视频推荐列表*
  /// [type] =0:推荐；=1:免费
  static Future<MediaList?> getShortRecommend(
      {Map<String, dynamic>? data}) async {
    MediaList? model;
    String? path = "media/short/recommend";
    data?["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data ?? {}));
    return model;
  }

  /// path /media/pay 视频购买
  ///  [id] 对象ID
  ///  [payType] =1,余额购买；=2观影券购买
  static Future mediaPayAndPlay(
      {int? payType,
      int? id,
      Function()? onSuccess,
      Function(String)? onError}) async {
    String? path = "media/pay";
    Map<String, dynamic> data = {};
    data["payType"] = payType ?? 2;
    data["id"] = id ?? 0;
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onSuccess: (model) => onSuccess?.call(),
        onError: onError));
    print("付费购买成功");
  }

  /// path media/play 播放视频*
  static Future<MediaPlayModel?> playVideo(
      {Map<String, dynamic>? data, Function(String)? onError}) async {
    MediaPlayModel? model;
    String? path = "media/play";
    model = await _basePostNet<MediaPlayModel>(BaseParams(MediaPlayModel(),
        path: path, data: data ?? {}, onError: onError));
    return model;
  }

  ///path search/recommendByTag 播放页下面的推荐视频*
  static Future<MediaList?> getPlayerRecommendVideo(
      {int? pageNum, int? id, MediaType? contentType}) async {
    MediaList? model;
    String? path = "search/recommendByTag";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    data["contentType"] = contentType?.index ?? MediaType.videoLong.index;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path media/home 首页漫画分类主题*
  static Future<TopicList?> getComicTopicList(
      {int? id, int? pageNum, String? cateName}) async {
    TopicList? model;
    String? path = "$cateName/home";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = 10;
    model = await _basePostNet<TopicList>(
        BaseParams(TopicList(), path: path, data: data));
    return model;
  }

  /// path media/home 首页根据分类获取主题列表*
  static Future<CategoryTopics?> getTopicOfCategory(
      {int? id, MediaType? type}) async {
    CategoryTopics? model;
    String? path = "mediatopic/getTopicByType";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["contentType"] = type?.index ?? MediaType.comic.index;
    model = await _basePostNet<CategoryTopics>(
        BaseParams(CategoryTopics(), path: path, data: data));
    return model;
  }

  /// path %s/changeTopic 换一换主题列表*
  static Future<MediaList?> changeTopicList(
      {int? id, int? pageNum, int? pageSize, String? apiPath}) async {
    MediaList? model;
    //api/app/media/topic/details
    //api/app/comicsTopic/change
    //api/app/novelTopic/change
    String? path = "${apiPath ?? "comicsTopic"}/change";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize ?? 6;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path comics/detail  漫画详情*
  /// [id] 漫画ID
  static Future<DetailPageResponse?> getComicDetails(
      {int? id, int? pageNum}) async {
    DetailPageResponse? model;
    String? path = "comics/detail";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = 10;
    model = await _basePostNet<DetailPageResponse>(
        BaseParams(DetailPageResponse(), path: path, data: data));
    return model;
  }

  /// path %s/changeTopic 获取推荐漫画*
  static Future<MediaList?> getRecommendComics(
      {int? id, int? pageNum, int? pageSize}) async {
    MediaList? model;
    String? path = "comics/relatedComics";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize ?? 10;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path novel/relatedNovels 获取推荐小说*
  static Future<MediaList?> getRecommendNovels(
      {int? id, int? pageNum, int? pageSize}) async {
    MediaList? model;
    String? path = "novel/relatedNovels";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize ?? 10;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path comicsTopic/list 漫画专题、标签详情*
  static Future<MediaList?> getTopicDetailList(
      {required int id,
      int? pageNum,
      int? sort,
      MediaType? mediaType,
      required String apiPath}) async {
    MediaList? model;
    String? path = apiPath;
    Map<String, dynamic> data = {};
    data["id"] = id;
    data["tagId"] = id;
    data["pageNum"] = pageNum ?? 0;
    data["sort"] = sort ?? 0;
    data["pageSize"] = pageSize;
    data['location'] = mediaType?.index ?? MediaType.comic.index;
    print(data);
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path comics/author 根据漫画作者获取相关漫画*
  static Future<MediaList?> getComicsOfAuthorName(
      {required String author, int? pageNum}) async {
    MediaList? model;
    String? path = "comics/author";
    Map<String, dynamic> data = {};
    data["author"] = author;
    data["pageNum"] = pageNum ?? 0;
    data["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path search/recommendList 智能推荐详情*
  static Future<MediaList?> getAiRecommendData(
      {required int type, int? pageNum}) async {
    MediaList? model;
    String? path = "search/recommendList";
    Map<String, dynamic> data = {};
    data["categoryType"] = type;
    data["pageNum"] = pageNum ?? 0;
    data["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path preview/rankList 排行榜列表*
  static Future<MediaList?> getRankListNetData(
      {required MediaType type, int? pageNum, int? sortType}) async {
    MediaList? model;
    String? path = "preview/rankList";
    Map<String, dynamic> data = {};
    data["contentType"] = type.index;
    data["pageNum"] = pageNum ?? 0;
    data["rankType"] = sortType ?? 0;
    data["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  /// path comics/detail  请求阅读漫画章节*
  /// [id] 漫画章节ID
  static Future<PlayComicResponse?> requestChapter(
      {int? id, MediaType? type}) async {
    PlayComicResponse? model;
    String catePath =
        type == MediaType.comic ? "comicsChapter" : "novelChapter";
    String? path = "$catePath/isLook";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    model = await _basePostNet<PlayComicResponse>(
        BaseParams(PlayComicResponse(), path: path, data: data));
    return model;
  }

  /// path comics/detail  漫画章节阅读返回内容*
  /// [id] 漫画章节ID
  static Future<ChapterDetails?> getChapter({int? id, MediaType? type}) async {
    String comic = "comicsChapter/pics";
    String novel = "novelChapter/info";
    String? path = type == MediaType.comic ? comic : novel;
    ChapterDetails? model;
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    model = await _basePostNet<ChapterDetails>(
        BaseParams(ChapterDetails(), path: path, data: data));
    return model;
  }

  /// path novel/detail  小说详情*
  /// [id] 漫画ID
  static Future<DetailPageResponse?> getNovelDetails(
      {int? id, int? pageNum}) async {
    DetailPageResponse? model;
    String? path = "novel/detail";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = 10;
    model = await _basePostNet<DetailPageResponse>(
        BaseParams(DetailPageResponse(), path: path, data: data));
    return model;
  }

  /// path media/home 首页视频专题主题
  static Future<TopicList?> getHomeTopicList({int? id, int? pageNum}) async {
    TopicList? model;
    String? path = "media/home";
    Map<String, dynamic> data = {};
    data["id"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = 10;
    model = await _basePostNet<TopicList>(
        BaseParams(TopicList(), path: path, data: data));
    return model;
  }

  /// path comicsTag/listById 漫画标签分类搜索
  /// path novelTag/listByTag 小说标签分类搜索
  /// path tag/listByTagSort  视频标签分类搜索
  static Future<MediaList?> categorySearch(
      {MediaType? contentType,
      int? tagId,
      int? payType,
      int? year,
      int? month,
      int? sort,
      int? updateStatus,
      int? area,
      int? pageNum,
      String? apiPath}) async {
    MediaList? model;
    String? path = apiPath ?? "comicsTag/listById";
    Map<String, dynamic> data = {};
    data["id"] = tagId ?? 0;
    data["payType"] = payType;
    data["year"] = year ?? 0;
    data["month"] = month ?? 0;
    data["sort"] = sort ?? 0;
    data["updateStatus"] = updateStatus ?? 0;
    data["area"] = area ?? 0;
    data["contentType"] = contentType?.index ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = 10;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));
    return model;
  }

  static String bookStoreComicPath = "comics/trackList";
  static String bookStoreNovelPath = "novel/trackList";

  /// 获取书架数据
  /// path comics/trackList 漫画
  /// path novel/trackList 小说
  static Future<MediaList?> getBookStoreNetData(
      {int? pageNum, SortMediaType? sort, String? apiPath}) async {
    MediaList? model;
    String? path = apiPath ?? "comics/trackList";
    Map<String, dynamic> data = {};
    data["sort"] = sort?.index ?? SortMediaType.MT_Commomet.index;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = 10;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data));

    return model;
  }

  /// 获取标签分类
  /// path tag/tagsByType
  static Future<CategoryTagModel?> getCategoryTagMap() async {
    CategoryTagModel? model;
    String? path = "tag/tagsByType";
    Map<String, dynamic> data = {};
    model = await _basePostNet<CategoryTagModel>(
        BaseParams(CategoryTagModel(), path: path, data: data));
    return model;
  }

  /// 根据标签分类获取标签列表
  /// path tag/getTagType
  static Future<TagTypeNetModel?> getTagListById(int id) async {
    TagTypeNetModel? model;
    String? path = "tag/getTagType";
    Map<String, dynamic> data = {};
    data["id"] = id;
    model = await _basePostNet<TagTypeNetModel>(
        BaseParams(TagTypeNetModel(), path: path, data: data));
    return model;
  }

  /// path preview/epCollection 获取新番预告合集数据*
  static Future<EpisodePreviewModel?> getEpisodePreviewData({int? year}) async {
    EpisodePreviewModel? model;
    String? path = "preview/epCollection";
    Map<String, dynamic> data = {};
    data["year"] = year;
    model = await _basePostNet<EpisodePreviewModel>(
        BaseParams(EpisodePreviewModel(), path: path, data: data));
    return model;
  }

  static Future<YearList?> getPreviewYearList() async {
    YearList? model;
    String? path = "preview/getYear";
    Map<String, dynamic> data = {};
    model = await _basePostNet<YearList>(
        BaseParams(YearList(), path: path, data: data));
    return model;
  }

  /// path preview/epList 获取新番预告详情*
  static Future<PreviewDetails?> getPreviewDetail({int? id}) async {
    PreviewDetails? model;
    String? path = "preview/epList";
    Map<String, dynamic> data = {};
    data["nowPreviewId"] = id;
    model = await _basePostNet<PreviewDetails>(
        BaseParams(PreviewDetails(), path: path, data: data));
    return model;
  }

  /// path hope/activity 获取许愿池列表*
  static Future<WishedListModel?> getWishedList() async {
    WishedListModel? model;
    String? path = "hope/activity";
    Map<String, dynamic> data = {};
    model = await _basePostNet<WishedListModel>(
        BaseParams(WishedListModel(), path: path, data: data));
    return model;
  }

  /// path hope/details 获取许愿池列表*
  static Future<WishedActiveInfoDetail?> getWishedActiveInfoData(
      {int? id, int? pageNum}) async {
    WishedActiveInfoDetail? model;
    String? path = "hope/details";
    Map<String, dynamic> data = {};
    data["activityId"] = id ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<WishedActiveInfoDetail>(
        BaseParams(WishedActiveInfoDetail(), path: path, data: data));
    return model;
  }

  /// path hope/publish 提交许愿内容*
  static Future submitWishContent(
      {int? id,
      String? reason,
      String? title,
      Function? onSuccess,
      Function? onError}) async {
    String? path = "hope/publish";
    Map<String, dynamic> data = {};
    data["activityId"] = id ?? 0;
    data["reason"] = reason ?? "";
    data["title"] = title ?? "";
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onSuccess: onSuccess?.call(),
        onError: onError?.call()));
  }

  /// path hope/details 获取许愿池列表*
  static Future wishSponsor({int? id}) async {
    String? path = "hope/collet";
    Map<String, dynamic> data = {};
    data["hopeId"] = id ?? 0;
    await _basePostNet(BaseParams(null, path: path, data: data));
  }

  /// path [POST] dailypicks/pickDetails 获取每日精选当日视频列表*
  static Future<MediaList?> getDailyPicksDetails(
      {Map<String, dynamic>? data}) async {
    MediaList? model;
    DateTime now = DateTime.now();
    String? path = "dailypicks/pickDetail";
    Map<String, dynamic> params = {};
    params["day"] = data?["day"] ?? now.day;
    params["month"] = data?["month"] ?? now.month;
    params["year"] = data?["year"] ?? now.year;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: params));
    return model;
  }

  /// path [POST] dailypicks/pickHome 获取每日精选首页日期列表*
  static Future<MediaList?> getDailyPicksHome(
      {Map<String, dynamic>? data}) async {
    MediaList? model;
    String? path = "dailypicks/pickHome";
    data?["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data ?? {}));
    return model;
  }

  /// path [POST] short/recommendV2 获取短视频播放页推荐视频*
  static Future<MediaList?> getHomeShortMedia(
      {Map<String, dynamic>? data}) async {
    MediaList? model;
    String? path = "media/short/recommendV2";
    data?["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data ?? {}));
    return model;
  }

  /// path [GET] media/topic/details 获取首页分类下的视频*
  static Future<MediaList?> getHomeCategoryMedia(
      {Map<String, dynamic>? data}) async {
    MediaList? model;
    String? path = "media/category/list";
    data?["pageSize"] = pageSize;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data ?? {}));
    return model;
  }

  ///path [POST] search/details 搜索*
  static Future<MediaList?> getSearchResultData(
      {String? content, int? pageNum, int? type}) async {
    MediaList? model;
    String? path = "search/details";
    Map<String, dynamic> data = {};
    data["content"] = content ?? "";
    data["type"] = type ?? MediaType.comic.index;
    data["pageSize"] = pageSize;
    data["pageNum"] = pageNum ?? 1;
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data ?? {}));
    return model;
  }

  ///path [POST] search/everydaySearch 搜索页面排行榜视频*
  static Future<MediaList?> getSearchRankMediaList(
      {MediaType? type, int? pageNum, int? sort}) async {
    MediaList? model;
    String? path = "search/everydaySearch";
    Map<String, dynamic> data = {};
    data["categoryType"] = type?.index ?? MediaType.videoLong.index;
    data["sort"] = sort ?? 0;
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    print(data);
    model = await _basePostNet<MediaList>(
        BaseParams(MediaList(), path: path, data: data ?? {}));
    return model;
  }

  /// path [POST] hotsearch/list 热搜词*
  static Future<HotSearchModel?> getHotSearchApi(
      {Map<String, dynamic>? data}) async {
    HotSearchModel? model;
    String? path = "hotsearch/list";
    model = await _basePostNet<HotSearchModel>(
        BaseParams(HotSearchModel(), path: path, data: data ?? {}));
    return model;
  }

  /// path [POST] user/qrcode 获取用户二维码凭证*
  static Future<QrModel?> getUserQrCode({Map<String, dynamic>? data}) async {
    QrModel? model;
    String? path = "user/qrcode";
    model = await _basePostNet<QrModel>(
        BaseParams(QrModel(), path: path, data: data ?? {}));
    return model;
  }

  /// path [post] user/isCert 保存账号凭证任务
  static Future saveUserQrCodeTask() {
    String? path = "user/isCert";
    Map<String, dynamic> data = {};
    return _basePostNet(BaseParams(null, path: path, data: data));
  }

  /// path user/shareRecord 添加收藏到收藏列表*
  ///  [recordType]  记录类型
  ///  [shareType] 分享类型
  static Future addTaskRecord(
      {int? shareType, int? recordType, Function(String)? onError}) async {
    String? path = "user/shareRecord";
    Map<String, dynamic> data = {};
    data["shareType"] = shareType ?? ShareType.showTypeLongMedia.index;
    data["recordType"] = recordType ?? RecordType.recordTypeShare.index;
    await _basePostNet(
        BaseParams(null, path: path, data: data, onError: onError));
  }

  /// path wlgame/getBalance 查询用户余额
  static Future<UserBalanceModel?> getUserBalance(
      {Function()? onSuccess, Function(String)? onError}) async {
    UserBalanceModel? model;
    String? path = "wlgame/getBalance";
    model = await _basePostNet<UserBalanceModel>(BaseParams(UserBalanceModel(),
        onSuccess: onSuccess?.call(), onError: onError, path: path, data: {}));
    return model;
  }

  /// path [GET] ping/config 获取APP配置文件*
  static Future<ConfigModel?> getAppConfig(
      {Map<String, dynamic>? data,
      Function()? onSuccess,
      Function(String)? onError}) async {
    ConfigModel? model;
    String? path = "ping/config";
    model = await _baseGetNet<ConfigModel>(BaseParams(ConfigModel(),
        onSuccess: onSuccess?.call(),
        onError: onError,
        path: path,
        data: data ?? {}));
    return model;
  }

  /// path user/qrcode/info 扫描二维码登陆账号
  static Future<UserInfo?> scanQrCodeAndLogin(
      {Function(String)? onError, Function? onSuccess, String? code}) async {
    UserInfo? model;
    String? path = "user/qrcode/info";
    Map<String, dynamic> data = {};
    data["value"] = code ?? "";
    model = await _basePostNet<UserInfo>(BaseParams(UserInfo(),
        onSuccess: onSuccess?.call(),
        onError: onError,
        path: path,
        data: data));
    return model;
  }

  /// path /user/info 获取用户资料
  static Future<UserInfo?> getUpdateUserInfo(
      {Function()? onSuccess, Function(String)? onError}) async {
    UserInfo? model;
    model = await _basePostNet<UserInfo>(BaseParams(UserInfo(),
        onSuccess: onSuccess?.call(),
        onError: onError,
        path: "user/info",
        data: {}));
    ShareKeys shareKeys = Get.find<ShareKeys>();
    shareKeys.setUserInfo(model);

    return model;
  }

  /// path /user/info/modify 更改用户资料
  static Future setUserInformation({
    Function(String)? onError,
    Function()? onSuccess,
    String? nickName,
    String? age, //年龄
    String? avatar, //头像
    int? gender, //性别
    String? introduction, //简介
  }) async {
    String? path = "user/info/modify";
    Map<String, dynamic> data = {};

    if (nickName != null) data["nickName"] = nickName;
    if (age != null) data["age"] = age;
    if (avatar != null) data["avatar"] = avatar;
    if (gender != null) data["gender"] = gender;
    if (introduction != null) data["introduction"] = introduction;

    await _basePostNet(BaseParams(null,
        onError: onError,
        onSuccess: (e) => onSuccess?.call(),
        path: path,
        data: data));
  }

  /// path user/avatar 获取用户头像
  static Future<UserAvatarList?> getUserAvatar({
    Function(String)? onError,
  }) async {
    UserAvatarList? model;
    String? path = "user/avatar";
    Map<String, dynamic> data = {};
    model = await _basePostNet<UserAvatarList>(
        BaseParams(UserAvatarList(), onError: onError, path: path, data: data));
    return model;
  }

  /// path login/bindMobile 绑定手机号码
  static Future<UserInfo?> bindingPhone(
      {Function(String)? onError,
      String? country,
      String? mobile,
      String? captcha,
      Function(UserInfo)? onSuccess}) async {
    UserInfo? model;
    String? path = "login/bindMobile";
    Map<String, dynamic> data = {};
    data["country"] = country ?? "";
    data["mobile"] = mobile ?? "";
    data["captcha"] = captcha ?? "";
    model = await _basePostNet<UserInfo>(BaseParams(UserInfo(),
        onSuccess: (res) => onSuccess?.call(res),
        onError: onError,
        path: path,
        data: data));
    return model;
  }

  /// path login/bindMobile 绑定手机号码
  static Future<UserInfo?> loginByPhone(
      {Function(String)? onError,
      String? country,
      String? mobile,
      String? captcha,
      Function(UserInfo)? onSuccess}) async {
    UserInfo? model;
    String? path = "login/phone";
    Map<String, dynamic> data = {};
    data["country"] = country ?? "";
    data["mobile"] = mobile ?? "";
    data["captcha"] = captcha ?? "";
    model = await _basePostNet<UserInfo>(BaseParams(UserInfo(),
        onSuccess: (res) => onSuccess?.call(res),
        onError: onError,
        path: path,
        data: data));
    return model;
  }

  /// path login/captcha 发送短信验证码
  static Future getCaptcha(
      {Function(String)? onError,
      String? country,
      String? mobile,
      Function? onSuccess}) async {
    String? path = "login/captcha";
    Map<String, dynamic> data = {};
    data["country"] = country ?? "";
    data["mobile"] = mobile ?? "";
    await _basePostNet(BaseParams(null,
        path: path,
        data: data,
        onError: onError,
        onSuccess: (rep) => onSuccess?.call(rep)));
  }

  /// path upload/img 图片上传
  static Future<UploadImageRep?> uploadImg(
      {Function(String)? onError,
      FormData? formData,
      Function(int, int)? onSendProgress,
      Function? onSuccess}) async {
    UploadImageRep? model;
    String? path = "upload/img";
    model = await _baseUploadNet<UploadImageRep>(path, formData ?? FormData(),
        onSendProgress: onSendProgress, type: UploadImageRep());
    return model;
  }

  /// path ai/category 获取AI分类详情
  static Future<AiCateGoryInfo?> getAiCategoryInfo(
      {Function(String)? onError,
      int? aiType,
      Function(UserInfo)? onSuccess}) async {
    AiCateGoryInfo? model;
    String? path = "ai/category";
    Map<String, dynamic> data = {};
    data["aiType"] = aiType ?? "";
    model = await _basePostNet<AiCateGoryInfo>(BaseParams(AiCateGoryInfo(),
        onSuccess: (res) => onSuccess?.call(res),
        onError: onError,
        path: path,
        data: data));
    return model;
  }

  /// path ai/getAITagList 获取AI标签列表
  static Future<AiTagStringList?> getAiTagList(
      {Function(String)? onError,
      int? pageNum,
      Function(UserInfo)? onSuccess}) async {
    AiTagStringList? model;
    String? path = "ai/getAITagList";
    Map<String, dynamic> data = {};
    data["pageNum"] = pageNum ?? 1;
    data["pageSize"] = pageSize;
    model = await _basePostNet<AiTagStringList>(BaseParams(AiTagStringList(),
        onSuccess: (res) => onSuccess?.call(res),
        onError: onError,
        path: path,
        data: data));
    return model;
  }

  /// path ai/getFaceList 获取AI标签列表
  static Future<AiTFaceImageList?> getAiFaceImageList(
      {Function(String)? onError,
      int? aiType,
      Function(UserInfo)? onSuccess}) async {
    AiTFaceImageList? model;
    String? path = "ai/getFaceList";
    Map<String, dynamic> data = {};
    data["aiType"] = aiType ?? 1;
    model = await _basePostNet<AiTFaceImageList>(BaseParams(AiTFaceImageList(),
        onSuccess: (res) => onSuccess?.call(res),
        onError: onError,
        path: path,
        data: data));
    return model;
  }

  /// path aitask/addAITaskList 添加AI生成任务
  static Future<void> addAiTaskToGenerate(
      {Function(String)? onError,
      AiTaskRequestModel? aiTaskReq,
      Function(UserInfo)? onSuccess}) async {
    String? path = "aitask/addAITaskList";
    Map<String, dynamic> data = {};
    data = aiTaskReq?.toJson() ?? {};
    await _basePostNet(BaseParams(null,
        onSuccess: (res) => onSuccess?.call(res),
        onError: onError,
        path: path,
        data: data));
  }

  /// path aitask/getAITaskList 获取AI生成任务
  static Future<AiTaskListRespModel?> getAiTaskList(
      {Function(String)? onError,
      int? pageNum,
      AiTaskType? aiType,
      AiTaskStatus? status,
      Function(UserInfo)? onSuccess}) async {
    AiTaskListRespModel? model;
    String? path = "aitask/getAITaskList";
    Map<String, dynamic> data = {};
    data['pageNum'] = pageNum ?? 1;
    data['aiType'] = aiType?.index ?? AiTaskType.aiChangeFace.index;
    if (status != null) {
      data['AITaskStatus'] = status.index;
    }
    model = await _basePostNet<AiTaskListRespModel>(BaseParams(
        AiTaskListRespModel(),
        onSuccess: (res) => onSuccess?.call(res),
        onError: onError,
        path: path,
        data: data));
    return model;
  }

  static Future<T?> _baseGetNet<T>(BaseParams params) async {
    T? result;
    String prefix = "/api/app/";
    String fullPath = "$prefix${params.path!}";
    String apiKey = await NetWorkCreator.sign(fullPath);
    final Options options = Options(headers: {"x-api-key": apiKey});
    if ((params.path ?? "").isNotEmpty) {
      var response = await get<T, T>(fullPath,
          options: options,
          decodeType: params.type,
          data: params.data,
          queryParameters: params.data);
      response.when(success: (T? model) async {
        if (model != null) {
          result = model;
          params.onSuccess?.call(model);
        }
      }, failure: (String msg, int code) {
        log.e("_network_get_error",
            "_network_error: router:$fullPath,errorMsg:$msg");
        params.onError?.call(msg);
      });
    }
    return result;
  }

  static Future<T?> _basePostNet<T>(BaseParams params) async {
    T? result;
    String prefix = "/api/app/";
    String fullPath = "$prefix${params.path!}";
    String apiKey = await NetWorkCreator.sign(fullPath);
    final Options options = Options(headers: {"x-api-key": apiKey});
    if ((params.path ?? "").isNotEmpty) {
      var response = await post<T, T>(fullPath,
          options: options, decodeType: params.type, data: params.data);
      response.when(success: (T? model) async {
        result = model;
        params.onSuccess?.call(model);
      }, failure: (String msg, int code) async {
        log.i("_network_post_error ",
            "_network_error: router:$fullPath,errorMsg:$msg");
        ShareKeys shareKeys = Get.find();
        await FirebaseUtils.firebaseLogEvent(
            eventName: "basePostNetFailed",
            routePath: Get.currentRoute,
            eventArgs: {
              "path": fullPath,
              "err": msg,
              "baseUri": shareKeys.baseUrl
            });
        params.onError?.call(msg);
      });
    }
    return result;
  }

  // static Future _baseDownloadNet({String? path, String? savePath}) async {
  //   if ((path ?? "").isNotEmpty) {
  //     var response = await download(
  //       path!,
  //       savePath,
  //     );
  //   }
  // }

  static Future<List<T>?> _basePostListNet<T>(BaseParams params) async {
    List<T>? result;
    String prefix = "/api/app/";
    if ((params.path ?? "").isNotEmpty) {
      String fullPath = "$prefix${params.path!}";
      String apiKey = await NetWorkCreator.sign(fullPath);
      final Options options = Options(headers: {"x-api-key": apiKey});

      var response = await post<T, List<T>>(fullPath,
          options: options, decodeType: params.type, data: params.data);
      response.when(success: (List<T>? model) async {
        result = model;
        params.onSuccess?.call(model);
      }, failure: (String msg, int code) {
        log.e("_network_post_list_error",
            "_network_error: router:${params.path},errorMsg:$msg");
        params.onError?.call(msg);
      });
    }
    return result;
  }

  static Future<T?> _baseUploadNet<T>(String path, FormData formData,
      {T? type, Function(int, int)? onSendProgress}) async {
    T? result;
    String prefix = "/api/app/";
    String fullPath = "$prefix$path";
    String apiKey = await NetWorkCreator.sign(fullPath);
    final Options options = Options(headers: {"x-api-key": apiKey});

    if (path.isNotEmpty) {
      var response = await post<T, T>(fullPath,
          options: options,
          decodeType: type,
          onSendProgress: onSendProgress,
          data: formData);

      response.when(success: (T? model) async {
        if (model != null) {
          result = model;
        }
      }, failure: (String msg, int code) {
        log.e("_network_upload_error",
            "_network_error: router:$fullPath,errorMsg:$msg");
      });
    }
    return result;
  }
}

class BaseParams<T> {
  T? type;
  String? path;
  Function(T? rep)? onSuccess;
  Function(String)? onError;
  Map<String, dynamic>? data;

  BaseParams(this.type, {this.onError, this.path, this.onSuccess, this.data});
}
