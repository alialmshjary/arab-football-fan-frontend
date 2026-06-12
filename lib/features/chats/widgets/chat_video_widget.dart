import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'chat_video_fullscreen.dart';

class ChatVideoWidget extends StatefulWidget {
  const ChatVideoWidget({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<ChatVideoWidget> createState() => _ChatVideoWidgetState();
}

class _ChatVideoWidgetState extends State<ChatVideoWidget>
    with AutomaticKeepAliveClientMixin {
  late final VideoPlayerController _controller;

  bool _initialized = false;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('VIDEO INIT ERROR = $e');

      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.pause();
    }

    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized || _hasError) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasError) {
      return _videoFrame(
        child: const Center(
          child: Text(
            'تعذر تشغيل الفيديو',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }

    if (!_initialized) {
      return _videoFrame(
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return _videoFrame(
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: _controller,
        builder: (context, value, child) {
          final position = value.position;
          final duration = value.duration;
          final size = value.size;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),

              Positioned.fill(
                child: GestureDetector(
                  onTap: _togglePlay,
                  onDoubleTap: () {
                    Get.to(
                      () => ChatVideoFullScreen(videoUrl: widget.videoUrl),
                    );
                  },
                  child: Container(
                    color: Colors.black.withOpacity(
                      value.isPlaying ? 0.04 : 0.18,
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: value.isPlaying ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: const Icon(
                          Icons.play_circle_fill,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white54,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        duration.inMilliseconds > 0
                            ? '${_formatDuration(position)} / ${_formatDuration(duration)}'
                            : _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _videoFrame({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        height: 260,
        color: Colors.black87,
        child: child,
      ),
    );
  }
}