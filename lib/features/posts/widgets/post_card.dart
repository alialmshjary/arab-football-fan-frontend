import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/widgets/app_chrome.dart';
import '../post_model.dart';
import '../../reports/report_dialog.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.compact = false,
  });

  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mediaUrl = ApiClient.mediaUrl(post.mediaUrl);
    return MadrajCard(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () =>
                        Get.toNamed(Routes.fanProfile, arguments: post.fanId),
                    borderRadius: BorderRadius.circular(99),
                    child: AppAvatar(
                      imageUrl: post.fanProfilePicUrl,
                      name: post.fanDisplayName,
                      radius: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.fanDisplayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(post.createdAt),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.fanId == StorageService.userId)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            tooltip: 'تعديل المنشور',
                            onPressed: onEdit,
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.red,
                            ),
                          ),
                        if (onDelete != null)
                          IconButton(
                            tooltip: 'حذف المنشور',
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.muted,
                            ),
                          ),
                      ],
                    )
                  else
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.muted),
                      onSelected: (value) {
                        if (value == 'report') {
                          ReportDialog.show(targetType: 1, targetId: post.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.flag_outlined, color: Colors.red),
                              SizedBox(width: 8),
                              Text('إبلاغ'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (post.caption?.trim().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Text(
                  post.caption!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF141419)
                      : Colors.white,
                  child: post.isVideo
                      ? _VideoPlaceholder(mediaUrl: mediaUrl)
                      : Image.network(
                          mediaUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => const _MediaError(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.red,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Row(
                children: [
                  _PostAction(
                    icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                    label: _compactNumber(post.likeCount),
                    active: post.isLiked,
                    onTap: onLike,
                  ),
                  _PostAction(
                    icon: Icons.mode_comment_outlined,
                    label: _compactNumber(post.commentCount),
                    onTap: onComment,
                  ),
                  const Spacer(),
                  _PostAction(
                    icon: post.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    label: _compactNumber(post.bookmarkCount),
                    active: post.isBookmarked,
                    onTap: onBookmark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date.toLocal());
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return DateFormat('yyyy/MM/dd').format(date.toLocal());
  }

  String _compactNumber(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 21,
              color: active
                  ? AppColors.red
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? AppColors.red
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.mediaUrl});

  final String mediaUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 58),
            SizedBox(height: 8),
            Text(
              'فيديو',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaError extends StatelessWidget {
  const _MediaError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF23232A)
          : AppColors.background,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, color: AppColors.muted),
            SizedBox(height: 8),
            Text('تعذر عرض الصورة', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
