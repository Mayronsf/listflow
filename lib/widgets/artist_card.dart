import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/artist.dart';

/// Widget para exibir um card de artista (estilo Spotify/Deezer)
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;
  final double size;

  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto do artista (circular)
            ClipOval(
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: artist.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: artist.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: size * 0.4,
                            color: Colors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: size * 0.4,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: size * 0.4,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Nome do artista
            Text(
              artist.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

