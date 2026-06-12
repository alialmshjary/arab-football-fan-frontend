import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'match_model.dart';
import 'matches_service.dart';

class MatchesController extends GetxController {
  MatchesController(this._service);

  final MatchesService _service;

  final matches = <MatchModel>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isRefreshing = false.obs;

  final searchController = TextEditingController();
  final searchText = ''.obs;

  int currentPage = 1;
  int totalPage = 1;
  int totalCount = 0;
  final int pageSize = 10;

  bool get hasNextPage => currentPage < totalPage;

  @override
  void onInit() {
    super.onInit();
    fetchMatches();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchMatches({bool refresh = false}) async {
    if (isLoading.value || isLoadingMore.value) return;

    if (refresh) {
      currentPage = 1;
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final response = await _service.getMatches(
        pageNumber: currentPage,
        pageSize: pageSize,
        search: searchController.text,
      );

      final result = response.data;

      if (!response.isSuccess || result == null) {
        _toast(
          'لم تكتمل العملية',
          response.message.isNotEmpty
              ? response.message
              : 'تعذر جلب المباريات.',
        );
        return;
      }

      matches.assignAll(result.items);
      currentPage = result.currentPage;
      totalPage = result.totalPage;
      totalCount = result.totalCount;
    } catch (error) {
      _toast('خطأ', error.toString());
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore.value || isLoading.value) return;

    isLoadingMore.value = true;

    try {
      final nextPage = currentPage + 1;

      final response = await _service.getMatches(
        pageNumber: nextPage,
        pageSize: pageSize,
        search: searchController.text,
      );

      final result = response.data;

      if (!response.isSuccess || result == null) {
        _toast('تنبيه', response.message);
        return;
      }

      matches.addAll(result.items);
      currentPage = result.currentPage;
      totalPage = result.totalPage;
      totalCount = result.totalCount;
    } catch (error) {
      _toast('خطأ', error.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> searchMatches() async {
    currentPage = 1;
    await fetchMatches(refresh: true);
  }

  Future<void> clearSearch() async {
    searchController.clear();
    searchText.value = '';
    currentPage = 1;
    await fetchMatches(refresh: true);
  }

  void _toast(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
