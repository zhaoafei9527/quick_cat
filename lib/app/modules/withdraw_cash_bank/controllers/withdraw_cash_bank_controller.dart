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
  /// 提现渠道类型，与 [WithdrawType] / 服务端 wtype 对齐
  int withdrawWtype = WithdrawType.bank.index;
  String paramName = '';
  String paramIcon = '';

  bool get isBankWithdraw => withdrawWtype == WithdrawType.bank.index;

  String get pageAppBarTitle => paramName.isNotEmpty ? "$paramName提现" : '提现';

  WalletInfo? get currentWalletInfo {
    List<WalletInfo> walletList = userInfo.value.wallets ?? [];
    for (final wallet in walletList) {
      if (wallet.walletType?.index == withdrawWtype) {
        return wallet;
      }
    }
    // 部分数据场景没有 orderType，兜底按名称匹配
    for (final wallet in walletList) {
      if ((wallet.walletName ?? "") == paramName) {
        return wallet;
      }
    }
    return null;
  }

  bool get hasArrivalAccount {
    if (isBankWithdraw) {
      return (bankCard.value.bankName ?? '').isNotEmpty;
    }
    final wallet = currentWalletInfo;
    return wallet != null &&
        (wallet.walletName ?? '').isNotEmpty &&
        (wallet.walletAddr ?? '').isNotEmpty;
  }

  String get arrivalName {
    if (isBankWithdraw) return bankCard.value.bankName ?? '';
    return currentWalletInfo?.walletName ?? paramName;
  }

  String get arrivalSubText {
    if (isBankWithdraw) return '2分钟内到账';
    return currentWalletInfo?.walletAddr ?? '';
  }

  String get arrivalLabelText {
    if (isBankWithdraw) return '到账银行卡';
    if (paramName.isNotEmpty) return '到账$paramName账户';
    return '到账账户';
  }

  String get bindPageTitle {
    if (isBankWithdraw) return '绑定银行卡';
    if (paramName.isNotEmpty) return '绑定$paramName';
    return '绑定钱包';
  }

  String bindButtonLabel() {
    final hasCard =
        bankCard.value.bankName != null && bankCard.value.bankName != '';
    if (isBankWithdraw) {
      return '立即绑定银行卡';
    }
    if (paramName.isNotEmpty) {
      return hasArrivalAccount ? '更换钱包地址' : '立即绑定钱包地址';
    }
    return hasCard ? '更换绑定账户' : '立即绑定账户';
  }

  void _readRouteParams() {
    applyRouteParams();
  }

  /// 提现页、绑定页路由上携带的 wtype / name / icon
  void applyRouteParams([Map<String, String?>? override]) {
    final p = override ?? Get.parameters;
    withdrawWtype = int.tryParse(p['wtype'] ?? '') ?? WithdrawType.bank.index;
    paramName = p['name'] ?? '';
    paramIcon = p['icon'] ?? '';
    count.value++;
  }

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
  RxBool isLoadingBindInfo = false.obs;
  final count = 0.obs;

  @override
  Future<void> onInit() async {
    _readRouteParams();
    ShareKeys shareKeys = Get.find<ShareKeys>();
    userInfo.value = shareKeys.userInfo;
    super.onInit();
    shareKeys.getUserBalance();
    if (isBankWithdraw) {
      isLoadingBindInfo.value = true;
      try {
        BankByList? model = await ApiRes.getBankCardList();
        if (model != null) {
          bankCard.value = model;
        }

        BanksList? bankDataList = await ApiRes.getBankList();
        if (bankDataList != null) {
          bankList.value = bankDataList.listData ?? [];
          for (var bank in bankList) {
            if (bank.bankCode == bankCard.value.bankCode) {
              bankCard.value.img = bank.img;
              bankImg = bank.img ?? '';
              bankCard.refresh();
            }
          }
        }
      } finally {
        isLoadingBindInfo.value = false;
      }
    }
  }

  Future<void> _syncLatestUserInfo() async {
    await ApiRes.getUpdateUserInfo();
    final shareKeys = Get.find<ShareKeys>();
    userInfo.value = shareKeys.userInfo;
    count.value++;
  }

  Future bankChooseClick(ListData bankList) async {
    //选择银行卡点击事件
    bankImg = bankList.img ?? '';
    bankCodes = bankList.bankCode ?? '';
    bankNameField.text = bankList.name ?? '';
  }

  /// 绑定页提交：银行卡与电子钱包字段与接口语义不同
  Future submitBinding() async {
    if (isBankWithdraw) {
      await _submitBankBinding();
    } else {
      await _submitWalletBinding();
    }
  }

  Future _submitBankBinding() async {
    String accountName = nameField.text;
    String accountNo = cardNumberField.text;
    String bankCode = bankCodes;
    String bankName = bankNameField.text;
    String bankBranch = branchesField.text;
    if (accountName.isEmpty ||
        accountNo.isEmpty ||
        bankCode.isEmpty ||
        bankName.isEmpty ||
        bankBranch.isEmpty) {
      showTypeToast(msg: "请填写完整银行卡信息");
      return;
    }
    await ApiRes.submitBindBankCard(
        accountName: accountName,
        accountNo: accountNo,
        bankBranch: bankBranch,
        bankCode: bankCode,
        bankName: bankName,
        onSuccess: () async {
          showTypeToast(msg: "绑定银行卡成功", toastType: ToastType.SUCCESS);
          bankCard.value = BankByList(
              accountName: nameField.text,
              accountNo: cardNumberField.text,
              bankCode: bankCodes,
              bankName: bankNameField.text,
              bankBranch: branchesField.text,
              img: bankImg);
          await _syncLatestUserInfo();
          Get.back();
        });
  }

  Future _submitWalletBinding() async {
    String accountName = nameField.text;
    String walletAddress = cardNumberField.text;
    if (accountName.isEmpty || walletAddress.isEmpty) {
      showTypeToast(msg: "请填写姓名、钱包地址并选择钱包名称");
      return;
    }
    await ApiRes.submitBindWallet(
        accountName: accountName,
        accountNo: walletAddress,
        wtype: withdrawWtype,
        onError: (msg) {
          showTypeToast(msg: msg);
        },
        onSuccess: () async {
          showTypeToast(msg: "绑定成功", toastType: ToastType.SUCCESS);
          bankCard.value = BankByList(
              accountName: nameField.text,
              accountNo: cardNumberField.text,
              img: bankImg);
          await _syncLatestUserInfo();
          Get.back();
        });
  }

  Future submitWithdraw() async {
    //提现
    ShareKeys shareKeys = Get.find<ShareKeys>();
    String accountName = bankCard.value.accountName ?? ''; //账户持有人
    String accountNo = bankCard.value.accountNo ?? ''; //银行卡号
    String bankBranch = bankCard.value.bankBranch ?? ''; //银行支行
    String bankCode = bankCard.value.bankCode ?? ''; //银行编码
    String bankName = bankCard.value.bankName ?? ''; //开户银行名称
    if (!isBankWithdraw) {
      accountName = currentWalletInfo?.walletName ?? '';
      accountNo = currentWalletInfo?.walletAddr ?? '';
    }

    double maxAmount = double.tryParse(shareKeys.userBalance.value) ?? 0.0;
    double doubleAmount = double.tryParse(cashField.text) ?? 0.0;
    int money = (doubleAmount * 100).toInt();
    if (isBankWithdraw) {
      if (accountName.isEmpty ||
          accountNo.isEmpty ||
          bankCode.isEmpty ||
          bankBranch.isEmpty ||
          bankName.isEmpty) {
        showTypeToast(msg: "请完善银行卡信息后再试（含开户支行）");
        return;
      }
    } else {
      if (accountName.isEmpty || accountNo.isEmpty) {
        showTypeToast(msg: "请绑定完整账户信息后再试");
        return;
      }
    }

    if (isBankWithdraw &&
        (bankCard.value.bankBranch == null ||
            bankCard.value.bankBranch!.isEmpty)) {
      showTypeToast(msg: "请绑定完整银行卡信息（含开户支行）");
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
          orderType: withdrawWtype,
          onError: (msg) {
            showTypeToast(msg: "提现失败:$msg");
          },
          onSuccess: () {
            cashField.text = '';
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
