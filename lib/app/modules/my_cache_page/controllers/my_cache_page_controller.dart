import 'package:acgn_client/app/model/home/video_play_model.dart';
import 'package:acgn_client/plugins_utils/VideoPlayer/src/m3u8_cache_manager.dart';
import 'package:get/get.dart';

class MyCachePageController extends GetxController {
  RxString playVideoUrl = "".obs;
  RxString playVideoCoverImg = "".obs;
  RxList<VideoCacheInfo> cacheInfoList = <VideoCacheInfo>[].obs;

  @override
  void onInit() async{
    super.onInit();
    M3u8CacheManager manage = M3u8CacheManager();
    cacheInfoList.value =
        await manage.getAllVideoCacheInfoPersistent();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
