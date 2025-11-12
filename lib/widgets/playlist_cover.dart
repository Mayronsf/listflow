import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/playlist.dart';

/// Widget responsável por gerar a capa visual de uma playlist a partir das faixas.
class PlaylistCover extends StatelessWidget {
  final Playlist playlist;
  final double size;
  final double borderRadius;

  const PlaylistCover({
    super.key,
    required this.playlist,
    this.size = 150,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueTrackCovers = _extractDistinctTrackCovers();

    // Quando não há capas de faixas disponíveis, tenta usar a capa da playlist (caso remoto).
    if (uniqueTrackCovers.isEmpty && playlist.coverUrl != null) {
      return _buildSingleImage(playlist.coverUrl!);
    }

    if (uniqueTrackCovers.isEmpty) {
      return _buildFallback();
    }

    switch (uniqueTrackCovers.length) {
      case 1:
        return _buildSingleImage(uniqueTrackCovers.first);
      case 2:
        return _buildTwoImageLayout(uniqueTrackCovers);
      case 3:
        return _buildThreeImageLayout(uniqueTrackCovers);
      default:
        return _buildFourImageLayout(uniqueTrackCovers);
    }
  }

  List<String> _extractDistinctTrackCovers() {
    final seen = <String>{};
    final covers = <String>[];

    for (final track in playlist.tracks) {
      final url = track.coverUrl;
      if (url != null && url.isNotEmpty && seen.add(url)) {
        covers.add(url);
        if (covers.length == 4) {
          break;
        }
      }
    }

    return covers;
  }

  Widget _buildContainer(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSingleImage(String url) {
    return _buildContainer(_buildImage(url, BoxFit.cover));
  }

  Widget _buildTwoImageLayout(List<String> covers) {
    const spacing = 4.0;
    return _buildContainer(
      Row(
        children: [
          Expanded(child: _buildImage(covers[0], BoxFit.cover)),
          const SizedBox(width: spacing),
          Expanded(child: _buildImage(covers[1], BoxFit.cover)),
        ],
      ),
    );
  }

  Widget _buildThreeImageLayout(List<String> covers) {
    const spacing = 4.0;
    return _buildContainer(
      Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(covers[0], BoxFit.cover)),
                const SizedBox(width: spacing),
                Expanded(child: _buildImage(covers[1], BoxFit.cover)),
              ],
            ),
          ),
          const SizedBox(height: spacing),
          Expanded(child: _buildImage(covers[2], BoxFit.cover)),
        ],
      ),
    );
  }

  Widget _buildFourImageLayout(List<String> covers) {
    const spacing = 4.0;
    return _buildContainer(
      Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(covers[0], BoxFit.cover)),
                const SizedBox(width: spacing),
                Expanded(child: _buildImage(covers[1], BoxFit.cover)),
              ],
            ),
          ),
          const SizedBox(height: spacing),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(covers[2], BoxFit.cover)),
                const SizedBox(width: spacing),
                Expanded(child: _buildImage(covers[3], BoxFit.cover)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return _buildContainer(
      Center(
        child: Icon(
          Icons.music_note,
          size: size * 0.4,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildImage(String url, BoxFit fit) {
    if (url.startsWith('asset://')) {
      final assetPath = url.replaceFirst('asset://', '');
      return Image.asset(assetPath, fit: fit);
    }

    if (url.startsWith('file://')) {
      final filePath = url.replaceFirst('file://', '');
      if (kIsWeb) {
        // Web não suporta File, então exibe fallback.
        return _buildFallback();
      }
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(file, fit: fit);
      }
      return _buildFallback();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, _) => Container(
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: Icon(
          Icons.music_note,
          size: size * 0.3,
          color: Colors.grey[500],
        ),
      ),
      errorWidget: (context, _, __) => _buildFallback(),
    );
  }
}

