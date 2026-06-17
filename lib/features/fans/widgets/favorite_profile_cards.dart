part of '../fan_profile_screen.dart';

class _FavoriteTeamCard extends StatelessWidget {
  const _FavoriteTeamCard({required this.team, required this.isMe, required this.onChoose, required this.onClear, this.margin});

  final FavoriteTeam? team;
  final bool isMe;
  final VoidCallback onChoose;
  final VoidCallback onClear;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderFill = isDark ? const Color(0xFF23232A) : AppColors.background;
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : AppColors.black);

    return MadrajCard(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (team != null)
            TeamBadge(shortName: team!.shortName, logoUrl: team!.logoUrl, primary: team!.primary, secondary: team!.secondary, size: 58)
          else
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: placeholderFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.red, size: 26),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  team?.name ?? (isMe ? 'اختر فريقك المفضل' : 'لم يحدد فريقًا مفضلًا'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: titleColor, fontWeight: FontWeight.w900, fontSize: 14.5, height: 1.25),
                ),
                if (team != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (team!.primary.computeLuminance() > .62 ? team!.secondary : team!.primary).withOpacity(isDark ? .18 : .10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      team!.league,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDark ? Colors.white70 : AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isMe)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TinyIconButton(icon: Icons.tune_rounded, color: AppColors.red, onTap: onChoose),
                if (team != null) ...[
                  const SizedBox(height: 8),
                  _TinyIconButton(icon: Icons.close_rounded, color: AppColors.muted, onTap: onClear),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _FavoritePlayerCard extends StatelessWidget {
  const _FavoritePlayerCard({required this.player, required this.isMe, required this.onChoose, required this.onClear, this.margin});

  final FavoritePlayer? player;
  final bool isMe;
  final VoidCallback onChoose;
  final VoidCallback onClear;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderFill = isDark ? const Color(0xFF23232A) : AppColors.background;
    final titleColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : AppColors.black);

    return MadrajCard(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (player != null)
            _PlayerAvatar(player: player!, size: 58)
          else
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: placeholderFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Icon(Icons.sports_soccer_outlined, color: AppColors.red, size: 26),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  player?.name ?? (isMe ? 'اختر لاعبك المفضل' : 'لم يحدد لاعبًا مفضلًا'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: titleColor, fontWeight: FontWeight.w900, fontSize: 14.5, height: 1.25),
                ),
                if (player != null) ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(isDark ? .18 : .08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${player!.club} • ${player!.position}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDark ? Colors.white70 : AppColors.muted, fontSize: 10.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isMe)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TinyIconButton(icon: Icons.tune_rounded, color: AppColors.red, onTap: onChoose),
                if (player != null) ...[
                  const SizedBox(height: 8),
                  _TinyIconButton(icon: Icons.close_rounded, color: AppColors.muted, onTap: onClear),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TinyIconButton extends StatelessWidget {
  const _TinyIconButton({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF23232A) : AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player, this.size = 50});

  final FavoritePlayer player;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmedName = player.name.trim();
    final initials = trimmedName.isEmpty ? 'لاعب' : (trimmedName.length <= 2 ? trimmedName : trimmedName.substring(0, 2));
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * .32),
      child: Container(
        width: size,
        height: size,
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF23232A) : AppColors.background,
        child: CachedAppImage(
          imageUrl: player.photoUrl,
          fit: BoxFit.cover,
          placeholder: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red)),
          errorWidget: Center(child: Text(initials, style: TextStyle(fontSize: size * .22, fontWeight: FontWeight.w900, color: AppColors.red))),
        ),
      ),
    );
  }
}

