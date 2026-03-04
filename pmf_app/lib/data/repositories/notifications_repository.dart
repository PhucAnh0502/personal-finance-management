import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bank_notification_model.dart';

class NotificationsRepository {
  final _client = Supabase.instance.client;

  Future<List<BankNotificationModel>> fetchNotifications({int limit = 50}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return [];
    }

    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((item) => BankNotificationModel.fromJson(item))
        .toList();
  }

  Future<void> insertNotification(BankNotificationModel notification) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('notifications').insert({
      'user_id': user.id,
      'package_name': notification.packageName,
      'title': notification.title,
      'body': notification.body,
      'amount': notification.amount,
      'type': notification.type.name,
      'is_read': notification.isRead,
      'created_at': notification.createdAt.toIso8601String(),
    });
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', user.id);
  }

  Future<void> markAllAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id);
  }
}
