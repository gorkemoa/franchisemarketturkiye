import 'package:flutter/material.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/notification.dart';
import 'package:franchisemarketturkiye/viewmodels/notification_view_model.dart';
import 'package:franchisemarketturkiye/views/widgets/custom_drawer.dart';
import 'package:franchisemarketturkiye/services/deep_link_service.dart';
import 'package:intl/intl.dart';

class NotificationsView extends StatefulWidget {
  final NotificationViewModel viewModel;

  const NotificationsView({super.key, required this.viewModel});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlobalScaffold(
      showBackButton: true,
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading &&
              widget.viewModel.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (widget.viewModel.errorMessage != null &&
              widget.viewModel.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => widget.viewModel.fetchNotifications(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => widget.viewModel.fetchNotifications(),
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                if (widget.viewModel.notifications.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Henüz bir bildirim bulunmuyor.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.viewModel.notifications.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 24,
                        color: AppTheme.borderColor,
                      ),
                      itemBuilder: (context, index) {
                        final notification =
                            widget.viewModel.notifications[index];
                        return _NotificationItem(notification: notification);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final bool isInternalBlog =
        notification.targetType == 'internal' && notification.itemId != null;
    final bool hasLink =
        notification.linkUrl != null && notification.linkUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: () {
        if (isInternalBlog) {
          DeepLinkService().handleNavigation(
            'blog',
            notification.itemId.toString(),
          );
        } else if (hasLink) {
          DeepLinkService().handleUrl(notification.linkUrl!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.imageUrl != null)
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        notification.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(notification.updatedAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textTertiary,
                    fontFamily: 'Inter',
                  ),
                ),
                if (isInternalBlog || hasLink)
                  const Text(
                    'Detayları Gör',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
