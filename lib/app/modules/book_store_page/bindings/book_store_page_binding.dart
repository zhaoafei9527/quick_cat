import 'package:get/get.dart';

import '../controllers/book_store_page_controller.dart';

class BookStorePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookStorePageController>(
      () => BookStorePageController(),
    );
  }
}
