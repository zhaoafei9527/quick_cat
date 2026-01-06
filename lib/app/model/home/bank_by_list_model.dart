// 🌎 Project imports:
import '../../../plugins_utils/HttpRequester/src/base_net_model.dart';

class BankByList extends BaseNetModel {
  @override
  BankByList fromJson(Map<String, dynamic> json) {
    return BankByList.fromJson(json);
  }

  String? accountName;
  String? accountNo;
  String? bankBranch;
  String? bankCode;
  String? img;
  String? bankName;
  int? userId;

  BankByList(
      {this.accountName,
      this.accountNo,
      this.bankBranch,
      this.bankCode,
        this.img,
      this.bankName,
      this.userId});

  BankByList.fromJson(Map<String, dynamic> json) {
    accountName = json['accountName'];
    accountNo = json['accountNo'];
    bankBranch = json['bankBranch'];
    bankCode = json['bankCode'];
    img = json['img'];
    bankName = json['bankName'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['accountName'] = accountName;
    data['accountNo'] = accountNo;
    data['bankBranch'] = bankBranch;
    data['bankCode'] = bankCode;
    data['img'] = img;
    data['bankName'] = bankName;
    data['userId'] = userId;
    return data;
  }
}
