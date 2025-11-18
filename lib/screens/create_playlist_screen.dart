import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../models/track.dart';
import '../providers/music_provider.dart';
import '../widgets/playlist_cover.dart';

class CreatePlaylistScreen extends StatefulWidget {
  final List<Track>? initialTracks;
  final Playlist? playlistToEdit;
  
  const CreatePlaylistScreen({
    super.key,
    this.initialTracks,
    this.playlistToEdit,
  });

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPublic = true;
  late List<Track> _selectedTracks;
  List<Track> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.playlistToEdit != null;
    
    if (_isEditing && widget.playlistToEdit != null) {
      _nameController.text = widget.playlistToEdit!.nome;
      _descriptionController.text = widget.playlistToEdit!.descricao ?? '';
      _isPublic = widget.playlistToEdit!.ehPublica;
      _selectedTracks = List<Track>.from(widget.playlistToEdit!.faixas);
    } else {
      _selectedTracks = widget.initialTracks ?? [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _performSearch(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final musicProvider = context.read<MusicProvider>();
      await musicProvider.searchTracks(query);
      setState(() {
        _searchResults = musicProvider.searchTracksList;
        _isSearching = false;
      });
    });
  }

  void _toggleTrackSelection(Track track) {
    setState(() {
      if (_selectedTracks.any((t) => t.id == track.id)) {
        _selectedTracks.removeWhere((t) => t.id == track.id);
      } else {
        _selectedTracks.add(track);
      }
    });
  }

  bool _isTrackSelected(Track track) {
    return _selectedTracks.any((t) => t.id == track.id);
  }

  Future<void> _createPlaylist() async {
    if (!_formKey.currentState!.validate()) return;

    final musicProvider = context.read<MusicProvider>();

    bool success;
    if (_isEditing && widget.playlistToEdit != null) {
      success = await musicProvider.updateLocalPlaylistWithDetails(
        playlistId: widget.playlistToEdit!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
        tracks: _selectedTracks,
      );
    } else {
      success = await musicProvider.createLocalPlaylistWithDetails(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        isPublic: _isPublic,
        tracks: _selectedTracks,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing 
            ? 'Playlist atualizada com sucesso!' 
            : 'Playlist criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Retorna true para indicar que houve mudança
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(musicProvider.error ?? 
            (_isEditing ? 'Erro ao atualizar playlist' : 'Erro ao criar playlist')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Playlist _buildPreviewPlaylist() {
    final base = widget.playlistToEdit;
    final name = _nameController.text.trim().isEmpty
        ? (base?.nome ?? 'Nova Playlist')
        : _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? base?.descricao
        : _descriptionController.text.trim();

    return Playlist(
      id: base?.id ?? 'preview',
      nome: name,
      descricao: description,
      urlCapa: base != null && !base.ehLocal ? base.urlCapa : null,
      nomeCriador: base?.nomeCriador,
      faixas: _selectedTracks,
      criadaEm: base?.criadaEm ?? DateTime.now(),
      ehPublica: _isPublic,
      ehLocal: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewPlaylist = _buildPreviewPlaylist();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Playlist' : 'Criar Playlist'),
        actions: [
          TextButton(
            onPressed: _createPlaylist,
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    PlaylistCover(
                      playlist: previewPlaylist,
                      size: 200,
                      borderRadius: 12,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A capa usa as capas das primeiras músicas da playlist.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da playlist *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.music_note),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite um nome para a playlist';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Pública'),
                subtitle: Text(_isPublic ? 'Qualquer pessoa pode ver' : 'Apenas você pode ver'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              if (_selectedTracks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedTracks.length} ${_selectedTracks.length == 1 ? 'música selecionada' : 'músicas selecionadas'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Adicionar Músicas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar músicas...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _performSearch,
              ),
              const SizedBox(height: 16),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text('Nenhuma música encontrada'),
                  ),
                )
              else if (_searchResults.isNotEmpty)
                ..._searchResults.map((track) {
                  final isSelected = _isTrackSelected(track);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                    child: ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleTrackSelection(track),
                      ),
                      title: Text(track.titulo),
                      subtitle: Text(track.artista),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.add_circle_outline,
                        color: isSelected ? Theme.of(context).primaryColor : null,
                      ),
                      onTap: () => _toggleTrackSelection(track),
                    ),
                  );
                }),
              if (_selectedTracks.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Músicas Selecionadas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ..._selectedTracks.map((track) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _toggleTrackSelection(track),
                      ),
                      title: Text(track.titulo),
                      subtitle: Text(track.artista),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}


