import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:pmf_app/core/utils/format_helper.dart';
import 'package:pmf_app/data/models/bank_notification_model.dart';
import 'package:pmf_app/data/repositories/budget_repository.dart';
import 'package:pmf_app/data/repositories/notifications_repository.dart';
import '../constants/bank_constants.dart';

class BankMonitorService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final ValueNotifier<List<BankNotificationModel>> notifications =
      ValueNotifier<List<BankNotificationModel>>([]);
  static final NotificationsRepository _notificationsRepository =
      NotificationsRepository();

  static Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: android);
    await _notificationsPlugin.initialize(settings: settings);
  }

  static Future<void> loadNotifications() async {
    final items = await _notificationsRepository.fetchNotifications();
    notifications.value = items;
  }

  static Future<void> markAsRead(String id) async {
    await _notificationsRepository.markAsRead(id);
    final updated = notifications.value
        .map((item) => item.id == id
            ? BankNotificationModel(
                id: item.id,
                userId: item.userId,
                packageName: item.packageName,
                title: item.title,
                body: item.body,
                amount: item.amount,
                type: item.type,
                isRead: true,
                createdAt: item.createdAt,
              )
            : item)
        .toList();
    notifications.value = updated;
  }

  static Future<void> markAllAsRead() async {
    await _notificationsRepository.markAllAsRead();
    final updated = notifications.value
        .map((item) => BankNotificationModel(
              id: item.id,
              userId: item.userId,
              packageName: item.packageName,
              title: item.title,
              body: item.body,
              amount: item.amount,
              type: item.type,
              isRead: true,
              createdAt: item.createdAt,
            ))
        .toList();
    notifications.value = updated;
  }

  static void onNotificationEvent(NotificationEvent event) async {
    final packageName = event.packageName ?? '';
    if (!BankConstants.bankPackages.contains(packageName)) return;

    final rawText = '${event.title ?? ''} ${event.text ?? ''}'.trim();
    if (rawText.isEmpty) return;

    final content = rawText.toLowerCase();
    final match = BankConstants.amountRegExp.firstMatch(rawText);
    if (match == null) return;

    final amountText = match.group(0) ?? '';
    final amount = double.tryParse(amountText.replaceAll(RegExp(r'[,.]'), ''));
    if (amount == null) return;

    final isIncome = BankConstants.incomeKeywords.any((k) => content.contains(k));
    final isExpense = BankConstants.expenseKeywords.any((k) => content.contains(k));

    if (isExpense) {
      await _handleExpense(amount, packageName, rawText);
    } else if (isIncome) {
      await _handleIncome(amount, packageName, rawText);
    } else {
      await _addNotification(
        amount: amount,
        packageName: packageName,
        title: event.title ?? '',
        body: event.text ?? rawText,
        type: BankNotificationType.unknown,
      );
    }
  }

  static Future<void> _handleExpense(
    double amount,
    String packageName,
    String rawText,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'expense_alert', 'Chi tiêu mới',
      importance: Importance.max, priority: Priority.high,
    );

    await _addNotification(
      amount: amount,
      packageName: packageName,
      title: 'Expense detected',
      body: rawText,
      type: BankNotificationType.expense,
    );

    final amountText = FormatHelper.formatCurrencyWithSymbol(amount, symbol: ' VND');

    await _notificationsPlugin.show(
      id: 1,
      title: 'Expense Detected!',
      body: 'You have just spent -$amountText. Please go into the app to categorize',
      notificationDetails:  NotificationDetails(android: androidDetails)
    );
  }

  static Future<void> _handleIncome(
    double amount,
    String packageName,
    String rawText,
  ) async {
    try {
      final BudgetRepository budgetRepo = BudgetRepository();
      await budgetRepo.incrementUnallocatedAmount(amount);
      const androidDetails = AndroidNotificationDetails(
        'income_alert', 'Thu nhập mới',
        importance: Importance.max, priority: Priority.high,
      );

      await _addNotification(
        amount: amount,
        packageName: packageName,
        title: 'Income detected',
        body: rawText,
        type: BankNotificationType.income,
      );

      final amountText = FormatHelper.formatCurrencyWithSymbol(amount, symbol: ' VND');
      await _notificationsPlugin.show(
        id: 2,
        title: 'Income Detected!',
        body: 'You have just received +$amountText.',
        notificationDetails: NotificationDetails(android: androidDetails)
      );
    } catch (e) {
      print('Error handling income: $e');
    }
  }

  static Future<void> _addNotification({
    required double amount,
    required String packageName,
    required String title,
    required String body,
    required BankNotificationType type,
  }) async {
    final item = BankNotificationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      packageName: packageName,
      title: title,
      body: body,
      amount: amount,
      type: type,
      createdAt: DateTime.now(),
    );

    final current = List<BankNotificationModel>.from(notifications.value);
    current.insert(0, item);
    notifications.value = current;

    await _notificationsRepository.insertNotification(item);
  }
}