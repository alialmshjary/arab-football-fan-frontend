import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/widgets/app_chrome.dart';
import '../../../core/widgets/cached_app_image.dart';
import '../../chats/widgets/chat_video_fullscreen.dart';
import '../post_model.dart';

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
                      ? _PostVideoPlayer(mediaUrl: mediaUrl)
                      : CachedAppImage(
                          imageUrl: mediaUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          placeholder: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.red,
                            ),
                          ),
                          errorWidget: const _MediaError(),
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
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _PostVideoPlayer extends StatefulWidget {
  const _PostVideoPlayer({required this.mediaUrl});

  final String mediaUrl;

  @override
  State<_PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<_PostVideoPlayer> {
  VideoPlayerController? _controller;

  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrl),
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('POST VIDEO ERROR = $e');

      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    final controller = _controller;

    if (controller != null) {
      controller.pause();
      controller.dispose();
    }

    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;

    if (!_initialized || _hasError || controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _openFullScreen() {
    if (!_initialized || _hasError) return;

    Get.to(() => ChatVideoFullScreen(videoUrl: widget.mediaUrl));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_hasError) {
      return Container(
        color: AppColors.black,
        child: const Center(
          child: Text(
            'تعذر تشغيل الفيديو',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    if (!_initialized || controller == null) {
      return Container(
        color: AppColors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.red),
        ),
      );
    }

    return Container(
      color: AppColors.black,
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final position = value.position;
          final duration = value.duration;
          final size = value.size;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),

              Positioned.fill(
                child: GestureDetector(
                  onTap: _togglePlay,
                  onDoubleTap: _openFullScreen,
                  child: Container(
                    color: Colors.black.withOpacity(
                      value.isPlaying ? 0.04 : 0.18,
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: value.isPlaying ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white54,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        duration.inMilliseconds > 0
                            ? '${_formatDuration(position)} / ${_formatDuration(duration)}'
                            : _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: 'ملء الشاشة',
                  onPressed: _openFullScreen,
                  icon: const Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
    final color = active
        ? AppColors.red
        : Theme.of(context).textTheme.bodyLarge?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
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
