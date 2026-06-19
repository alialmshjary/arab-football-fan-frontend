import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/media/media_compressor.dart';
import '../../core/storage/storage_service.dart';
import '../../core/utils/auth_guard.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/widgets/cached_app_image.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../app/routes/app_routes.dart';
import '../fans/fan_model.dart';
import '../fans/fans_controller.dart';
import '../comments/comment_model.dart';
import '../comments/comments_controller.dart';
import 'post_model.dart';
import 'posts_controller.dart';
import 'widgets/post_card.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late final PostsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PostsController>();
    if (controller.posts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.loadFeed(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Obx(() {
      if (controller.isLoading.value && controller.posts.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.red),
        );
      }
      if (controller.posts.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.loadFeed,
          color: AppColors.red,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 160),
              EmptyState(
                title: 'لا توجد منشورات من المستخدمين الآخرين',
                subtitle:
                    'منشوراتك تظهر في بروفايلك، والمجتمع يعرض منشورات باقي المشجعين فقط.',
                icon: Icons.groups_2_outlined,
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.loadFeed,
        color: AppColors.red,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return PostCard(
              post: post,
              onTap: () => controller.openPost(post),
              onLike: () => controller.toggleLike(post),
              onComment: () => controller.openPost(post),
              onBookmark: () => controller.toggleBookmark(post),
              onEdit: post.fanId == controller.currentUserId
                  ? () => showEditPostSheet(context, post)
                  : null,
              onDelete: () => controller.deletePost(post),
            );
          },
        ),
      );
    });

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppScreenHeader(
        title: 'المجتمع',
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!AuthGuard.requireLogin(
                message:
                    'يجب عليك تسجيل الدخول أولاً حتى تتمكن من البحث وفتح الملفات الشخصية.',
              ))
                return;
              _showFanSearchSheet(context);
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () {
              if (!AuthGuard.requireLogin(
                message:
                    'يجب عليك تسجيل الدخول أولاً حتى تتمكن من إنشاء منشور.',
              ))
                return;
              showCreatePostSheet(context);
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: body,
    );
  }
}

void _showFanSearchSheet(BuildContext context) {
  if (!AuthGuard.requireLogin(
    message:
        'يجب عليك تسجيل الدخول أولاً حتى تتمكن من البحث وفتح الملفات الشخصية.',
  ))
    return;
  final fansController = Get.find<FansController>();
  fansController.clearSearch();
  Get.bottomSheet(
    _PostFanSearchSheet(controller: fansController),
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
  );
}

void showCreatePostSheet(BuildContext context) {
  if (!AuthGuard.requireLogin(
    message: 'يجب عليك تسجيل الدخول أولاً حتى تتمكن من إنشاء منشور.',
  ))
    return;
  final controller = Get.find<PostsController>();
  Get.bottomSheet(
    _CreatePostSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
  );
}

void showEditPostSheet(BuildContext context, PostModel post) {
  final controller = Get.find<PostsController>();
  Get.bottomSheet(
    _EditPostSheet(controller: controller, post: post),
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
  );
}

class _CreatePostSheet extends StatelessWidget {
  const _CreatePostSheet({required this.controller});

  final PostsController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Obx(() {
          final path = controller.selectedMediaPath.value;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'منشور جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.captionController,
                  hint: 'اكتب تعليقك على اللقطة...',
                  icon: Icons.edit_note_rounded,
                  maxLines: 4,
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: controller.pickMedia,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: path == null ? 118 : 220,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF23232A)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: path == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppColors.red,
                                size: 34,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'اختر صورة أو فيديو',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'يدعم التطبيق الصور والفيديوهات بالامتدادات المسموحة',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return const Center(
                                  child: Text(
                                    'تم اختيار ملف ميديا',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                CustomButton(
                  label: 'نشر الآن',
                  icon: Icons.send_rounded,
                  isLoading: controller.isCreating.value,
                  onPressed: controller.createPost,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _EditPostSheet extends StatefulWidget {
  const _EditPostSheet({required this.controller, required this.post});

  final PostsController controller;
  final PostModel post;

  @override
  State<_EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<_EditPostSheet> {
  late final TextEditingController captionController;
  String? newMediaPath;

  @override
  void initState() {
    super.initState();
    captionController = TextEditingController(text: widget.post.caption ?? '');
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final media = await picker.pickMedia(imageQuality: 86);
    if (media == null) return;

    final compressedPath = await MediaCompressor.compressMedia(media.path);
    setState(() => newMediaPath = compressedPath);
  }

  Future<void> _save() async {
    final ok = await widget.controller.updatePost(
      widget.post,
      caption: captionController.text,
      mediaPath: newMediaPath,
    );
    if (ok) Get.back<void>();
  }

  @override
  Widget build(BuildContext context) {
    final currentMedia = ApiClient.mediaUrl(widget.post.mediaUrl);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          16,
          18,
          MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'تعديل المنشور',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: captionController,
                hint: 'اكتب نص المنشور...',
                icon: Icons.edit_note_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickMedia,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 230,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF23232A)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (newMediaPath != null)
                          Image.file(
                            File(newMediaPath!),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text(
                                'تم اختيار ملف ميديا',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          )
                        else if (widget.post.isVideo)
                          const Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              size: 54,
                              color: AppColors.red,
                            ),
                          )
                        else
                          CachedAppImage(
                            imageUrl: currentMedia,
                            fit: BoxFit.contain,
                            errorWidget: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.62),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'تغيير الميديا',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Obx(
                () => CustomButton(
                  label: 'حفظ التعديل',
                  icon: Icons.check_rounded,
                  isLoading: widget.controller.isUpdating.value,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }
}

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  late final PostsController postsController;
  late final CommentsController commentsController;
  int postId = 0;

  @override
  void initState() {
    super.initState();
    postsController = Get.find<PostsController>();
    commentsController = Get.find<CommentsController>();
    _readArgsAndLoad();
  }

  void _readArgsAndLoad() {
    final args = Get.arguments;
    PostModel? seed;

    if (args is PostModel) {
      seed = args;
      postId = args.id;
    } else if (args is int) {
      postId = args;
    } else if (args is Map) {
      final possiblePost = args['post'];
      if (possiblePost is PostModel) seed = possiblePost;
      final rawId = args['postId'] ?? args['id'];
      postId = rawId is int ? rawId : int.tryParse('$rawId') ?? seed?.id ?? 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      commentsController.comments.clear();
      commentsController.commentController.clear();
      if (postId > 0) {
        postsController.loadPostById(postId, seed: seed);
        commentsController.loadComments(postId);
      } else {
        postsController.selectedPost.value = seed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppScreenHeader(
        title: 'المنشور',
        subtitle: null,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: postId > 0
                ? () => postsController.loadPostById(postId)
                : null,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final post = postsController.selectedPost.value;
              if (postsController.isPostLoading.value && post == null) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.red),
                );
              }
              if (post == null || post.id == 0) {
                return const EmptyState(
                  title: 'لم يتم العثور على المنشور',
                  subtitle:
                      'افتح المنشور من البروفايل أو المجتمع، أو تأكد أن المنشور ما زال متاحًا.',
                  icon: Icons.article_outlined,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await postsController.loadPostById(post.id, seed: post);
                  await commentsController.loadComments(post.id);
                },
                color: AppColors.red,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    PostCard(
                      post: post,
                      onLike: () => postsController.toggleLike(post),
                      onComment: () {},
                      onBookmark: () => postsController.toggleBookmark(post),
                      onEdit: post.fanId == postsController.currentUserId
                          ? () => showEditPostSheet(context, post)
                          : null,
                      onDelete: () => postsController.deletePost(post),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                      child: Text(
                        'التعليقات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (commentsController.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: AppColors.red,
                            ),
                          ),
                        );
                      }
                      if (commentsController.comments.isEmpty) {
                        return const EmptyState(
                          title: 'لا توجد تعليقات',
                          subtitle: 'ابدأ النقاش مع جمهور المدرج.',
                          icon: Icons.mode_comment_outlined,
                        );
                      }
                      return Column(
                        children: commentsController.comments.map((comment) {
                          final canDelete =
                              comment.fanId == postsController.currentUserId ||
                              post.fanId == postsController.currentUserId;
                          return _CommentTile(
                            comment: comment,
                            canDelete: canDelete,
                            isDeleting: commentsController.deletingCommentIds
                                .contains(comment.id),
                            onDelete: canDelete
                                ? () async {
                                    final deleted = await commentsController
                                        .deleteComment(comment);
                                    if (deleted)
                                      await postsController.loadPostById(
                                        post.id,
                                        seed: post,
                                      );
                                  }
                                : null,
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
          Obx(() {
            final post = postsController.selectedPost.value;
            return _CommentInput(
              postId: post?.id ?? 0,
              controller: commentsController,
              postsController: postsController,
            );
          }),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.canDelete,
    required this.isDeleting,
    this.onDelete,
  });

  final CommentModel comment;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return MadrajCard(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            imageUrl: comment.fanProfilePic,
            name: comment.fanName,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.fanName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(height: 1.45)),
              ],
            ),
          ),
          if (canDelete)
            IconButton(
              tooltip: 'حذف التعليق',
              onPressed: isDeleting ? null : onDelete,
              icon: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.red,
                      ),
                    )
                  : const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.muted,
                      size: 21,
                    ),
            ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.postId,
    required this.controller,
    required this.postsController,
  });

  final int postId;
  final CommentsController controller;
  final PostsController postsController;

  @override
  Widget build(BuildContext context) {
    if (StorageService.isGuest) {
      return InkWell(
        onTap: () => AuthGuard.showLoginRequiredDialog(
          message: 'يجب عليك تسجيل الدخول أولاً حتى تتمكن من كتابة تعليق.',
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            MediaQuery.of(context).padding.bottom + 14,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: const Text(
            'سجل دخولك للتعليق على المنشور',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.commentController,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقاً...',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            return IconButton.filled(
              onPressed: controller.isSending.value || postId == 0
                  ? null
                  : () async {
                      final added = await controller.addComment(postId);
                      if (added) await postsController.loadPostById(postId);
                    },
              style: IconButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
              ),
              icon: controller.isSending.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            );
          }),
        ],
      ),
    );
  }
}

class _PostFanSearchSheet extends StatelessWidget {
  const _PostFanSearchSheet({required this.controller});

  final FansController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .76,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'البحث عن مستخدمين',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller.searchController,
                textInputAction: TextInputAction.search,
                onChanged: controller.searchFans,
                onSubmitted: controller.searchFans,
                decoration: InputDecoration(
                  hintText: 'اكتب اسم المستخدم أو اسم العرض...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Obx(
                    () => controller.isSearching.value
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.red,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (controller.searchText.value.isEmpty) {
                    return const EmptyState(
                      title: 'ابدأ بالبحث',
                      subtitle:
                          'يمكنك البحث عن المشجعين ثم فتح بروفايل أي حساب.',
                      icon: Icons.search_rounded,
                    );
                  }
                  if (controller.isSearching.value &&
                      controller.searchResults.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.red),
                    );
                  }
                  if (controller.searchResults.isEmpty) {
                    return const EmptyState(
                      title: 'لا توجد نتائج',
                      subtitle: 'جرّب اسم مستخدم آخر.',
                      icon: Icons.person_search_outlined,
                    );
                  }
                  return ListView.separated(
                    itemCount: controller.searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _PostFanSearchResultTile(
                      fan: controller.searchResults[index],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostFanSearchResultTile extends StatelessWidget {
  const _PostFanSearchResultTile({required this.fan});

  final FanBasicProfile fan;

  @override
  Widget build(BuildContext context) {
    return MadrajCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: () {
          if (!AuthGuard.requireLogin(
            message:
                'يجب عليك تسجيل الدخول أولاً حتى تتمكن من فتح الملفات الشخصية.',
          ))
            return;
          Get.back<void>();
          Get.toNamed(
            Routes.fanProfile,
            arguments: {'fanId': fan.id, 'fan': fan},
          );
        },
        leading: AppAvatar(
          imageUrl: fan.profilePicUrl,
          name: fan.displayName,
          radius: 22,
        ),
        title: Text(
          fan.displayName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          fan.bio?.trim().isNotEmpty == true ? fan.bio! : 'مشجع في مجتمع مدرج',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}
