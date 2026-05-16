import 'package:flutter/foundation.dart';

import 'package:get/get.dart';
import 'package:quick_cat_client/app/modules/home/home_game_page/controllers/game_web_view_controller.dart';
import 'package:quick_cat_client/app/modules/withdraw_cash_bank/views/withdraw_type_view.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../conf/api_res.dart';
import '../../plugins_utils/VideoPlayer/fijk_player.dart';
import '../../utils/AppDeferredLoad.dart';
import '../../utils/app_util.dart';
import '../../utils/toast_util.dart';
import '../data/address.dart';
import '../data/share_key.dart';
import '../modules/about_us_page/bindings/about_us_page_binding.dart';
import '../modules/about_us_page/views/about_us_page_view.dart';
import '../modules/ai_change_face_page/bindings/ai_change_face_page_binding.dart';
import '../modules/ai_change_face_page/views/ai_change_face_page_view.dart';
import '../modules/ai_recommend_page/bindings/ai_recommend_page_binding.dart';
import '../modules/ai_recommend_page/views/ai_recommend_page_view.dart';
import '../modules/ai_task_list_page/bindings/ai_task_list_page_binding.dart';
import '../modules/ai_task_list_page/views/ai_task_list_page_view.dart';
import '../modules/bill_record_manage/bindings/bill_record_binding.dart';
import '../modules/bill_record_manage/views/bill_record_list.dart';
import '../modules/bill_record_manage/views/bill_record_page_view.dart';
import '../modules/book_store_page/bindings/book_store_page_binding.dart';
import '../modules/book_store_page/views/book_store_page_view.dart';
import '../modules/category_detail_page/bindings/category_detail_page_binding.dart';
import '../modules/category_detail_page/views/category_detail_page_view.dart';
import '../modules/comic_detail_page/bindings/comic_detail_page_binding.dart';
import '../modules/comic_detail_page/views/comic_detail_page_view.dart';
import '../modules/comic_reader_page/bindings/comic_reader_page_binding.dart';
import '../modules/comic_reader_page/views/comic_reader_page_view.dart';
import '../modules/comic_wished_page/bindings/comic_wished_page_binding.dart';
import '../modules/comic_wished_page/views/comic_wished_page_view.dart';
import '../modules/comic_wished_page/views/wished_active_page.dart';
import '../modules/comic_wished_page/views/wishing_page.dart';
import '../modules/custom_service_page/bindings/custom_service_page_binding.dart';
import '../modules/custom_service_page/views/custom_service_page_view.dart';
import '../modules/episode_preview_page/bindings/episode_preview_page_binding.dart';
import '../modules/episode_preview_page/views/episode_preview_page_view.dart';
import '../modules/episode_preview_page/views/preview_image_viewer.dart';
import '../modules/game_details_page/bindings/game_details_page_binding.dart';
import '../modules/game_details_page/views/game_details_page_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/home_game_page/bindings/home_game_page_binding.dart';
import '../modules/home/home_game_page/controllers/home_game_page_controller.dart';
import '../modules/home/home_game_page/views/game_web_view_page.dart';
import '../modules/home/home_game_page/views/home_game_page_view.dart';
import '../modules/home/home_index_web/views/home_index_web_view.dart';
import '../modules/home/home_mine_center/views/home_mine_center_view.dart';
import '../modules/home/home_post_page/views/home_post_page_view.dart';
import '../modules/home/home_recommend_page/views/home_recommend_page_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/invited_page/bindings/invited_page_binding.dart';
import '../modules/invited_page/views/invited_page_view.dart';
import '../modules/message_center_page/bindings/message_center_page_binding.dart';
import '../modules/message_center_page/views/message_center_page_view.dart';
import '../modules/message_center_page/views/system_message_page_view.dart';
import '../modules/mine_collect_page/bindings/mine_collect_page_binding.dart';
import '../modules/mine_collect_page/views/mine_collect_page_view.dart';
import '../modules/my_cache_page/bindings/my_cache_page_binding.dart';
import '../modules/my_cache_page/views/my_cache_page_view.dart';
import '../modules/novel_detail_page/bindings/novel_detail_page_binding.dart';
import '../modules/novel_detail_page/views/novel_detail_page_view.dart';
import '../modules/novel_reader_page/bindings/novel_reader_page_binding.dart';
import '../modules/novel_reader_page/views/novel_reader_page_view.dart';
import '../modules/post_detail_page/bindings/post_detail_page_binding.dart';
import '../modules/post_detail_page/views/post_detail_page_view.dart';
import '../modules/post_topic_page/bindings/post_topic_page_binding.dart';
import '../modules/post_topic_page/views/post_topic_page_view.dart';
import '../modules/rank_list_page/bindings/rank_list_page_binding.dart';
import '../modules/rank_list_page/views/rank_list_page_view.dart';
import '../modules/redeem_code_page/bindings/redeem_code_page_binding.dart';
import '../modules/search_page/bindings/search_page_binding.dart';
import '../modules/search_page/views/search_page_view.dart';
import '../modules/setting_page/bindings/setting_page_binding.dart';
import '../modules/setting_page/views/account_find_page.dart';
import '../modules/setting_page/views/phone_binding_page.dart';
import '../modules/setting_page/views/scan_qr_code_page.dart';
import '../modules/setting_page/views/set_user_avatar.dart';
import '../modules/setting_page/views/setting_page_view.dart';
import '../modules/short_video_player/bindings/short_video_player_binding.dart';
import '../modules/short_video_player/views/short_video_player_view.dart';
import '../modules/splash_page/bindings/splash_page_binding.dart';
import '../modules/sub_terms_page/bindings/sub_terms_page_binding.dart';
import '../modules/tag_detail_page/bindings/tag_detail_page_binding.dart';
import '../modules/tag_detail_page/views/tag_detail_page_view.dart';
import '../modules/task_center_page/bindings/task_center_page_binding.dart';
import '../modules/task_center_page/views/acativity_web_page.dart';
import '../modules/task_center_page/views/activity_center_page.dart';
import '../modules/task_center_page/views/reward_history_page.dart';
import '../modules/task_center_page/views/weekly_check_in.dart';
import '../modules/task_center_page/views/welfare_task_page_view.dart';
import '../modules/ticket_manage_page/bindings/ticket_manage_page_binding.dart';
import '../modules/ticket_manage_page/views/ticket_manage_page_view.dart';
import '../modules/topic_detail_page/bindings/topic_detail_page_binding.dart';
import '../modules/topic_detail_page/views/topic_detail_page_view.dart';
import '../modules/user_terms_page/bindings/user_terms_page_binding.dart';
import '../modules/video_player_page/bindings/video_player_page_binding.dart';
import '../modules/video_player_page/views/video_player_page_view.dart';
import '../modules/vip_center_page/bindings/vip_center_page_binding.dart';
import '../modules/vip_center_page/views/vip_center_page_view.dart';
import '../modules/watch_history_page/bindings/watch_history_page_binding.dart';
import '../modules/watch_history_page/views/watch_history_page_view.dart';
import '../modules/withdraw_cash_bank/bindings/withdraw_cash_bank_binding.dart';
import '../modules/withdraw_cash_bank/views/binding_bank_card.dart';
import '../modules/withdraw_cash_bank/views/withdraw_cash_bank_view.dart';

// 🐦 Flutter imports:

// 📦 Package imports:

// 🌎 Project imports:

import '../modules/redeem_code_page/views/redeem_code_page_view.dart'
    deferred as redeem_code_page_view;

import '../modules/splash_page/views/splash_page_view.dart'
    deferred as splash_page_view;
import '../modules/sub_terms_page/views/sub_terms_page_view.dart'
    deferred as sub_terms_page_view;

import '../modules/user_terms_page/views/user_terms_page_view.dart'
    deferred as user_terms_page_view;

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_PAGE;

  static final routes = [
    GetPage(
        name: _Paths.HOME,
        page: () => const HomeView(),
        binding: HomeBinding(),
        children: [
          GetPage(
            name: _Paths.HOME_INDEX_WEB,
            page: () => HomeIndexWebView(),
            // binding: HomeIndexWebBinding(),
          ),
          GetPage(
            name: _Paths.HOME_MINE_CENTER,
            page: () => const HomeMineCenterView(),
            // binding: HomeMineCenterBinding(),
          ),
          GetPage(
            name: _Paths.HOME_RECOMMEND_PAGE,
            page: () => const HomeRecommendPageView(),
            // binding: HomeRecommendPageBinding(),
          ),
          GetPage(
            name: _Paths.HOME_HOME_GAME_PAGE,
            page: () => const HomeGamePageView(),
            // binding: HomeGamePageBinding(),
          ),
          GetPage(
            name: _Paths.HOME_HOME_POST_PAGE,
            page: () => const HomePostPageView(),
            // binding: HomePostPageBinding(),
          )
        ]),
    GetPage(
      name: _Paths.SPLASH_PAGE,
      page: () => AppDeferredWidget(
          libraryLoader: splash_page_view.loadLibrary,
          builder: () => splash_page_view.SplashPageView()),
      binding: SplashPageBinding(),
    ),
    GetPage(
      name: _Paths.REDEEM_CODE_PAGE,
      page: () => AppDeferredWidget(
          libraryLoader: redeem_code_page_view.loadLibrary,
          builder: () => redeem_code_page_view.RedeemCodePageView()),
      binding: RedeemCodePageBinding(),
    ),
    GetPage(
      name: _Paths.VIP_CENTER_PAGE,
      page: () => const VipCenterPageView(),
      binding: VipCenterPageBinding(),
    ),
    GetPage(
      name: _Paths.SETTING_PAGE,
      page: () => const SettingPageView(),
      binding: SettingPageBinding(),
    ),
    GetPage(
      name: _Paths.SET_USER_AVATAR_PAGE,
      page: () => const SetUserAvatarPage(),
      binding: SettingPageBinding(),
    ),
    GetPage(
      name: _Paths.SET_ACCOUNT_FIND,
      page: () => const AccountFindPage(),
      binding: SettingPageBinding(),
    ),
    GetPage(
      name: _Paths.SCAN_QR_CODE,
      page: () => const ScanQrCodePageView(),
      binding: SettingPageBinding(),
    ),
    GetPage(
      name: _Paths.BIND_MOBILE_PAGE,
      page: () => const PhoneBindingPage(),
      binding: SettingPageBinding(),
    ),
    GetPage(
      name: _Paths.USER_TERMS_PAGE,
      page: () => AppDeferredWidget(
          libraryLoader: user_terms_page_view.loadLibrary,
          builder: () => user_terms_page_view.UserTermsPageView()),
      binding: UserTermsPageBinding(),
    ),
    GetPage(
      name: _Paths.SUB_TERMS_PAGE,
      page: () => AppDeferredWidget(
          libraryLoader: sub_terms_page_view.loadLibrary,
          builder: () => sub_terms_page_view.SubTermsPageView()),
      binding: SubTermsPageBinding(),
    ),
    GetPage(
      name: _Paths.WELFARE_TASK_PAGE,
      page: () => const WelfareTaskPageView(),
      binding: TaskCenterPageBinding(),
    ),
    GetPage(
      name: _Paths.WEEKLY_CHECK_TASK_PAGE,
      page: () => const WeeklyCheckInPageView(),
      binding: TaskCenterPageBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVITY_CENTER_PAGE,
      page: () => const ActivityCenterPageView(),
      binding: TaskCenterPageBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVITY_WEB_PAGE,
      page: () => const ActivityWebPageView(),
      binding: TaskCenterPageBinding(),
    ),
    GetPage(
      name: _Paths.TICKET_MANAGE_PAGE,
      page: () => const TicketManagePageView(),
      binding: TicketManagePageBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGE_CENTER_PAGE,
      page: () => const MessageCenterPageView(),
      binding: MessageCenterPageBinding(),
    ),
    GetPage(
      name: _Paths.SYSTEM_MESSAGE_PAGE,
      page: () => const SystemMessagePageView(),
      binding: MessageCenterPageBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT_US_PAGE,
      page: () => const AboutUsPageView(),
      binding: AboutUsPageBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOM_SERVICE_PAGE,
      page: () => const CustomServicePageView(),
      binding: CustomServicePageBinding(),
    ),
    GetPage(
      name: _Paths.BILL_RECORD_PAGE_VIEW,
      page: () => const BillRecordPageView(),
      binding: BillRecordBinding(),
    ),
    GetPage(
      name: _Paths.BILL_RECORD_LIST,
      page: () => const BillRecordListView(),
    ),
    GetPage(
      name: _Paths.VIDEO_PLAYER_PAGE,
      page: () => VideoPlayerPageView(),
      binding: VideoPlayerPageBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH_PAGE,
      page: () => const SearchPageView(),
      binding: SearchPageBinding(),
    ),
    GetPage(
      name: _Paths.TOPIC_DETAIL_PAGE,
      page: () => const TopicDetailPageView(),
      binding: TopicDetailPageBinding(),
    ),
    GetPage(
      name: _Paths.MINE_COLLECT_PAGE,
      page: () => const MineCollectPageView(),
      binding: MineCollectPageBinding(),
    ),
    GetPage(
      name: _Paths.POST_DETAILE_PAGE,
      page: () => const PostDetailPageView(),
      binding: PostDetailPageBinding(),
    ),
    GetPage(
      name: _Paths.POST_TOPIC_PAGE,
      page: () => const PostTopicPageView(),
      binding: PostTopicPageBinding(),
    ),
    GetPage(
      name: _Paths.TAG_DETAIL_PAGE,
      page: () => const TagDetailPageView(),
      binding: TagDetailPageBinding(),
    ),
    GetPage(
      name: _Paths.WITHDRAW_CASH_BANK,
      page: () => const WithdrawCashBankView(),
      binding: WithdrawCashBankBinding(),
    ),
    GetPage(
      name: _Paths.BINDING_BANK_CARD,
      page: () => const BindingBankCardPageView(),
      binding: WithdrawCashBankBinding(),
    ),
    GetPage(
      name: _Paths.ENTER_GAME_WEB_VIEW,
      page: () => const GameWebViewPage(),
      binding: HomeGamePageBinding(),
    ),
    GetPage(
      name: _Paths.SHORT_VIDEO_PLAYER,
      page: () => const ShortVideoPlayerView(),
      binding: ShortVideoPlayerBinding(),
    ),
    GetPage(
      name: _Paths.INVITED_PAGE,
      page: () => const InvitedPageView(),
      binding: InvitedPageBinding(),
    ),
    GetPage(
      name: _Paths.GAME_DETAILS_PAGE,
      page: () => const GameDetailsPageView(),
      binding: GameDetailsPageBinding(),
    ),
    GetPage(
      name: _Paths.COMIC_DETAIL_PAGE,
      page: () => const ComicDetailPageView(),
      binding: ComicDetailPageBinding(),
    ),
    GetPage(
      name: _Paths.COMIC_READER_PAGE,
      page: () => const ComicReaderPageView(),
      binding: ComicReaderPageBinding(),
    ),
    GetPage(
      name: _Paths.NOVEL_DETAIL_PAGE,
      page: () => const NovelDetailPageView(),
      binding: NovelDetailPageBinding(),
    ),
    GetPage(
      name: _Paths.NOVEL_READER_PAGE,
      page: () => const NovelReaderPageView(),
      binding: NovelReaderPageBinding(),
    ),
    GetPage(
      name: _Paths.CATEGORY_DETAIL_PAGE,
      page: () => const CategoryDetailPageView(),
      binding: CategoryDetailPageBinding(),
    ),
    GetPage(
      name: _Paths.BOOK_STORE_PAGE,
      page: () => const BookStorePageView(),
      binding: BookStorePageBinding(),
    ),
    GetPage(
      name: _Paths.RANK_LIST_PAGE,
      page: () => const RankListPageView(),
      binding: RankListPageBinding(),
    ),
    GetPage(
      name: _Paths.EPISODE_PREVIEW_PAGE,
      page: () => const EpisodePreviewPageView(),
      binding: EpisodePreviewPageBinding(),
    ),
    GetPage(
      name: _Paths.COMIC_WISHED_PAGE,
      page: () => const ComicWishedPageView(),
      binding: ComicWishedPageBinding(),
    ),
    GetPage(
      name: _Paths.WISHED_ACTIVE_PAGE,
      page: () => const WishedActivePage(),
    ),
    GetPage(
      name: _Paths.WISHING_PAGE,
      page: () => const WishingPage(),
    ),
    GetPage(
      name: _Paths.WATCH_HISTORY_PAGE,
      page: () => const WatchHistoryPageView(),
      binding: WatchHistoryPageBinding(),
    ),
    GetPage(
        name: _Paths.REWARD_HISTORY_PAGE,
        page: () => const RewardHistoryPage()),
    GetPage(
      name: _Paths.AI_CHANGE_FACE_PAGE,
      page: () => const AiChangeFacePageView(),
      binding: AiChangeFacePageBinding(),
    ),
    GetPage(
      name: _Paths.AI_TASK_LIST_PAGE,
      page: () => const AiTaskListPageView(),
      binding: AiTaskListPageBinding(),
    ),
    GetPage(
      name: _Paths.PREVIEW_IMAGE_VIEWER,
      page: () => const PreviewImageViewer(),
    ),
    GetPage(
      name: _Paths.MY_CACHE_PAGE,
      page: () => const MyCachePageView(),
      binding: MyCachePageBinding(),
    ),
    GetPage(
      name: _Paths.AI_RECOMMEND_PAGE,
      page: () => const AiRecommendPageView(),
      binding: AiRecommendPageBinding(),
    ),
    GetPage(
      name: _Paths.WITHDRAW_TYPE_PAGE,
      page: () => const WithdrawTypeView(),
    ),
  ];

  static jumpRouter({String? path, String? id}) async {
    try {
      // 外部分为三种跳转 [insert:app内部页面][webView:webView页面][launch:打开浏览器][game:游戏页面]
      // 长视频播放器 insert://video-player-page?id=0000
      // 专题详情  insert://topic-detail-page?topicId=15996&mediaType=1
      // 帖子详情  insert://post-detail-page?id=11341
      // 活动中心  insert://activity-center-page
      // 充值中心  insert://vip_center_page
      // 签到领红包 insert://weekly_check_task_page
      // 许愿池 insert://comic-wished-page
      // 排行榜 insert://rank-list-page
      // 新番预告 insert://episode-preview-page
      // 短视频 insert://short-video-player
      // 漫画详情 insert://comic-detail-page?comicId=10001&title=斗罗大陆
      // 小说详情 insert://novel-detail-page?novelId=10001&title=斗罗大陆

      // 所有内部网页 webView://web_view?title=大转盘&uri=http://192.168.16:8090
      // 某个游戏跳转 game://in_game_page?gameType=0000&gamePlatform=1
      // 所有外部网页 launch://http://192.168.16:8090
      // 首页跳转 insert://home?index=0
      // 游戏退出 game://home_game_page
      String route = path ?? "";
      Map<String, String> args = getArgsInPath(route);
      ShareKeys shareKeys = Get.find<ShareKeys>();
      if (route.startsWith("insert://")) {
        String router = route.replaceAll("insert://", "");
        if (router == "home") {
          AppUtils.jumpToHome(index: 0);
        } else {
          Get.toNamed(router, arguments: args);
        }
      } else if (route.startsWith("game://")) {
        FIJKPlayerManager manager = FIJKPlayerManager();
        manager.disposePlayer();
        String router = route.replaceAll("game://", "");
        if (router.split("?").isNotEmpty) {
          router = router.split("?")[0];
          if (router == "home_game_page") {
            if (Get.isRegistered<GameWebViewPageController>()) {
              final game = Get.find<GameWebViewPageController>();
              game.exitGame();
            }
          } else if (router == "in_game_page") {
            String gameType = args['gameType'] ?? '';
            int gamePlatform = int.tryParse(args['gamePlatform'] ?? '') ?? 0;
            HomeGamePageController game = Get.find<HomeGamePageController>();
            await game.enterGame(gameType: gameType, platform: gamePlatform);
          }
        }
      } else if (route.startsWith("webView://")) {
        String imgCdn = Address.imgCdn ?? "";
        String router = route.replaceAll("webView://", "");
        String? token = await shareKeys.getToken();
        int balance = shareKeys.userInfo.balance ?? 0;
        FIJKPlayerManager manager = FIJKPlayerManager();
        manager.disposePlayer();
        if (args["uri"] != null) {
          Uri baseUri = Uri.parse(args["uri"]!);
          String path = baseUri.path;
          String uri =
              "${shareKeys.baseUrl}$path?token=$token&gameBalance=$balance&imgCdn=$imgCdn";
          if (kIsWeb) uri += "&kIsWeb=$kIsWeb";
          args["uri"] = uri;
        }
        Get.toNamed(Routes.ACTIVITY_WEB_PAGE, arguments: args);
      } else if (route.startsWith("launch://")) {
        String router = route.replaceAll("launch://", "");
        if ((id ?? "").isNotEmpty) {
          ApiRes.clickAds(id: id);
        }
        if (kIsWeb) {
          html.window.localStorage["rechargeUrl"] = router;
          html.Element? link = html.document.getElementById("jumpToBrowser");
          link?.click();
        } else {
          if (!await launchUrl(
            Uri.parse(router),
            webOnlyWindowName: '_blank',
            mode: LaunchMode.externalApplication,
          )) {
            throw Exception('Could not launch $path');
          }
        }
      }else if (route.startsWith("http")) {
        if (!await launchUrl(
          Uri.parse(route),
          webOnlyWindowName: '_blank',
          mode: LaunchMode.externalApplication,
        )) {
          throw Exception('Could not launch $path');
        }
      } else {
        Get.toNamed(route, arguments: args);
      }
    } catch (error) {
      showToast(msg: "跳转出现故障，请重试！错误：$error");
    }
  }

  static Map<String, String> getArgsInPath(String route) {
    Map<String, String> args = {};
    if (route.split("?").length > 1) {
      List<String> argsKey = route.split("?").last.split("&");
      for (String item in argsKey) {
        if (item.split("=").length > 1) {
          List<String> keys = item.split("=");
          if (keys.isNotEmpty) {
            args[keys[0]] = keys[1];
          }
        }
      }
    }
    return args;
  }
}
