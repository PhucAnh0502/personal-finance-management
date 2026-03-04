class BankConstants {
  static const List<String> bankPackages = [
    'com.VCB',
    'com.vietinbank.ipay',
    'com.vnpay.bidv',
    'com.vnpay.Agribank3g',
    'vn.com.techcombank.bb.app',
    'com.mbmobile',
    'com.tpb.mb.gprsandroid',
    'com.vnpay.vpbankonline',
    'mobile.acb.com.vn',
    'com.sacombank.ewallet',
    'com.shinhan.global.vn.bank',
    'com.mservice.momotransfer',
    'com.bplus.vtpay',
    'vn.com.vng.zalopay',
  ];

  static const List<String> incomeKeywords = ['+', 'cong tien', 'nhan tien', 'da thanh toan'];
  static const List<String> expenseKeywords = ['-', 'tru tien', 'thanh toan', 'gd tru'];

  static final RegExp amountRegExp = RegExp(r'([0-9]{1,3}([,.][0-9]{3})*)');
}