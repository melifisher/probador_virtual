import 'package:flutter/material.dart';

class NotificationPanel extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationPanel({
    Key? key,
    required this.notifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: const Row(
              children: [
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Notificaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Text('No hay notificaciones'),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return NotificationTile(
                        notification: notifications[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;

  const NotificationTile({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.notifications),
      ),
      title: Text(notification.title),
      subtitle: Text(notification.message),
      trailing: Text(
        '${notification.time.hour}:${notification.time.minute}',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      tileColor: notification.isRead ? null : Colors.blue[50],
    );
  }
}
