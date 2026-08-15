import 'package:flutter/material.dart';
import '../../domain/entities/post_media_entity.dart';

class MediaGridWidget extends StatelessWidget {
  final List<PostMediaEntity> mediaList;

  const MediaGridWidget({super.key, required this.mediaList});

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) return const SizedBox.shrink();

    final count = mediaList.length;

    if (count == 1) {
      return _buildImageTile(mediaList.first.file, height: 260);
    }

    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _buildImageTile(mediaList[0].file, height: 200)),
          const SizedBox(width: 4),
          Expanded(child: _buildImageTile(mediaList[1].file, height: 200)),
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: count > 4 ? 4 : count,
      itemBuilder: (context, index) {
        if (index == 3 && count > 4) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildImageTile(mediaList[index].file),
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Text(
                  '+${count - 3}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }
        return _buildImageTile(mediaList[index].file);
      },
    );
  }

  Widget _buildImageTile(String url, {double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: height ?? 150,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }
}