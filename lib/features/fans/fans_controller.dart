import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/storage/storage_service.dart';
import '../../core/media/media_compressor.dart';
import '../posts/post_model.dart';
import 'fan_model.dart';
import 'fans_service.dart';
import 'favorite_player.dart';
import 'favorite_team.dart';
import '../../core/utils/app_snackbar.dart';

class FansController extends GetxController {
  FansController(this._service);

  final FansService _service;

  // حالة شاشة البروفايل
  final isLoading = false.obs;
  final isSaving = false.obs;
  final profile = Rxn<FanProfile>();
  final selectedTeam = Rxn<FavoriteTeam>();
  final selectedPlayer = Rxn<FavoritePlayer>();
  final isFollowing = false.obs;

  // حالة البحث عن مشجعين
  final searchResults = <FanBasicProfile>[].obs;
  final searchText = ''.obs;
  final isSearching = false.obs;

  // حالة المتابعين والذين يتابعهم المستخدم
  final followList = <FanBasicProfile>[].obs;
  final isFollowListLoading = false.obs;
  final followSearchText = ''.obs;
  final activeFollowMode = 'followers'.obs;
  final activeFollowOwnerId = RxnInt();

  final displayNameController = TextEditingController();
  final bioController = TextEditingController();
  final searchController = TextEditingController();

  int? get currentUserId => StorageService.userId;
  bool get isMyProfile => profile.value?.id == currentUserId;

  List<FanBasicProfile> get visibleFollowList {
    final query = followSearchText.value.trim().toLowerCase();
    if (query.isEmpty) return followList;

    return followList.where((fan) {
      return fan.displayName.toLowerCase().contains(query) ||
          fan.username.toLowerCase().contains(query) ||
          (fan.bio ?? '').toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    selectedTeam.value = StorageService.favoriteTeam;
    selectedPlayer.value = StorageService.favoritePlayer;
  }

  // =========================
  // تحميل وتحديث البروفايل
  // =========================

  Future<void> loadMe() async {
    final id = currentUserId;
    if (id == null || id == 0) {
      _toast('تنبيه', 'لم يتم العثور على رقم المستخدم في الجلسة.');
      return;
    }
    await loadProfile(id);
  }

  Future<void> loadProfile(int fanId, {FanBasicProfile? preview}) async {
    _prepareProfileForLoading(fanId, preview);

    isLoading.value = true;
    try {
      final response = await _service.getProfile(fanId);
      final data = response.data;
      profile.value = data;

      if (data == null) return;

      _fillEditFields(data);
      _applyFavoritesFromFan(data, fallback: preview, allowLocalFallback: data.id == currentUserId);
      await _loadFollowingState(data.id);
    } catch (error) {
      if (preview != null) {
        _applyFavoritesFromFan(preview, allowLocalFallback: preview.id == currentUserId);
      }
      _toast('خطأ', _cleanError(error));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCurrent() async {
    final id = profile.value?.id ?? currentUserId;
    if (id != null) await loadProfile(id);
  }

  Future<void> updateProfile({String? imagePath}) async {
    final displayName = displayNameController.text.trim();
    final bio = bioController.text.trim();

    if (displayName.isEmpty) {
      _toast('تنبيه', 'اسم العرض مطلوب.');
      return;
    }

    isSaving.value = true;
    try {
      final response = await _service.updateProfile(
        displayName: displayName,
        bio: bio,
        imagePath: imagePath,
      );

      if (response.data != null) {
        await loadMe();
        Get.back<void>();
        _toast('تم', response.message.isNotEmpty ? response.message : 'تم تحديث الملف الشخصي.');
      }
    } catch (error) {
      _toast('خطأ', _cleanError(error));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickAndUpdateImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 86);
    if (image == null) return;

    final compressedPath = await MediaCompressor.compressImage(image.path);
    await updateProfile(imagePath: compressedPath);
  }

  void _prepareProfileForLoading(int fanId, FanBasicProfile? preview) {
    if (profile.value?.id != fanId) profile.value = null;
    if (preview != null) {
      _applyFavoritesFromFan(preview, allowLocalFallback: preview.id == currentUserId);
    }
  }

  void _fillEditFields(FanProfile fan) {
    displayNameController.text = fan.displayName;
    bioController.text = fan.bio ?? '';
  }

  Future<void> _loadFollowingState(int fanId) async {
    if (fanId != currentUserId && currentUserId != null) {
      await checkFollowing(fanId);
    } else {
      isFollowing.value = false;
    }
  }

  // =========================
  // الفريق واللاعب المفضل
  // =========================

  Future<void> chooseTeam(FavoriteTeam team) async {
    await _changeTeam(team, successMessage: 'تم حفظ ${team.name} كفريقك المفضل.');
  }

  Future<void> clearTeam() async {
    await _changeTeam(null);
  }

  Future<void> choosePlayer(FavoritePlayer player) async {
    await _changePlayer(player, successMessage: 'تم حفظ ${player.name} كلاعبك المفضل.');
  }

  Future<void> clearPlayer() async {
    await _changePlayer(null);
  }

  Future<void> _changeTeam(FavoriteTeam? team, {String? successMessage}) async {
    final previous = selectedTeam.value;
    selectedTeam.value = team;
    await _cacheTeam(team);

    try {
      await _saveFavoriteCodes();
      await refreshCurrent();
      if (successMessage != null) _toast('تم اختيار الفريق', successMessage);
    } catch (error) {
      selectedTeam.value = previous;
      await _cacheTeam(previous);
      _toast('خطأ', _cleanError(error));
    }
  }

  Future<void> _changePlayer(FavoritePlayer? player, {String? successMessage}) async {
    final previous = selectedPlayer.value;
    selectedPlayer.value = player;
    await _cachePlayer(player);

    try {
      await _saveFavoriteCodes();
      await refreshCurrent();
      if (successMessage != null) _toast('تم اختيار اللاعب', successMessage);
    } catch (error) {
      selectedPlayer.value = previous;
      await _cachePlayer(previous);
      _toast('خطأ', _cleanError(error));
    }
  }

  Future<void> _saveFavoriteCodes() async {
    await _service.updateProfile(
      favoriteTeamCode: selectedTeam.value?.code,
      favoritePlayerCode: selectedPlayer.value?.code,
      includeFavoriteTeam: true,
      includeFavoritePlayer: true,
    );
  }

  Future<void> _cacheTeam(FavoriteTeam? team) {
    return team == null ? StorageService.clearFavoriteTeam() : StorageService.saveFavoriteTeam(team);
  }

  Future<void> _cachePlayer(FavoritePlayer? player) {
    return player == null ? StorageService.clearFavoritePlayer() : StorageService.saveFavoritePlayer(player);
  }

  void _applyFavoritesFromFan(
    FanBasicProfile fan, {
    FanBasicProfile? fallback,
    bool allowLocalFallback = false,
  }) {
    final team = fan.favoriteTeam ?? fallback?.favoriteTeam;
    final player = fan.favoritePlayer ?? fallback?.favoritePlayer;

    selectedTeam.value = team ?? (allowLocalFallback ? StorageService.favoriteTeam : null);
    selectedPlayer.value = player ?? (allowLocalFallback ? StorageService.favoritePlayer : null);
  }

  // =========================
  // البحث والمتابعين
  // =========================

  void clearSearch() {
    searchController.clear();
    searchText.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  Future<void> searchFans(String query) async {
    final text = query.trim();
    searchText.value = text;

    if (text.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    try {
      final response = await _service.searchFans(text);
      searchResults.assignAll(response.data ?? const []);
    } catch (error) {
      _toast('خطأ', _cleanError(error));
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> loadFollowList({required int fanId, required String mode}) async {
    if (fanId <= 0) {
      _toast('تنبيه', 'لم يتم العثور على رقم المشجع المطلوب.');
      return;
    }

    _startFollowListLoading(fanId, mode);

    try {
      final response = activeFollowMode.value == 'followers'
          ? await _service.getFollowers(fanId)
          : await _service.getFollowing(fanId);
      followList.assignAll(response.data ?? const []);
    } catch (error) {
      followList.clear();
      _toast('خطأ', _cleanError(error));
    } finally {
      isFollowListLoading.value = false;
    }
  }

  Future<void> refreshFollowList() async {
    final fanId = activeFollowOwnerId.value;
    if (fanId == null) return;
    await loadFollowList(fanId: fanId, mode: activeFollowMode.value);
  }

  void filterFollowList(String query) {
    followSearchText.value = query;
  }

  Future<void> checkFollowing(int targetId) async {
    if (targetId == currentUserId) return;

    try {
      final response = await _service.isFollowing(targetId);
      isFollowing.value = response.data == true;
    } catch (_) {
      isFollowing.value = false;
    }
  }

  Future<void> toggleFollow() async {
    final targetId = profile.value?.id;
    if (targetId == null || targetId == currentUserId) return;

    final wasFollowing = isFollowing.value;
    isFollowing.value = !wasFollowing;

    try {
      if (wasFollowing) {
        await _service.unfollow(targetId);
      } else {
        await _service.follow(targetId);
      }
      await loadProfile(targetId);
    } catch (error) {
      isFollowing.value = wasFollowing;
      _toast('خطأ', _cleanError(error));
    }
  }

  void _startFollowListLoading(int fanId, String mode) {
    activeFollowMode.value = mode == 'following' ? 'following' : 'followers';
    activeFollowOwnerId.value = fanId;
    followSearchText.value = '';
    searchController.clear();
    searchText.value = '';
    isFollowListLoading.value = true;
  }

  // =========================
  // المنشورات
  // =========================

  Future<void> openPost(PostModel post) async {
    await Get.toNamed('/post-details', arguments: {'postId': post.id, 'post': post});
    await refreshCurrent();
  }

  // =========================
  // أدوات مساعدة
  // =========================

  String _cleanError(Object error) => AppSnackbar.cleanError(error);

  void _toast(String title, String message) {
    AppSnackbar.show(title, message);
  }

  @override
  void onClose() {
    displayNameController.dispose();
    bioController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
