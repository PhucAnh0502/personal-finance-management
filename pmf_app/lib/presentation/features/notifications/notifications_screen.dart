import 'package:flutter/material.dart';
import 'package:pmf_app/core/constants/app_colors.dart';
import 'package:pmf_app/core/theme/app_theme.dart';
import 'package:pmf_app/core/services/bank_monitor_service.dart';
import 'package:pmf_app/core/utils/format_helper.dart';
import 'package:pmf_app/data/models/bank_notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    BankMonitorService.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackground(context),
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => BankMonitorService.markAllAsRead(),
            child: const Text(
              'Mark all read',
              style: TextStyle(color: AppColors.primaryEmerald),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<List<BankNotificationModel>>(
        valueListenable: BankMonitorService.notifications,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final amountText = FormatHelper.formatCurrencyWithSymbol(
                item.amount,
                symbol: ' VND',
              );
              final title = item.title.isNotEmpty ? item.title : 'Bank notification';
              final subtitle = item.body.isNotEmpty ? item.body : item.packageName;
              final iconColor = _typeColor(item.type);
              final sign = item.type == BankNotificationType.income
                  ? '+'
                  : item.type == BankNotificationType.expense
                      ? '-'
                      : '';

              return GestureDetector(
                onTap: () {
                  if (!item.isRead) {
                    BankMonitorService.markAsRead(item.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.isRead ? AppTheme.getSurfaceColor(context) : AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _typeIcon(item.type),
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: AppTheme.getTextPrimaryColor(context),
                                      fontSize: 14,
                                      fontWeight: item.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (!item.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryEmerald,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppTheme.getSubtitleStyle(context).color,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$sign$amountText',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static IconData _typeIcon(BankNotificationType type) {
    switch (type) {
      case BankNotificationType.income:
        return Icons.arrow_downward_rounded;
      case BankNotificationType.expense:
        return Icons.arrow_upward_rounded;
      case BankNotificationType.unknown:
        return Icons.notifications_active_outlined;
    }
  }

  static Color _typeColor(BankNotificationType type) {
    switch (type) {
      case BankNotificationType.income:
        return AppColors.income;
      case BankNotificationType.expense:
        return AppColors.expense;
      case BankNotificationType.unknown:
        return AppColors.primaryEmerald;
    }
  }
}
