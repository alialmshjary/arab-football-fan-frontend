import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/utils/app_snackbar.dart';
import '../matches/match_model.dart';
import 'prediction_model.dart';
import 'predictions_service.dart';

class MatchPredictionScreen extends StatefulWidget {
  const MatchPredictionScreen({super.key});

  @override
  State<MatchPredictionScreen> createState() => _MatchPredictionScreenState();
}

class _MatchPredictionScreenState extends State<MatchPredictionScreen> {
  late final PredictionsService _service;

  MatchModel? match;
  PredictionModel? myPrediction;

  int homeScore = 0;
  int awayScore = 0;

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<ApiClient>()) {
      Get.put<ApiClient>(ApiClient(), permanent: true);
    }

    _service = PredictionsService(Get.find<ApiClient>());
    _readArgsAndLoad();
  }

  Future<void> _readArgsAndLoad() async {
    final args = Get.arguments;

    if (args is MatchModel) {
      match = args;
    } else if (args is Map && args['match'] is MatchModel) {
      match = args['match'] as MatchModel;
    }

    if (match == null) {
      setState(() => isLoading = false);
      return;
    }

    await _loadMyPrediction();
  }

  Future<void> _loadMyPrediction() async {
    try {
      final prediction = await _service.getMyPredictionForMatch(match!.id);

      if (!mounted) return;

      setState(() {
        myPrediction = prediction;

        if (prediction != null) {
          homeScore = prediction.predictedHomeScore;
          awayScore = prediction.predictedAwayScore;
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      AppSnackbar.show('تنبيه', AppSnackbar.cleanError(e));
    }
  }

  Future<void> _submitPrediction() async {
    if (match == null || isSaving) return;

    if (homeScore < 0 || awayScore < 0) {
      AppSnackbar.show('تنبيه', 'لا يمكن أن تكون النتيجة أقل من صفر.');
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await _service.submitPrediction(
        matchId: match!.id,
        homeScore: homeScore,
        awayScore: awayScore,
      );

      if (!mounted) return;

      setState(() {
        myPrediction = response.data;
        isSaving = false;
      });

      AppSnackbar.show(
        'تم',
        response.message.isNotEmpty ? response.message : 'تم إرسال التوقع بنجاح.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      AppSnackbar.show('خطأ', e.message);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      AppSnackbar.show('خطأ', AppSnackbar.cleanError(e));
    }
  }

  void _increaseHome() {
    if (homeScore >= 50) return;
    setState(() => homeScore++);
  }

  void _decreaseHome() {
    if (homeScore <= 0) return;
    setState(() => homeScore--);
  }

  void _increaseAway() {
    if (awayScore >= 50) return;
    setState(() => awayScore++);
  }

  void _decreaseAway() {
    if (awayScore <= 0) return;
    setState(() => awayScore--);
  }

  @override
  Widget build(BuildContext context) {
    final currentMatch = match;

    if (currentMatch == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppScreenHeader(title: 'توقع النتيجة'),
        body: EmptyState(
          title: 'لا توجد بيانات',
          subtitle: 'لم يتم إرسال بيانات المباراة لهذه الصفحة.',
          icon: Icons.error_outline,
        ),
      );
    }

    final isOpen = currentMatch.predictionState.trim() == 'مفتوحة';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppScreenHeader(
        title: 'توقع النتيجة',
        subtitle: currentMatch.league,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.red))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                MadrajCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? AppColors.success.withOpacity(.1)
                              : AppColors.red.withOpacity(.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isOpen ? 'التوقعات مفتوحة' : 'التوقعات مغلقة',
                          style: TextStyle(
                            color: isOpen ? AppColors.success : AppColors.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: _TeamName(name: currentMatch.homeTeam),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _TeamName(name: currentMatch.awayTeam),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _ScorePicker(
                              title: currentMatch.homeTeam,
                              value: homeScore,
                              onIncrease: isOpen ? _increaseHome : null,
                              onDecrease: isOpen ? _decreaseHome : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ScorePicker(
                              title: currentMatch.awayTeam,
                              value: awayScore,
                              onIncrease: isOpen ? _increaseAway : null,
                              onDecrease: isOpen ? _decreaseAway : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      if (myPrediction != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.red.withOpacity(.07),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.red.withOpacity(.18),
                            ),
                          ),
                          child: Text(
                            'توقعك الحالي: ${myPrediction!.predictedHomeScore} - ${myPrediction!.predictedAwayScore}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                      if (isOpen)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _submitPrediction,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              isSaving
                                  ? 'جاري الإرسال...'
                                  : myPrediction == null
                                  ? 'إرسال التوقع'
                                  : 'تحديث التوقع',
                            ),
                          ),
                        )
                      else
                        const EmptyState(
                          title: 'التوقعات مغلقة',
                          subtitle:
                              'لا يمكن إرسال أو تعديل التوقع لهذه المباراة.',
                          icon: Icons.lock_outline,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _TeamName extends StatelessWidget {
  const _TeamName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w900,
        fontSize: 16,
      ),
    );
  }
}

class _ScorePicker extends StatelessWidget {
  const _ScorePicker({
    required this.title,
    required this.value,
    required this.onIncrease,
    required this.onDecrease,
  });

  final String title;
  final int value;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    final enabled = onIncrease != null && onDecrease != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          IconButton.filled(
            onPressed: enabled ? onIncrease : null,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '$value',
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w900,
                fontSize: 38,
              ),
            ),
          ),

          IconButton.outlined(
            onPressed: enabled ? onDecrease : null,
            icon: const Icon(Icons.remove_rounded),
          ),
        ],
      ),
    );
  }
}
