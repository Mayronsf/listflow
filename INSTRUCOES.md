# 🎵 ListFlow - Aplicativo de Curadoria Musical com Spotify

## ✅ Sobre o Projeto

ListFlow é um aplicativo Flutter completo para curadoria musical que utiliza a **Spotify Web API** para descobrir músicas, criar playlists e explorar o catálogo musical.

## 📦 Estrutura do Projeto

```
lib/
├── models/              # Modelos de dados
│   ├── track.dart      # Modelo de faixa musical
│   ├── playlist.dart   # Modelo de playlist
│   ├── artist.dart     # Modelo de artista
│   └── user.dart       # Modelo de usuário
├── services/           # Serviços
│   ├── spotify_service.dart   # Consumo da API Spotify
│   └── storage_service.dart   # Persistência local
├── providers/          # Gerenciamento de estado
│   ├── music_provider.dart    # Provider de música
│   └── theme_provider.dart    # Provider de tema
├── screens/            # Telas do aplicativo
│   ├── home_screen.dart              # Tela inicial
│   ├── playlist_detail_screen.dart   # Detalhes da playlist
│   ├── create_playlist_screen.dart   # Criar playlist
│   ├── search_screen.dart            # Busca
│   ├── my_playlists_screen.dart      # Minhas playlists
│   ├── profile_screen.dart           # Perfil
│   └── artist_profile_screen.dart    # Perfil do artista
├── widgets/            # Widgets reutilizáveis
│   ├── loading_widget.dart    # Widgets de carregamento
│   ├── playlist_card.dart     # Card de playlist
│   ├── playlist_cover.dart    # Capa da playlist
│   ├── track_tile.dart        # Tile de faixa
│   ├── artist_card.dart       # Card de artista
│   ├── error_widget.dart      # Widget de erro
│   └── empty_widget.dart      # Widget de estado vazio
└── main.dart           # Arquivo principal
```

## 🔑 Configuração da API Spotify

### 1. Criar Aplicativo no Spotify Dashboard
1. Acesse [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Faça login com sua conta Spotify
3. Clique em "Create app"
4. Preencha os dados do aplicativo
5. Em "Redirect URIs", adicione: `http://localhost:8888/callback`

### 2. Obter Credenciais
Após criar o app, você terá acesso ao:
- **Client ID**: Identificador público do seu app
- **Client Secret**: Chave secreta (não compartilhe!)

### 3. Configurar no Código
As credenciais já estão configuradas em `lib/services/spotify_service.dart`:
```dart
static const String _clientId = '0a508f9d317d4f11b6a7e88b6a8759ec';
static const String _clientSecret = 'd41314292a854b479a5528d84efafc3f';
```

## 🚀 Como Executar o Projeto

### 1. Pré-requisitos
- Flutter SDK instalado (versão 3.0.0 ou superior)
- VS Code ou Android Studio
- Chrome, emulador Android ou dispositivo físico

### 2. Instalação
```bash
# Entre no diretório do projeto
cd listflow

# Instale as dependências
flutter pub get

# Execute o aplicativo (Web)
flutter run -d chrome

# Execute no Android
flutter run -d android

# Execute no Windows
flutter run -d windows
```

### 3. Verificar Problemas
```bash
# Analisar o código
flutter analyze

# Executar testes
flutter test
```

## 🎨 Funcionalidades Implementadas

### ✅ Integração com Spotify
- [x] Autenticação OAuth 2.0 (Client Credentials)
- [x] Busca de músicas e artistas
- [x] Playlists populares brasileiras
- [x] Top 50 músicas do Brasil
- [x] Informações detalhadas de artistas
- [x] Abertura de faixas no Spotify

### ✅ Gerenciamento de Playlists
- [x] Criar playlists personalizadas (sempre públicas)
- [x] Adicionar/remover músicas
- [x] Visualizar detalhes da playlist
- [x] Minhas playlists salvas localmente

### ✅ Interface
- [x] Material Design 3
- [x] Tema escuro/claro
- [x] Navegação por abas
- [x] Cards de playlist com imagens
- [x] Skeleton loaders durante carregamento
- [x] Interface responsiva

### ✅ Persistência
- [x] SharedPreferences para dados locais
- [x] Cache de playlists criadas
- [x] Sistema de favoritos

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework multiplataforma
- **Provider**: Gerenciamento de estado
- **Spotify Web API**: Catálogo musical e dados
- **HTTP**: Requisições à API REST
- **SharedPreferences**: Armazenamento local
- **CachedNetworkImage**: Cache de imagens otimizado
- **URLLauncher**: Abertura de links no Spotify

## 🇧🇷 Código em Português

**Todo o código foi traduzido para português!** Isso inclui:

### Modelos (Models)
- ✅ Todos os atributos traduzidos (title → titulo, artist → artista, coverUrl → urlCapa)
- ✅ Todos os métodos traduzidos (fromJson → deJson, toJson → paraJson, copyWith → copiarCom)
- ✅ Getters traduzidos (trackCount → quantidadeFaixas, isFavorite → ehFavorito)

### Serviços (Services)
- ✅ Todos os métodos do SpotifyService traduzidos:
  - `buscarTudo()` - Busca geral
  - `obterPlaylistsEmDestaque()` - Playlists populares
  - `obterFaixasDaPlaylist()` - Músicas de uma playlist
  - `obterArtistaPorId()` - Dados de um artista
  - `obterFaixasDoArtista()` - Top músicas do artista
  - `obterTopFaixasBrasil()` - Top 50 Brasil
  - `obterArtistasRecomendados()` - Artistas recomendados

- ✅ Todos os métodos do StorageService traduzidos:
  - `salvarFavoritas()` / `carregarFavoritas()`
  - `salvarPlaylistsLocais()` / `carregarPlaylistsLocais()`
  - `adicionarFavorita()` / `removerFavorita()`
  - `adicionarPlaylistLocal()` / `atualizarPlaylistLocal()`
  - `limparTodosDados()` / `limparFavoritas()`

### Providers
- ✅ MusicProvider com métodos traduzidos para gerenciar estado
- ✅ ThemeProvider com métodos traduzidos para tema

### Benefícios da Tradução
1. **Código mais legível** para desenvolvedores brasileiros
2. **Facilita manutenção** e compreensão do projeto
3. **Melhor para apresentação** em ambiente acadêmico brasileiro
4. **Consistência** em todo o código

## 📱 Navegação do App

1. **Home** - Playlists populares e top músicas do Brasil
2. **Buscar** - Pesquisar músicas e artistas no Spotify
3. **Minhas Playlists** - Criar e gerenciar playlists locais
4. **Perfil** - Configurações de tema e informações

## 📚 API Spotify - Principais Endpoints Utilizados

### Autenticação
```
POST https://accounts.spotify.com/api/token
Content-Type: application/x-www-form-urlencoded
grant_type=client_credentials
```

### Busca
```
GET /v1/search?q={query}&type=track,artist&market=BR&limit=20
# Busca músicas e artistas
```

### Playlists
```
GET /v1/search?q={query}&type=playlist&market=BR&limit=20
# Busca playlists por tema

GET /v1/playlists/{playlist_id}/tracks
# Obtém faixas de uma playlist
```

### Artistas
```
GET /v1/artists/{artist_id}
# Informações detalhadas do artista

GET /v1/artists/{artist_id}/top-tracks?market=BR
# Top músicas do artista
```

## 🔧 Limitações da API

### Client Credentials Flow
O app usa **Client Credentials**, que tem algumas limitações:
- ❌ Não acessa dados do usuário autenticado
- ❌ Não pode criar/modificar playlists no Spotify
- ✅ Permite buscar músicas, artistas e playlists
- ✅ Permite obter informações públicas

### Preview de Músicas
- Nem todas as músicas têm preview disponível na API
- Quando disponível, são clipes de ~30 segundos
- O app redireciona para o Spotify para reprodução completa

## 💡 Exemplos de Uso

### Buscar Músicas
```dart
// No MusicProvider
final resultado = await _spotify.buscarTudo('Linkin Park');
final faixas = resultado['tracks']['items'];
```

### Adicionar aos Favoritos
```dart
// Adiciona uma música aos favoritos
await musicProvider.addToFavorites(track);

// Verifica se está nos favoritos
final ehFavorita = musicProvider.isFavorite(track.id);
```

### Criar Playlist Local
```dart
// Cria uma nova playlist
await musicProvider.createLocalPlaylistWithDetails(
  name: 'Minha Playlist',
  description: 'As melhores músicas',
  tracks: minhasFaixas,
);
```

### Trabalhar com Modelos
```dart
// Criar uma cópia modificada de uma música
final musicaFavorita = track.copiarCom(ehFavorito: true);

// Adicionar faixa a uma playlist
final playlistAtualizada = playlist.adicionarFaixa(novaFaixa);

// Verificar se playlist contém música
if (playlist.contemFaixa(track.id)) {
  print('Música já está na playlist!');
}
```

## 🔧 Próximas Melhorias

### Funcionalidades
1. **Autenticação de Usuário**
   - Implementar Authorization Code Flow
   - Sincronizar playlists com conta Spotify
   - Seguir artistas e playlists

2. **Descoberta Musical**
   - Gêneros e categorias
   - Álbuns populares
   - Lançamentos da semana

3. **Social**
   - Compartilhar playlists
   - Exportar para Spotify
   - Integração com redes sociais

### Melhorias Técnicas
1. **Performance**
   - Paginação infinita
   - Lazy loading de imagens
   - Cache de requisições

2. **Testes**
   - Testes unitários dos services
   - Testes de widget
   - Testes de integração

3. **UX/UI**
   - Animações de transição
   - Modo de visualização compacto
   - Filtros avançados de busca

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Erro 401 (Unauthorized)
- Verifique se as credenciais do Spotify estão corretas
- Token de acesso pode ter expirado (válido por 1 hora)
- O serviço renova automaticamente quando necessário

#### 2. Erro ao executar flutter pub get
```bash
flutter clean
flutter pub get
```

#### 3. Erro de compilação
```bash
flutter clean
flutter pub get
flutter run
```

#### 4. App não abre links no Spotify
- Certifique-se de ter o Spotify instalado
- No navegador, pode abrir a versão web

## 🎯 Estrutura de Dados

### Track Model (Modelo de Música)
```dart
class Track {
  final String id;
  final String titulo;              // Título da música
  final String artista;              // Nome do artista
  final String? urlCapa;             // URL da capa do álbum
  final String? urlFonte;            // URL no Spotify
  final String? urlPrevia;           // URL do preview (30s)
  final String? tipoFonte;           // 'spotify', 'local', etc
  final String? idPlaylist;          // ID da playlist (se aplicável)
  final DateTime criadoEm;           // Data de criação
  final bool ehFavorito;             // Se está nos favoritos
}
```

### Playlist Model (Modelo de Playlist)
```dart
class Playlist {
  final String id;
  final String nome;                 // Nome da playlist
  final String? descricao;           // Descrição
  final String? urlCapa;             // URL da capa
  final String? idCriador;           // ID do criador
  final String? nomeCriador;         // Nome do criador
  final List<Track> faixas;          // Lista de músicas
  final DateTime criadaEm;           // Data de criação
  final bool ehPublica;              // Se é pública
  final bool ehLocal;                // Se foi criada localmente
  
  // Métodos úteis
  int get quantidadeFaixas => faixas.length;
  Playlist adicionarFaixa(Track faixa);
  Playlist removerFaixa(String idFaixa);
  bool contemFaixa(String idFaixa);
}
```

### Artist Model (Modelo de Artista)
```dart
class Artist {
  final String id;
  final String nome;                 // Nome do artista
  final String? urlCapa;             // URL da foto
  final int? seguidores;             // Número de seguidores
  final List<String> generos;        // Gêneros musicais
  final String? urlSpotify;          // Link para o Spotify
}
```

### User Model (Modelo de Usuário)
```dart
class User {
  final String id;
  final String nome;                      // Nome do usuário
  final String? email;                    // Email
  final String? urlAvatar;                // URL do avatar
  final String? bio;                      // Biografia
  final List<String> idsFaixasFavoritas;  // IDs das músicas favoritas
  final List<String> idsPlaylistsLocais;  // IDs das playlists locais
  final bool ehModoEscuro;                // Preferência de tema
}
```

## 📖 Recursos Adicionais

- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)

---

**Desenvolvido com Flutter 💙 e Spotify Web API 🎵**

## 🎯 Critérios de Avaliação (Sugestão)

- ✅ Funcionalidade (30%)
- ✅ Design e UX (25%)
- ✅ Código limpo e organizado (20%)
- ✅ Documentação (15%)
- ✅ Testes (10%)

## 📝 Notas Importantes

1. **API Pública**: A API do OpenWhyd é pública e não requer autenticação
2. **Limitações**: A API pode ter limitações de taxa de requisições
3. **Dados Locais**: Os dados são armazenados localmente no dispositivo
4. **Internet**: O app requer conexão com internet para funcionar

## 🤝 Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📧 Suporte

Se encontrar problemas ou tiver dúvidas:
1. Verifique a seção de Troubleshooting
2. Consulte a documentação da API
3. Entre em contato com o grupo

---

**Desenvolvido com ❤️ para o trabalho de faculdade**
**Prazo: 23 dias | Grupo: 6 integrantes**
