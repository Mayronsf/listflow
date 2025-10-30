# 🎵 OpenWhyd Music App - Instruções Completas

## ✅ Projeto Criado com Sucesso!

Este é um aplicativo Flutter completo para curadoria musical que consome a API pública do OpenWhyd.

## 📦 Estrutura do Projeto

```
lib/
├── models/              # Modelos de dados
│   ├── track.dart      # Modelo de faixa musical
│   ├── playlist.dart   # Modelo de playlist
│   └── user.dart       # Modelo de usuário
├── services/           # Serviços
│   ├── api_service.dart       # Consumo da API OpenWhyd
│   └── storage_service.dart   # Persistência local
├── providers/          # Gerenciamento de estado
│   ├── music_provider.dart    # Provider de música
│   └── theme_provider.dart    # Provider de tema
├── screens/            # Telas do aplicativo
│   ├── home_screen.dart              # Tela inicial
│   ├── playlist_detail_screen.dart   # Detalhes da playlist
│   ├── search_screen.dart            # Busca
│   ├── my_playlists_screen.dart      # Minhas playlists
│   └── profile_screen.dart           # Perfil
├── widgets/            # Widgets reutilizáveis
│   ├── loading_widget.dart    # Widgets de carregamento
│   ├── playlist_card.dart     # Card de playlist
│   ├── track_tile.dart        # Tile de faixa
│   ├── error_widget.dart      # Widget de erro
│   └── empty_widget.dart      # Widget de estado vazio
└── main.dart           # Arquivo principal
```

## 🚀 Como Executar o Projeto

### 1. Pré-requisitos
- Flutter SDK instalado (versão 3.0.0 ou superior)
- Android Studio ou VS Code
- Emulador Android ou dispositivo físico

### 2. Instalação
```bash
# Entre no diretório do projeto
cd api

# Instale as dependências
flutter pub get

# Execute o aplicativo
flutter run
```

### 3. Verificar Problemas
```bash
# Analisar o código
flutter analyze

# Executar testes
flutter test
```

## 🎨 Funcionalidades Implementadas

### ✅ Telas Completas
- [x] Tela Inicial com playlists populares
- [x] Tela de Detalhes da Playlist
- [x] Tela de Busca (faixas e playlists)
- [x] Tela de Minhas Playlists
- [x] Tela de Perfil com configurações

### ✅ Funcionalidades
- [x] Consumo da API OpenWhyd
- [x] Sistema de favoritos
- [x] Criação de playlists personalizadas
- [x] Persistência local com SharedPreferences
- [x] Tema escuro/claro
- [x] Busca de músicas e playlists
- [x] Navegação por abas

### ✅ Design
- [x] Material Design 3
- [x] Tema escuro por padrão
- [x] Interface responsiva
- [x] Skeleton loaders
- [x] Animações suaves

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Provider**: Gerenciamento de estado
- **HTTP**: Requisições à API
- **SharedPreferences**: Armazenamento local
- **CachedNetworkImage**: Cache de imagens
- **URLLauncher**: Abertura de links externos
- **Shimmer**: Efeitos de carregamento

## 📱 Navegação do App

1. **Home** - Playlists populares e faixas recentes
2. **Buscar** - Pesquisar músicas e playlists
3. **Minhas Playlists** - Gerenciar playlists locais
4. **Perfil** - Configurações e estatísticas

## 🔧 Próximos Passos (Melhorias Futuras)

### Funcionalidades Adicionais
1. **Player de Música**
   - Implementar mini player
   - Controles de reprodução
   - Fila de reprodução

2. **Social**
   - Seguir usuários
   - Compartilhar playlists
   - Comentários

3. **Descoberta**
   - Recomendações personalizadas
   - Gêneros musicais
   - Top charts

4. **Offline**
   - Download de músicas
   - Modo offline
   - Sincronização

### Melhorias Técnicas
1. **Performance**
   - Paginação de listas
   - Lazy loading
   - Otimização de imagens

2. **Testes**
   - Testes unitários
   - Testes de integração
   - Testes de widget

3. **CI/CD**
   - Configurar GitHub Actions
   - Builds automatizados
   - Deploy automático

## 🐛 Troubleshooting

### Problemas Comuns

#### 1. Erro ao executar flutter pub get
```bash
flutter clean
flutter pub get
```

#### 2. Erro de compilação
```bash
flutter clean
flutter pub get
flutter run
```

#### 3. Problemas com emulador
```bash
flutter devices
flutter run -d <device-id>
```

## 📚 Documentação da API

- **Base URL**: https://openwhyd.org/
- **Documentação**: https://openwhyd.github.io/openwhyd/API

### Endpoints Principais

```
GET /api/post?format=json&limit=20
# Retorna playlists populares

GET /api/playlist/:id?format=json
# Retorna detalhes de uma playlist

GET /api/search?q=<query>&format=json&limit=30
# Busca faixas e playlists

GET /api/user/:id?format=json&limit=50
# Retorna faixas de um usuário
```

## 👥 Trabalho em Grupo

### Divisão de Tarefas Sugerida (6 Integrantes)

1. **Integrante 1**: Implementação do player de música
2. **Integrante 2**: Funcionalidades sociais (seguir, compartilhar)
3. **Integrante 3**: Sistema de descoberta e recomendações
4. **Integrante 4**: Testes e documentação
5. **Integrante 5**: Design e UX (melhorias visuais)
6. **Integrante 6**: Performance e otimizações

### Cronograma Sugerido (23 dias)

**Semana 1 (Dias 1-7)**: Familiarização e melhorias básicas
- Entender a arquitetura do projeto
- Implementar melhorias no UI
- Adicionar validações e tratamento de erros

**Semana 2 (Dias 8-14)**: Funcionalidades avançadas
- Implementar player de música
- Adicionar funcionalidades sociais
- Sistema de descoberta

**Semana 3 (Dias 15-21)**: Testes e refinamentos
- Testes unitários e de integração
- Correção de bugs
- Otimizações de performance

**Dias 22-23**: Apresentação
- Preparar demonstração
- Documentação final
- Deploy (opcional)

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
