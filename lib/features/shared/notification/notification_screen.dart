import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/locator.dart';
import '../../../core/presentation/components/pull_to_refresh.dart';
import '../../../core/presentation/components/section_card.dart';
import '../../../core/presentation/components/snackbar.dart';
import '../../../core/presentation/widgets/app_top_bar.dart';
import '../../../core/presentation/widgets/empty_box.dart';
import '../../../core/presentation/widgets/error_box.dart';
import '../../../core/presentation/widgets/page_loader.dart';
import '../../../core/presentation/widgets/shimmer.dart';
import '../../../core/utils/format.dart';
import '../../../data/dto/notification/notification_response.dart';
import '../../../main_view_model.dart';
import '../../../navigation/routes.dart';
import '../../../ui/theme/space.dart';
import '../../../ui/theme/theme.dart';
import 'notification_view_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(locator(), locator()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  void _open(BuildContext context, NotificationResponse n) {
    if (!n.read) context.read<NotificationViewModel>().markRead(n.id);
    final isOwner = context.read<MainViewModel>().user?.isOwner ?? false;
    final target = notificationTarget(n, isOwner: isOwner);
    if (target != null) context.push(target);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<NotificationViewModel>();
    final loader = vm.loader;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'Notifications',
            subTitle: 'Applications, messages, posts',
            onBack: context.pop,
            actions: [
              IconButton(
                tooltip: 'Mark all as read',
                onPressed: () => vm.markAll(onResult: AppSnackbar.show),
                icon: const Icon(Icons.done_all),
              ),
            ],
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: loader,
              builder: (context, _) => switch (loader.state) {
                UiLoading() => const ShimmerList(),
                UiError(:final message) => ErrorBox(message: message, onRetry: loader.loadFirst),
                UiSuccess(data: final notifications) => PullToRefresh(
                  onRefresh: loader.refresh,
                  fillViewport: notifications.isEmpty,
                  child: notifications.isEmpty
                      ? const EmptyBox(
                          title: "You're all caught up",
                          subtitle: 'Notifications about your posts, applications and contracts land here.',
                          icon: Icons.notifications,
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            Space.screen,
                            Space.md,
                            Space.screen,
                            Space.listBottom,
                          ),
                          itemCount: notifications.length,
                          separatorBuilder: (_, _) => const SizedBox(height: Space.listGap),
                          itemBuilder: (context, i) {
                            final n = notifications[i];
                            return _NotificationItem(
                              key: ValueKey(n.id),
                              noty: n,
                              onClick: () => _open(context, n),
                            );
                          },
                        ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({super.key, required this.noty, required this.onClick});

  final NotificationResponse noty;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final body = noty.body;

    return SectionCard(
      contentPadding: EdgeInsets.zero,
      onClick: onClick,
      children: [
        Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread marker — a dot reads faster than a bolder weight.
              Container(
                margin: const EdgeInsets.only(top: 6, right: Space.md),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: noty.read ? colors.surfaceContainerHighest : colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(noty.title, style: context.typos.titleSmall),
                    if (body != null && body.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.xs),
                        child: Text(
                          body,
                          style: context.typos.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: Space.sm),
                child: Text(
                  timeAgo(noty.createdAt),
                  style: context.typos.labelSmall?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
