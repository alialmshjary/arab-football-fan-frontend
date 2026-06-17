import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/cached_app_image.dart';

class ChatImageFullScreen extends StatelessWidget {
  const ChatImageFullScreen({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: imageUrl,
                child: InteractiveViewer(
                  child: CachedAppImage(
                    imageUrl: imageUrl,
                    placeholder: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    errorWidget: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
