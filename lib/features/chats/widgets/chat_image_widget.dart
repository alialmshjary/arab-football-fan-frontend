import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/cached_app_image.dart';
import 'chat_image_fullscreen.dart';

class ChatImageWidget extends StatelessWidget {
  const ChatImageWidget({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ChatImageFullScreen(imageUrl: imageUrl));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Hero(
          tag: imageUrl,
          child: CachedAppImage(
            imageUrl: imageUrl,
            width: 200,
            height: 220,
            fit: BoxFit.cover,
            placeholder: Container(
              width: 200,
              height: 220,
              alignment: Alignment.center,
              color: Colors.grey.shade300,
              child: const CircularProgressIndicator(),
            ),
            errorWidget: Container(
              width: 200,
              height: 220,
              alignment: Alignment.center,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
      ),
    );
  }
}
