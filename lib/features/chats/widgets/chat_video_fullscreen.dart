import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChatVideoFullScreen extends StatefulWidget {
  const ChatVideoFullScreen({
    super.key,
    required this.videoUrl,
  });

  final String videoUrl;

  @override
  State<ChatVideoFullScreen> createState() => _ChatVideoFullScreenState();
}

class _ChatVideoFullScreenState extends State<ChatVideoFullScreen> {
  late final VideoPlayerController controller;

  bool isInitialized = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        isInitialized = true;
      });

      controller.play();
    } catch (error) {
      debugPrint('FULLSCREEN VIDEO ERROR = $error');

      if (!mounted) return;

      setState(() {
        hasError = true;
      });
    }
  }

  @override
  void dispose() {
    if (isInitialized) {
      controller.pause();
    }

    controller.dispose();
    super.dispose();
  }

  void togglePlay() {
    if (!isInitialized || hasError) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'تعذر تشغيل الفيديو',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            final position = value.position;
            final duration = value.duration;

            return Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),

                Positioned.fill(
                  child: GestureDetector(
                    onTap: togglePlay,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: value.isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          duration.inMilliseconds > 0
                              ? '${formatDuration(position)} / ${formatDuration(duration)}'
                              : formatDuration(position),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
      ),
    );
  }
}