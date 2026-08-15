import 'package:app/core/api/api_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/comment_api.dart';
import '../providers/comment_provider.dart';
import '../../../posts/presentation/providers/feed_provider.dart';

class CommentsBottomSheet extends StatefulWidget {
  final int postId;

  const CommentsBottomSheet({super.key, required this.postId});

  static void show(BuildContext context, int postId, ApiClient apiClient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider(
        create: (_) =>
            CommentProvider(api: CommentApi(apiClient), postId: postId)
              ..fetchComments(),
        child: CommentsBottomSheet(postId: postId),
      ),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final _controller = TextEditingController();

  Future<void> _handleSend(CommentProvider provider) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final success = await provider.addComment(text);
    if (success && mounted) {
      _controller.clear();
      FocusScope.of(context).unfocus(); // Fecha o teclado
      // Atualiza a contagem no PostCard no Feed de forma reativa
      context.read<FeedProvider>().incrementCommentCount(widget.postId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommentProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          // Puxador visual do BottomSheet
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Comentários',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(),

          // Lista de Comentários
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.comments.isEmpty) {
                  return const Center(
                    child: Text('Seja o primeiro a comentar!'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: provider.comments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comment = provider.comments[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              comment.author.profile!.avatarUrl != null
                              ? NetworkImage(comment.author.profile!.avatarUrl!)
                              : null,
                          child: comment.author.profile?.avatarUrl == null
                              ? Text(comment.author.username[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment.author.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(comment.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                comment.text,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            comment.hasLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: comment.hasLiked ? Colors.red : Colors.grey,
                            size: 16,
                          ),
                          onPressed: () => provider.toggleLike(comment.id),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Campo de Entrada para Novo Comentário
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Adicione um comentário...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: provider.sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.blue),
                    onPressed: provider.sending
                        ? null
                        : () => _handleSend(provider),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
