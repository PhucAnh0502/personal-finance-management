import 'package:intl/intl.dart';

class FormatHelper {
  /// Format số tiền với dấu phẩy ngăn cách hàng nghìn
  /// Ví dụ: 1000000 -> "1,000,000"
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(amount.round());
  }

  /// Format số tiền với ký hiệu tiền tệ
  /// Ví dụ: 1000000 -> "đ1,000,000" hoặc "1,000,000đ"
  static String formatCurrencyWithSymbol(double amount, {String symbol = 'đ', bool symbolAtEnd = true}) {
    final formattedAmount = formatCurrency(amount);
    return symbolAtEnd ? '$formattedAmount$symbol' : '$symbol$formattedAmount';
  }

  /// Format số tiền với 2 chữ số thập phân
  /// Ví dụ: 1000000.5 -> "1,000,000.50"
  static String formatCurrencyWithDecimals(double amount) {
    final formatter = NumberFormat('#,###.00', 'en_US');
    return formatter.format(amount);
  }

  /// Format số tiền ngắn gọn (K, M, B)
  /// Ví dụ: 1500000 -> "1.5M"
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
