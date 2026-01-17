// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:quick_cat_client/app/data/share_key.dart';
import 'package:quick_cat_client/app/model/home/user_info_model.dart';
import '../../../../conf/api_res.dart';
import '../../../../utils/toast_util.dart';
import '../../../data/enum.dart';
import '../../../model/home/bank_by_list_model.dart';
import '../../../model/home/banks_list_model.dart';

class WithdrawCashBankController extends GetxController {
  FocusNode nameFocusNode = FocusNode();
  TextEditingController nameField = TextEditingController();
  FocusNode cardNumberFocusNode = FocusNode();
  TextEditingController cardNumberField = TextEditingController();
  FocusNode bankNameFocusNode = FocusNode();
  TextEditingController bankNameField = TextEditingController();
  FocusNode branchesFocusNode = FocusNode();
  TextEditingController branchesField = TextEditingController();
  String bankCodes = '';
  String bankImg = '';
  FocusNode cashFocusNode = FocusNode();
  TextEditingController cashField = TextEditingController();
  Rx<UserInfo> userInfo = UserInfo().obs;

  var bankCard = Rx<BankByList>(BankByList());
  RxList<ListData> bankList = <ListData>[].obs;
  final count = 0.obs;

  @override
  Future<void> onInit() async {
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = shareKeys.userInfo;
    super.onInit();
    shareKeys.getUserBalance();
    BankByList? model = await ApiRes.getBankCardList();
    if (model != null) {
      bankCard.value = model;
    }

    BanksList? bankDataList = await ApiRes.getBankList();
    if (bankDataList != null) {
      bankList.value = bankDataList.listData ?? [];
      for (var bank in bankList.value) {
        if (bank.bankCode == bankCard.value.bankCode) {
          bankCard.value.img = bank.img;
          bankImg = bank.img ?? '';
          bankCard.refresh();
        }
      }
    }
  }



  Future bankChooseClick(ListData bankList) async {
    //选择银行卡点击事件
    bankImg = bankList.img ?? '';
    bankCodes = bankList.bankCode ?? '';
    bankNameField.text = bankList.name ?? '';
  }

  Future bindBankCard() async {
    //绑定
    String accountName = nameField.text; //账户持有人
    String accountNo = cardNumberField.text; //银行卡号
    String bankCode = bankCodes; //银行编码
    String bankName = bankNameField.text; //开户银行名称
    String bankBranch = branchesField.text; //银行支行
    await ApiRes.submitBindBankCard(
        accountName: accountName,
        accountNo: accountNo,
        bankBranch: bankBranch,
        bankCode: bankCode,
        bankName: bankName,
        onSuccess: () {
          showTypeToast(msg: "绑定银行卡成功", toastType: ToastType.SUCCESS);
          BankByList bankData = BankByList(
              accountName: nameField.text ?? '',
              accountNo: cardNumberField.text ?? '',
              bankCode: '',
              bankName: bankNameField.text ?? '',
              bankBranch: branchesField.text ?? '',
              img: bankImg ?? '');
          bankCard.value = bankData;
          // Get.back();
        });
  }

  Future bindingPhone() async {
    //提现
    ShareKeys shareKeys = Get.find<ShareKeys>();
    String accountName = bankCard.value.accountName ?? ''; //账户持有人
    String accountNo = bankCard.value.accountNo ?? ''; //银行卡号
    String bankBranch = bankCard.value.bankBranch ?? ''; //银行支行
    String bankCode = bankCard.value.bankCode ?? ''; //银行编码
    String bankName = bankCard.value.bankName ?? ''; //开户银行名称

    double maxAmount = double.tryParse(shareKeys.userTransferable.value) ?? 0.0;
    double doubleAmount = double.tryParse(cashField.text) ?? 0.0;
    int money = (doubleAmount * 100).toInt();
    if (accountName.isEmpty ||
        accountNo.isEmpty ||
        bankCode.isEmpty ||
        bankName.isEmpty) {
      showTypeToast(msg: "请绑定银行卡后重试！");
      return;
    }
    if (doubleAmount > maxAmount) {
      showTypeToast(msg: "提现金额不能大于可提现余额");
      return;
    }
    if (money >= 20000 && (money % 100) == 0) {
      await ApiRes.submitWithdrawal(
          accountName: accountName,
          accountNo: accountNo,
          bankBranch: bankBranch,
          bankCode: bankCode,
          bankName: bankName,
          money: money,
          onSuccess: () {
            cashField.text = '';
            ShareKeys shareKeys = Get.find<ShareKeys>();
            shareKeys.getUserBalance();
            showTypeToast(msg: "提现提交成功", toastType: ToastType.SUCCESS);
          });
    } else {
      showTypeToast(msg: "提现数额必须是大于200的整数倍");
    }

    // if (model != null) envList.value = model.list ?? [];
  }

  void increment() => count.value++;
}
