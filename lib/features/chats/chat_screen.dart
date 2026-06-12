import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import 'chat_controller.dart';
import 'widgets/chat_image_widget.dart';
import 'widgets/chat_video_widget.dart';
import 'chat_message_model.dart';
import '../../core/utils/date_time_utils.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  Widget _messageContent({
    required bool isMe,
    required bool isMedia,
    required String time,
    required Widget child,
    required bool showSenderName,
    String? senderName,
  }) {
    return Container(
      padding: isMedia
          ? const EdgeInsets.all(5)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? AppColors.red : Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(14),
          topRight: const Radius.circular(14),
          bottomLeft: Radius.circular(isMe ? 14 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSenderName) ...[
            Text(
              senderName ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 3),
          ],

          child,

          const SizedBox(height: 4),

          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: isMe ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required BuildContext context,
    required ChatMessageModel message,
    required bool isMe,
    required bool showSenderName,
  }) {
    final hasAttachment =
        message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty;

    final isImage = message.messageType == 1 && hasAttachment;
    final isVideo = message.messageType == 2 && hasAttachment;
    final isMedia = isImage || isVideo;

    final time = DateTimeUtils.formatTime(message.createdAt);
    Widget content;

    if (isImage) {
      content = ChatImageWidget(
        imageUrl: '${ApiConstants.serverUrl}${message.attachmentUrl}',
      );
    } else if (isVideo) {
      content = ChatVideoWidget(
        videoUrl: Uri.encodeFull(
          '${ApiConstants.serverUrl}${message.attachmentUrl}',
        ),
      );
    } else {
      content = Text(
        message.content ?? '',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isMe ? Colors.white : AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _messageContent(
              isMe: isMe,
              isMedia: isMedia,
              time: time,
              child: content,
              showSenderName: showSenderName,
              senderName: message.senderName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Obx(
          () => InkWell(
            onTap: () {
              if (controller.chatType == 2 || controller.chatType == 3) {
                Get.toNamed(
                  Routes.chatMembers,
                  arguments: {
                    'chatId': controller.chatId,
                    'chatTitle': controller.chatTitle,
                    'chatType': controller.chatType,
                  },
                );
              }
            },
            child: Text(
              controller.isConnected.value
                  ? controller.chatTitle
                  : 'جاري الاتصال...',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return const Center(child: Text('لا توجد رسائل بعد'));
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];

                  final isMe =
                      message.senderId == controller.currentUserId.value;

                  final isGroupLike =
                      controller.chatType == 2 || controller.chatType == 3;

                  final showSenderName =
                      isGroupLike &&
                      !isMe &&
                      message.senderName != null &&
                      message.senderName!.isNotEmpty;
                      
                  final showDateSeparator =
                      index == 0 ||
                      !DateTimeUtils.isSameDay(
                        controller.messages[index - 1].createdAt,
                        message.createdAt,
                      );
                  return Column(
                    children: [
                      if (showDateSeparator)
                        _dateSeparator(
                          DateTimeUtils.formatMessageDateSeparator(
                            message.createdAt,
                          ),
                        ),

                      KeyedSubtree(
                        key: ValueKey(message.messageId),
                        child: _buildMessageBubble(
                          context: context,
                          message: message,
                          isMe: isMe,
                          showSenderName: showSenderName,
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.background,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    if (controller.selectedMediaPath.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: controller.selectedMessageType.value == 2
                                  ? Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.play_circle_fill,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    )
                                  : Image.file(
                                      File(controller.selectedMediaPath.value),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: -6,
                              left: -6,
                              child: InkWell(
                                onTap: controller.clearSelectedMedia,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  Row(
                    children: [
                      Obx(
                        () => IconButton(
                          onPressed: controller.isSending.value
                              ? null
                              : controller.sendMessage,
                          icon: const Icon(Icons.send_rounded),
                          color: AppColors.red,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: controller.messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => controller.sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالة...',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Obx(
                        () => IconButton(
                          onPressed: controller.isUploading.value
                              ? null
                              : () {
                                  Get.bottomSheet(
                                    SafeArea(
                                      child: Wrap(
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.image_outlined,
                                            ),
                                            title: const Text('إرسال صورة'),
                                            onTap: () {
                                              Get.back();
                                              controller.pickImage();
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.videocam_outlined,
                                            ),
                                            title: const Text('إرسال فيديو'),
                                            onTap: () {
                                              Get.back();
                                              controller.pickVideo();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                  );
                                },
                          icon: controller.isUploading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.attach_file_outlined),
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
