import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/storage_service.dart';
import 'chat_message_model.dart';
import 'chat_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  ChatController(this._service);

  final ChatService _service;

  final messages = <ChatMessageModel>[].obs;

  final messageController = TextEditingController();

  final isLoading = false.obs;
  final isSending = false.obs;
  final isConnected = false.obs;
  final currentUserId = (StorageService.userId ?? 0).obs;
  final scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final isUploading = false.obs;
  final selectedMediaPath = ''.obs;
  final selectedMessageType = 0.obs; // 1 image, 2 video
  late final int chatId;
  late final String chatTitle;
  late final int chatType;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;

    chatId = args['chatId'];
    chatTitle = args['chatTitle'] ?? 'Chat';
    chatType = args['chatType'] ?? 0;

    initChat();
  }

  Future<void> initChat() async {
    await fetchMessages();
    await connectToHub();
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;

    try {
      final result = await _service.getMessages(chatId);
      messages.assignAll(result);
      scrollToBottom();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل الرسائل');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> connectToHub() async {
    try {
      final token = StorageService.token;

      if (token == null || token.isEmpty) {
        Get.snackbar('خطأ', 'يجب تسجيل الدخول أولًا');
        return;
      }
      await _service.connect(
        token: token,
        onMessageReceived: (message) {
          if (message.chatId != chatId) return;

          messages.add(message);
          scrollToBottom();
        },
        onError: (error) {
          Get.snackbar('خطأ في الشات', error);
        },
      );

      await _service.joinChat(chatId);

      isConnected.value = true;
    } catch (e) {
      isConnected.value = false;
      Get.snackbar('خطأ', 'فشل الاتصال بالشات');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    selectedMediaPath.value = pickedFile.path;
    selectedMessageType.value = 1;
  }

  Future<void> pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;

    selectedMediaPath.value = pickedFile.path;
    selectedMessageType.value = 2;
  }

  void clearSelectedMedia() {
    selectedMediaPath.value = '';
    selectedMessageType.value = 0;
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final mediaPath = selectedMediaPath.value;
    final mediaType = selectedMessageType.value;

    if (text.isEmpty && mediaPath.isEmpty) return;
    if (isSending.value || isUploading.value) return;

    isSending.value = true;

    try {
      if (mediaPath.isNotEmpty) {
        isUploading.value = true;

        final attachmentUrl = await _service.uploadAttachment(File(mediaPath));

        await _service.sendMediaMessage(
          chatId: chatId,
          attachmentUrl: attachmentUrl,
          messageType: mediaType,
        );

        clearSelectedMedia();
        messageController.clear();

        return;
      }

      await _service.sendTextMessage(chatId: chatId, content: text);

      messageController.clear();
    } catch (e) {
      debugPrint('SEND MESSAGE ERROR = $e');
      Get.snackbar('خطأ', e.toString());
    } finally {
      isUploading.value = false;
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    isConnected.value = false;
    closeHubConnection();

    messageController.dispose();
    scrollController.dispose();

    super.onClose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToBottom();

      Future.delayed(const Duration(milliseconds: 300), _animateToBottom);
      Future.delayed(const Duration(milliseconds: 700), _animateToBottom);
    });
  }

  void _animateToBottom() {
    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> closeHubConnection() async {
    try {
      await _service.leaveHubChat(chatId);
      await _service.disconnect();
    } catch (e) {
      debugPrint('CLOSE CHAT CONNECTION ERROR = $e');
    }
  }
}
