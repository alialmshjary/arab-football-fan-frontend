import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/storage/storage_service.dart';
import '../../core/utils/app_snackbar.dart';
import '../fans/fan_model.dart';
import '../fans/fans_service.dart';
import '../chats/chat_service.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final titleController = TextEditingController();
  final searchController = TextEditingController();

  final selectedFans = <FanBasicProfile>[];
  final searchResults = <FanBasicProfile>[];

  bool isSearching = false;
  bool isCreating = false;

  Future<void> searchFans(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      setState(() => searchResults.clear());
      return;
    }

    setState(() => isSearching = true);

    try {
      final response = await Get.find<FansService>().searchFans(query);

      if (!mounted) return;

      final currentUserId = StorageService.userId;

      setState(() {
        searchResults
          ..clear()
          ..addAll(
            (response.data ?? []).where((fan) => fan.id != currentUserId),
          );
      });
    } catch (e) {
      AppSnackbar.show('خطأ', AppSnackbar.cleanError(e));
    } finally {
      if (mounted) {
        setState(() => isSearching = false);
      }
    }
  }

  void toggleFan(FanBasicProfile fan) {
    setState(() {
      final exists = selectedFans.any((x) => x.id == fan.id);

      if (exists) {
        selectedFans.removeWhere((x) => x.id == fan.id);
      } else {
        selectedFans.add(fan);
      }
    });
  }

  Future<void> createGroup() async {
    final title = titleController.text.trim();
    final currentUserId = StorageService.userId;

    if (currentUserId == null) {
      AppSnackbar.show('خطأ', 'يجب تسجيل الدخول أولًا');
      return;
    }

    if (title.isEmpty) {
      AppSnackbar.show('تنبيه', 'اكتب اسم المجموعة');
      return;
    }

    if (selectedFans.isEmpty) {
      AppSnackbar.show('تنبيه', 'اختر مشجعًا واحدًا على الأقل');
      return;
    }

    final memberIds = {
      currentUserId,
      ...selectedFans.map((fan) => fan.id),
    }.toList();

    setState(() => isCreating = true);

    try {
      final chat = await Get.find<ChatService>().createGroupChat(
        title: title,
        memberIds: memberIds,
      );

      Get.offNamed(
        Routes.chats,
        arguments: {
          'chatId': chat.id,
          'chatTitle': chat.title ?? title,
          'chatType': chat.chatType,
        },
      );
    } catch (e) {
      AppSnackbar.show('خطأ', AppSnackbar.cleanError(e));
    } finally {
      if (mounted) {
        setState(() => isCreating = false);
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('إنشاء مجموعة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              onChanged: searchFans,
              decoration: InputDecoration(
                labelText: 'ابحث عن مشجع',
                border: const OutlineInputBorder(),
                suffixIcon: isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            if (selectedFans.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: selectedFans
                      .map(
                        (fan) => Chip(
                          label: Text(fan.displayName),
                          onDeleted: () => toggleFan(fan),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final fan = searchResults[index];
                  final selected = selectedFans.any((x) => x.id == fan.id);

                  return ListTile(
                    title: Text(fan.displayName),
                    subtitle: fan.bio != null && fan.bio!.trim().isNotEmpty
                        ? Text(fan.bio!)
                        : null,
                    trailing: Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                    ),
                    onTap: () => toggleFan(fan),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCreating ? null : createGroup,
                icon: const Icon(Icons.group_add_outlined),
                label: Text(isCreating ? 'جاري الإنشاء...' : 'إنشاء المجموعة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
