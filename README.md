# 🎵 Listflow - Aplicativo de Música

Um aplicativo Flutter moderno para descoberta e curadoria musical, integrado com a API do Spotify. Permite aos usuários explorar músicas, artistas, playlists populares e criar suas próprias playlists personalizadas.

## ✨ Funcionalidades Principais

### 🏠 Tela Inicial (Home)
- **Recomendações de Artistas**: Seção com artistas populares em formato circular (estilo Spotify/Deezer)
- **Playlists Populares**: Playlists em destaque do Spotify
- **Faixas em Alta**: Top 50 Brasil com as músicas mais populares do momento
- Pull-to-refresh para atualizar conteúdo
- Navegação direta para perfis de artistas e detalhes de playlists

### 🔍 Busca
- **Busca por Artistas**: Encontre artistas com fotos, gêneros e número de seguidores
- **Busca por Músicas**: Pesquise faixas com preview de áudio
- **Busca por Playlists**: Explore playlists do Spotify e suas próprias playlists locais
- Resultados em tempo real com abas separadas
- Navegação para perfis de artistas a partir dos resultados

### 🎤 Perfil do Artista
- Informações completas do artista (foto, nome, seguidores, gêneros)
- Lista de músicas mais populares do artista
- Botão para abrir perfil no Spotify
- Opções para favoritar músicas e adicionar à playlists

### 📋 Playlists
- **Playlists Populares**: Explore playlists em destaque do Spotify
- **Minhas Playlists**: Gerencie suas playlists locais
- **Criar Playlist**: Crie playlists personalizadas com nome, descrição e músicas
- **Editar Playlist**: Adicione ou remova músicas das suas playlists
- **Capa Automática**: Geração automática de capas baseadas nas músicas
- Visualização detalhada com todas as faixas

### ❤️ Sistema de Favoritos
- Marque músicas como favoritas
- Playlist automática "Músicas Curtidas"
- Sincronização automática entre favoritos e playlist
- Indicador visual de músicas favoritadas

### 🎧 Player de Preview
- Preview de áudio das músicas do Spotify
- Controles de reprodução (play/pause)
- Integração com just_audio

### 👤 Perfil do Usuário
- Estatísticas pessoais
- Configurações de tema
- Gerenciamento de dados locais
- Opções de limpeza de dados

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento multiplataforma
- **Dart**: Linguagem de programação
- **Provider**: Gerenciamento de estado reativo
- **HTTP**: Consumo da API do Spotify
- **Shared Preferences**: Persistência local de dados
- **Cached Network Image**: Cache inteligente de imagens
- **URL Launcher**: Abertura de links externos (Spotify)
- **Just Audio**: Reprodução de previews de áudio
- **Shimmer**: Efeitos de carregamento elegantes

## 📱 Telas do Aplicativo

### 1. Tela Inicial (HomeScreen)
- Seção de Recomendações de Artistas (horizontal scroll)
- Seção de Playlists Populares (horizontal scroll)
- Seção de Faixas em Alta (lista vertical)
- Funcionalidades de favoritar e adicionar à playlist diretamente da home

### 2. Tela de Busca (SearchScreen)
- Aba de Artistas: Busca e visualização de artistas
- Aba de Músicas: Busca de faixas com preview
- Aba de Playlists: Busca de playlists (Spotify + locais)
- Navegação para perfis e detalhes

### 3. Perfil do Artista (ArtistProfileScreen)
- Cabeçalho com foto, nome e informações
- Gêneros musicais em chips
- Lista de músicas mais populares
- Botão para abrir no Spotify
- Ações de favoritar e adicionar à playlist

### 4. Detalhes da Playlist (PlaylistDetailScreen)
- Capa da playlist (gerada automaticamente ou do Spotify)
- Informações da playlist (criador, número de faixas)
- Lista completa de músicas
- Ações por música (favoritar, adicionar à playlist)
- Suporte a playlists locais e do Spotify

### 5. Minhas Playlists (MyPlaylistsScreen)
- Lista de todas as playlists locais criadas
- Criação de novas playlists
- Edição e exclusão de playlists
- Visualização de estatísticas

### 6. Criar/Editar Playlist (CreatePlaylistScreen)
- Formulário para criar nova playlist
- Adição de músicas durante a criação
- Edição de playlists existentes
- Geração automática de capas

### 7. Perfil do Usuário (ProfileScreen)
- Estatísticas pessoais (favoritos, playlists)
- Configurações de tema
- Gerenciamento de dados
- Opções de limpeza

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.0.0 ou superior)
- Dart SDK
- Android Studio ou VS Code com extensão Flutter
- Dispositivo Android/iOS ou emulador

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/Mayronsf/listflow.git
   cd api
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**
   ```bash
   flutter run
   ```

### Configuração do Android

O arquivo `android/app/src/main/AndroidManifest.xml` já está configurado com:
- Permissão `INTERNET`: Para acessar a API do Spotify
- Permissão `ACCESS_NETWORK_STATE`: Para verificar conectividade

## 📁 Estrutura do Projeto

```
lib/
├── models/              # Modelos de dados
│   ├── track.dart      # Modelo de faixa musical
│   ├── playlist.dart   # Modelo de playlist
│   ├── artist.dart     # Modelo de artista
│   └── user.dart       # Modelo de usuário
├── services/           # Serviços
│   ├── spotify_service.dart    # Integração com API do Spotify
│   ├── storage_service.dart    # Persistência local
│   └── audio_player_service.dart # Player de áudio
├── providers/          # Gerenciamento de estado
│   ├── music_provider.dart      # Provider de música
│   └── theme_provider.dart      # Provider de tema
├── screens/            # Telas do aplicativo
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── artist_profile_screen.dart
│   ├── playlist_detail_screen.dart
│   ├── my_playlists_screen.dart
│   ├── create_playlist_screen.dart
│   └── profile_screen.dart
├── widgets/            # Widgets reutilizáveis
│   ├── artist_card.dart         # Card de artista (circular)
│   ├── playlist_card.dart       # Card de playlist
│   ├── playlist_cover.dart      # Capa de playlist (gerada)
│   ├── track_tile.dart          # Tile de faixa musical
│   ├── loading_widget.dart      # Widgets de carregamento
│   ├── error_widget.dart        # Widget de erro
│   └── empty_widget.dart        # Widget de estado vazio
└── main.dart          # Arquivo principal
```

## 🎨 Design e UX

- **Material Design 3**: Interface moderna e consistente
- **Tema Escuro Padrão**: Cores roxo, azul e preto inspiradas no Spotify/Deezer
- **Responsividade**: Adaptável a diferentes tamanhos de tela
- **Animações Suaves**: Transições fluidas entre telas
- **Feedback Visual**: 
  - Indicadores de carregamento
  - Estados de erro
  - Mensagens de confirmação (SnackBars)
  - Indicadores de favoritos
- **Capa Automática**: Geração inteligente de capas para playlists locais

## 🔧 Configurações

### API do Spotify
O aplicativo utiliza a API do Spotify com autenticação Client Credentials:
- Busca de artistas, músicas e playlists
- Playlists em destaque
- Top 50 Brasil
- Recomendações de artistas
- Informações de artistas e suas músicas populares

### Persistência Local
- Dados salvos com SharedPreferences
- Favoritos e playlists locais mantidos entre sessões
- Sincronização automática entre favoritos e playlist "Músicas Curtidas"
- Opção de limpeza de dados no perfil

### Tema
- Modo escuro por padrão
- Alternância entre tema claro e escuro
- Cores personalizadas inspiradas em plataformas de música modernas

## 📊 Funcionalidades Detalhadas

### Recomendações de Artistas
- Busca inteligente de artistas populares
- Exibição em cards circulares (estilo Spotify/Deezer)
- Navegação direta para perfil do artista
- Carregamento automático na inicialização

### Faixas em Alta
- Integração com playlist oficial "Top 50 - Brasil" do Spotify
- Fallback para músicas populares recentes
- Ações de favoritar e adicionar à playlist
- Atualização via pull-to-refresh

### Sistema de Favoritos
- Marcação visual de músicas favoritadas
- Playlist automática sincronizada
- Persistência local
- Acesso rápido em todas as telas

### Playlists Locais
- Criação ilimitada de playlists
- Edição completa (adicionar/remover músicas)
- Capas geradas automaticamente
- Exclusão de playlists
- Busca integrada nas playlists locais

## 🐛 Solução de Problemas

### Erro de Conectividade
- Verifique sua conexão com a internet
- A API do Spotify pode estar temporariamente indisponível
- Tente novamente após alguns instantes

### Erro de Carregamento
- Use pull-to-refresh para atualizar
- Reinicie o aplicativo se necessário
- Verifique se há atualizações disponíveis

### Dados Não Salvos
- Verifique se o SharedPreferences está funcionando
- Limpe os dados no perfil e tente novamente
- Certifique-se de ter espaço suficiente no dispositivo

### Preview de Áudio Não Funciona
- Algumas músicas podem não ter preview disponível
- Verifique sua conexão de internet
- Tente outra música

## 📝 Notas de Desenvolvimento

- **Arquitetura**: MVVM com Provider
- **Gerenciamento de Estado**: Provider para reatividade
- **Tratamento de Erros**: Try-catch com feedback visual
- **Performance**: 
  - Cache de imagens
  - Lazy loading
  - Otimização de requisições
- **Acessibilidade**: Suporte a leitores de tela

## 🤝 Contribuição

Este é um projeto acadêmico desenvolvido por um grupo de 6 integrantes. Para contribuir:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é destinado a fins acadêmicos e educacionais.

## 👥 Equipe

Desenvolvido por um grupo de 6 integrantes para trabalho de faculdade.

---

**Desenvolvido com ❤️ usando Flutter e a API do Spotify**
