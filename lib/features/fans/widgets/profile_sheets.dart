part of '../fan_profile_screen.dart';

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet({required this.controller});

  final FansController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 16, 18, MediaQuery.of(context).viewInsets.bottom + 18),
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99)))),
                const SizedBox(height: 18),
                const Text('تعديل الملف الشخصي', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 16),
                CustomTextField(controller: controller.displayNameController, hint: 'اسم العرض', icon: Icons.person_outline),
                const SizedBox(height: 12),
                CustomTextField(controller: controller.bioController, hint: 'نبذة قصيرة', icon: Icons.notes_rounded, maxLines: 3),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: controller.isSaving.value ? null : controller.pickAndUpdateImage,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('تغيير الصورة الشخصية'),
                ),
                const SizedBox(height: 14),
                CustomButton(label: 'حفظ التعديل', icon: Icons.save_rounded, isLoading: controller.isSaving.value, onPressed: () => controller.updateProfile()),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TeamPickerSheet extends StatefulWidget {
  const _TeamPickerSheet({required this.controller});

  final FansController controller;

  @override
  State<_TeamPickerSheet> createState() => _TeamPickerSheetState();
}

class _TeamPickerSheetState extends State<_TeamPickerSheet> {
  String selectedLeague = FavoriteTeamsCatalog.leagues.first;

  @override
  Widget build(BuildContext context) {
    final teams = FavoriteTeamsCatalog.teams.where((team) => team.league == selectedLeague).toList();
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .78,
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 16),
            const Text('اختر فريقك المفضل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: FavoriteTeamsCatalog.leagues.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final league = FavoriteTeamsCatalog.leagues[index];
                  final active = league == selectedLeague;
                  return ChoiceChip(
                    selected: active,
                    label: Text(league),
                    selectedColor: AppColors.red,
                    labelStyle: TextStyle(color: active ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w900),
                    onSelected: (_) => setState(() => selectedLeague = league),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                itemCount: teams.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 92, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return InkWell(
                    onTap: () async {
                      await widget.controller.chooseTeam(team);
                      Get.back<void>();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Theme.of(context).dividerColor),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 14, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        children: [
                          TeamBadge(shortName: team.shortName, logoUrl: team.logoUrl, primary: team.primary, secondary: team.secondary, size: 46),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(team.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                                const SizedBox(height: 3),
                                Text(team.league, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerPickerSheet extends StatefulWidget {
  const _PlayerPickerSheet({required this.controller});

  final FansController controller;

  @override
  State<_PlayerPickerSheet> createState() => _PlayerPickerSheetState();
}

class _PlayerPickerSheetState extends State<_PlayerPickerSheet> {
  String selectedLeague = FavoritePlayersCatalog.leagues.first;

  @override
  Widget build(BuildContext context) {
    final players = FavoritePlayersCatalog.players.where((player) => player.league == selectedLeague).toList();
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .78,
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 16),
            const Text('اختر لاعبك المفضل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: FavoritePlayersCatalog.leagues.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final league = FavoritePlayersCatalog.leagues[index];
                  final active = league == selectedLeague;
                  return ChoiceChip(
                    selected: active,
                    label: Text(league),
                    selectedColor: AppColors.red,
                    labelStyle: TextStyle(color: active ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w900),
                    onSelected: (_) => setState(() => selectedLeague = league),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                itemCount: players.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final player = players[index];
                  return InkWell(
                    onTap: () async {
                      await widget.controller.choosePlayer(player);
                      Get.back<void>();
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Theme.of(context).dividerColor),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 14, offset: const Offset(0, 8))],
                      ),
                      child: Row(
                        children: [
                          _PlayerAvatar(player: player, size: 58),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(player.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text('${player.club} • ${player.position}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_left_rounded, color: AppColors.muted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
