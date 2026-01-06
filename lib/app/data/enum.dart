// TopicShowType Enum类
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
  gameCategoryBY,
  gameCategorySX,
  gameCategoryQP,
  gameCategoryDZ,
  gameCategoryTY,
  gameCategoryHT, // 玩过
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
