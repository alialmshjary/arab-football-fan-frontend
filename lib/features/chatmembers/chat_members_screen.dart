import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_members_controller.dart';

class ChatMembersScreen extends GetView<ChatMembersController> {
  const ChatMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(controller.chatTitle),
      ),
      body: Obx(
        () => Column(
          children: [
            if (controller.isLoading.value)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.members.isEmpty)
              const Expanded(
                child: Center(child: Text('لا يوجد أعضاء')),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.loadMembers,
                  child: ListView.builder(
                    itemCount: controller.members.length,
                    itemBuilder: (context, index) {
                      final member = controller.members[index];

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            member.fanName.isNotEmpty
                                ? member.fanName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(member.fanName),
                        subtitle: Text(
                          member.isModerator ? 'مشرف' : 'عضو',
                        ),
                      );
                    },
                  ),
                ),
              ),

            if (controller.chatType == 2)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLeaving.value
                          ? null
                          : controller.leaveGroup,
                      icon: const Icon(Icons.logout),
                      label: Text(
                        controller.isLeaving.value
                            ? 'جاري الخروج...'
                            : 'الخروج من المجموعة',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}