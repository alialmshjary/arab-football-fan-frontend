import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import 'chat_list_controller.dart';
import 'chat_service.dart';
import '../../core/utils/date_time_utils.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  ChatListController get controller {
    if (Get.isRegistered<ChatListController>()) {
      return Get.find<ChatListController>();
    }

    return Get.put(ChatListController(Get.find<ChatService>()));
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 52, color: Colors.grey.shade400),
                  const SizedBox(height: 14),
                  const Text(
                    'تعذر تحميل المحادثات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تحقق من اتصال الإنترنت ثم حاول مرة أخرى.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.chats.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 52,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'لا توجد محادثات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'عند إنشاء أو الانضمام إلى محادثات ستظهر هنا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchChats,
          child: ListView.builder(
            itemCount: controller.chats.length,
            itemBuilder: (context, index) {
              final chat = controller.chats[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(chat.chatType == 1 ? Icons.person : Icons.group),
                ),
                title: Text(
                  chat.title ?? 'محادثة',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  chat.lastMessageType == 1
                      ? '📷 صورة'
                      : chat.lastMessageType == 2
                      ? '🎥 فيديو'
                      : (chat.lastMessage ?? 'لا توجد رسائل'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chat.lastMessageAt != null)
                      Text(
                        DateTimeUtils.formatChatListTime(chat.lastMessageAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
                onTap: () async {
                  await Get.toNamed(
                    Routes.chats,
                    arguments: {
                      'chatId': chat.id,
                      'chatTitle': chat.title,
                      'chatType': chat.chatType,
                    },
                  );

                  await controller.fetchChats();
                },
              );
            },
          ),
        );
      }),
    );
  }
}
