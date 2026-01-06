// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/withdraw_cash_bank_controller.dart';

class WithdrawCashBankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WithdrawCashBankController>(
      () => WithdrawCashBankController(),
    );
  }
}
