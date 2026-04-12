// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../controllers/withdraw_cash_bank_controller.dart';
import 'withdraw_cash_form_widget.dart';

class WithdrawCashBankView extends GetView<WithdrawCashBankController> {
  const WithdrawCashBankView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WithdrawCashFormWidget();
  }
}
