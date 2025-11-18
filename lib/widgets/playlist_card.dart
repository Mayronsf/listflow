import 'package:flutter/material.dart';

import '../models/playlist.dart';
import 'playlist_cover.dart';

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
            PlaylistCover(playlist: playlist, size: 150),
            const SizedBox(height: 4),
            
            Text(
              playlist.nome,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (playlist.nomeCriador != null) ...[
              const SizedBox(height: 4),
              Text(
                'por ${playlist.nomeCriador}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 1),
            Text(
              '${playlist.quantidadeFaixas} faixas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
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
