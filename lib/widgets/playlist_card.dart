import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/playlist.dart';

/// Card para exibir uma playlist
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showFavoriteButton;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.onFavorite,
    this.showFavoriteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Capa da playlist
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: playlist.coverUrl != null
                    ? (playlist.coverUrl!.startsWith('asset://')
                        ? Image.asset(
                            playlist.coverUrl!.replaceFirst('asset://', ''),
                            fit: BoxFit.cover,
                          )
                        : playlist.coverUrl!.startsWith('file://')
                            ? Image.file(
                                File(playlist.coverUrl!.replaceFirst('file://', '')),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: playlist.coverUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ))
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.music_note,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            
            // Título da playlist
            Text(
              playlist.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            
            // Informações adicionais
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (playlist.creatorName != null) ...[
                  Text(
                    'por ${playlist.creatorName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                ],
                Text(
                  '${playlist.trackCount} faixas',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            
            // Botão de favoritar (se aplicável)
            if (showFavoriteButton && onFavorite != null) ...[
              const SizedBox(height: 4),
              IconButton(
                onPressed: onFavorite,
                icon: const Icon(Icons.favorite_border),
                iconSize: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
