import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/post_entity.dart';
import '../providers/feed_provider.dart';
import 'media_grid_widget.dart';

class PostCardWidget extends StatelessWidget {
  final PostEntity post;
  final VoidCallback? onCommentTap;

  const PostCardWidget({
    super.key,
    required this.post,
    this.onCommentTap,
  });

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: Foto, Nome do Autor e Data
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.author.profile?.avatarUrl != null
                      ? NetworkImage(post.author.profile!.avatarUrl!)
                      : null,
                  child: post.author.profile?.avatarUrl == null
                      ? Text(post.author.username[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.username.isNotEmpty
                            ? post.author.username
                            : post.author.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${post.author.username} • ${_formatDate(post.createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Opções de post (Ex: Excluir se for o dono)
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Texto da publicação
            if (post.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  post.text,
                  style: const TextStyle(fontSize: 15, height: 1.3),
                ),
              ),

            // Anexos de Mídia
            if (post.media.isNotEmpty) ...[
              MediaGridWidget(mediaList: post.media),
              const SizedBox(height: 10),
            ],

            const Divider(height: 1),

            // Botões de Interação (Curtir & Comentar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botão de Curtida Otimista
                TextButton.icon(
                  onPressed: () {
                    context.read<FeedProvider>().toggleLike(post.id);
                  },
                  icon: Icon(
                    post.hasLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.hasLiked ? Colors.red : Colors.grey[700],
                    size: 20,
                  ),
                  label: Text(
                    '${post.likesCount}',
                    style: TextStyle(
                      color: post.hasLiked ? Colors.red : Colors.grey[700],
                    ),
                  ),
                ),

                // Botão de Comentários
                TextButton.icon(
                  onPressed: onCommentTap,
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey[700],
                    size: 20,
                  ),
                  label: Text(
                    '${post.commentsCount}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),

                // Compartilhar
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey[700], size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}