import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/track.dart';

/// Tile para exibir uma faixa musical
class TrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToPlaylist;
  final bool isFavorite;
  final bool showFavoriteButton;
  final bool showAddToPlaylistButton;

  const TrackTile({
    super.key,
    required this.track,
    this.onFavorite,
    this.onAddToPlaylist,
    this.isFavorite = false,
    this.showFavoriteButton = true,
    this.showAddToPlaylistButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: track.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: track.coverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.music_note,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.music_note,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.music_note,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        
        title: Text(
          track.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.artist,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (track.sourceType != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    _getSourceIcon(track.sourceType!),
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getSourceName(track.sourceType!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão de favoritar
            if (showFavoriteButton && onFavorite != null)
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            
            // Botão de adicionar à playlist
            if (showAddToPlaylistButton && onAddToPlaylist != null)
              IconButton(
                onPressed: onAddToPlaylist,
                icon: const Icon(Icons.playlist_add),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            
            // Botão de reproduzir (abrir link)
            if (track.sourceUrl != null)
              IconButton(
                onPressed: () => _launchUrl(track.sourceUrl!),
                icon: const Icon(Icons.play_arrow),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  /// Obtém o ícone da fonte
  IconData _getSourceIcon(String sourceType) {
    switch (sourceType.toLowerCase()) {
      case 'deezer':
        return Icons.music_note;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'soundcloud':
        return Icons.cloud;
      case 'spotify':
        return Icons.music_note;
      default:
        return Icons.link;
    }
  }

  /// Obtém o nome da fonte
  String _getSourceName(String sourceType) {
    switch (sourceType.toLowerCase()) {
      case 'deezer':
        return 'Deezer';
      case 'youtube':
        return 'YouTube';
      case 'soundcloud':
        return 'SoundCloud';
      case 'spotify':
        return 'Spotify';
      default:
        return 'Link externo';
    }
  }

  /// Abre o link da faixa
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
