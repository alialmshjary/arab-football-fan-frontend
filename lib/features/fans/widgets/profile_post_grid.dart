part of '../fan_profile_screen.dart';

class _ProfilePostsGrid extends StatelessWidget {
  const _ProfilePostsGrid({required this.posts, required this.onOpenPost});

  final List<PostModel> posts;
  final ValueChanged<PostModel> onOpenPost;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionTitle(title: 'المنشورات', trailing: '${posts.length}'),
        if (posts.isEmpty)
          const EmptyState(
            title: 'لا توجد منشورات',
            subtitle: 'عندما ينشر المشجع ستظهر لقطاته هنا.',
            icon: Icons.grid_view_rounded,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: posts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: .86,
              ),
              itemBuilder: (context, index) {
                final post = posts[index];
                return _ProfilePostThumb(
                  post: post,
                  onTap: () => onOpenPost(post),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ProfilePostThumb extends StatelessWidget {
  const _ProfilePostThumb({required this.post, required this.onTap});

  final PostModel post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mediaUrl = ApiClient.mediaUrl(post.mediaUrl);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            post.isVideo
                ? Container(color: AppColors.black, child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 34))
                : Container(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF141419) : Colors.white,
                    child: CachedAppImage(
                      imageUrl: mediaUrl,
                      fit: BoxFit.contain,
                      errorWidget: Container(color: AppColors.border, child: const Icon(Icons.image_not_supported_outlined)),
                    ),
                  ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(.55), Colors.transparent])),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 14),
                    const SizedBox(width: 3),
                    Text('${post.likeCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const Spacer(),
          if (trailing != null) Text(trailing!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

