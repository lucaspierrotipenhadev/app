import 'package:app/features/interactions/presentation/widgets/comments_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card_widget.dart';
import '../../../../core/api/api_client.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().fetchFeed(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedProvider>().fetchFeed();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => feedProvider.fetchFeed(refresh: true),
        child: Builder(
          builder: (context) {
            if (feedProvider.loading && feedProvider.posts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (feedProvider.error != null && feedProvider.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(feedProvider.error!),
                    ElevatedButton(
                      onPressed: () => feedProvider.fetchFeed(refresh: true),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (feedProvider.posts.isEmpty) {
              return const Center(
                child: Text('Nenhuma publicação encontrada.'),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: feedProvider.posts.length + (feedProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == feedProvider.posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = feedProvider.posts[index];
                return PostCardWidget(
                  post: post,
                  onCommentTap: () {
                    // Abrir Modal de Comentários ou Navegar para Detalhes
                    final apiClient = context.read<ApiClient>();
                    CommentsBottomSheet.show(context, post.id, apiClient);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }
}