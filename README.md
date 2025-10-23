# 🌿 Leafy — Seu Assistente de Plantas

> Aplicativo Flutter para ajudar utilizadores a lembrar de cuidar das suas plantas, com um fluxo de onboarding focado em privacidade (LGPD) e personalização de perfil (Avatar).

---

## 🧭 Visão Geral

O **Leafy** é um aplicativo de cuidados com plantas desenvolvido como parte da disciplina de Desenvolvimento Móvel (DM). O objetivo é ajudar utilizadores com rotinas corridas, como estudantes, a lembrar de regar e cuidar das suas plantas através de lembretes e checklists.

Na **primeira execução**, o utilizador é guiado por um onboarding, lê e aceita as políticas de privacidade (com consentimento explícito) e é levado à tela principal, onde pode (na Fase 2) personalizar o seu perfil com um avatar.

### 🎯 Objetivo
Ajudar utilizadores a manter as suas plantas saudáveis através de uma interface acessível (A11Y), respeitando a privacidade (LGPD) com todos os dados salvos localmente.

### 🧩 Principais Funcionalidades
- **Fase 1 (Onboarding/LGPD):**
    - Fluxo de onboarding com `PageView` e `SmoothPageIndicator`.
    - Visualizador de Políticas (Markdown) com barra de progresso de leitura.
    - Consentimento explícito (Opt-in) que só é habilitado após o *scroll* total.
    - Direito de Recusa (fechar o app) e Revogação de consentimento com "Desfazer" (`SnackBar`).
- **Fase 2 (Avatar):**
    - Seleção de Avatar via Câmera ou Galeria (`image_picker`).
    - Gestão de Permissões (`permission_handler`).
    - Processamento de Imagem (LGPD): Remoção de metadados EXIF/GPS e compressão.
    - Persistência Segura: Avatar salvo na pasta interna do app (não na galeria pública).
    - *Fallback* de UI (mostra as iniciais "GU" se não houver avatar).

---

## 🧍 Persona

**Guilherme**, um estudante universitário de engenharia de software que mora sozinho. Ele gosta de ter plantas no seu apartamento, mas, devido à rotina corrida de estudos e projetos, muitas vezes esquece de as regar, resultando em plantas murchas. Ele precisa de lembretes simples e visuais para o ajudar a manter a consistência.

---

## 🎨 Identidade Visual (Tema "Leafy")

| Elemento | Valor | Cor |
|-----------|--------|------|
| **Primária** | `#22C55E` | Verde (Green) |
| **Secundária** | `#0EA5E9` | Azul (Blue) |
| **Superfície/Fundo**| `#1F2937` | Ardósia (Slate Dark) |
| **Texto/Sobre** | `#FFFFFF` | Branco |
| **Estilo** | Dark Mode, Material 3, alto contraste (A11Y) |
| **Ícone do app** | Uma folha estilizada (ex: `Icons.eco`) |

*(Nota: O ícone do app não foi gerado via `flutter_launcher_icons` nesta fase, usando o fallback do Flutter).*

---

## 🧭 Fluxo do Utilizador (Fase 1 e 2)

1. **Splash** → verifica `PrefsService` (`isOnboardingComplete`).
2. **Onboarding (3 telas + consentimento)**
    - Tela 1: Boas-vindas
    - Tela 2: Lembretes
    - Tela 3: Privacidade
3. **Consentimento (LGPD)**
    - Botão "Pular" (Onboarding) ou "Concluir" leva para aqui.
    - Botão "Recusar" (X) mostra `AlertDialog` e fecha o app.
    - Leitura da política (Markdown) com barra de progresso.
    - Aceite (Checkbox) só habilita após *scroll* total.
4. **Home (Fase 1)**
    - Tela principal (vazia por enquanto).
    - `Drawer` (Menu Lateral) com Avatar de *fallback* ("GU").
    - Opção "Revogar Consentimento" com `SnackBar` e "Desfazer".
5. **Home (Fase 2 - Clique no Avatar)**
    - `showModalBottomSheet` (Câmera / Galeria).
    - Pedido de Permissão (Câmera ou Galeria).
    - Imagem é processada (LGPD/Compressão) e salva internamente.
    - UI atualiza (`setState`) mostrando a nova foto.
6. **Reabertura do App**
    - Splash → `isOnboardingComplete` (true) → `_loadAvatar()` (lê o caminho salvo) → Home (mostra a foto direto).

---

## ⚙️ Requisitos Funcionais (RF)

| ID | Descrição | Fase |
|----|------------|------|
| RF-1 | Splash deve decidir a rota (`/home` ou `/onboarding`) com base no `PrefsService`. | 1 |
| RF-2 | Indicador de "dots" (`SmoothPageIndicator`) deve sincronizar com o `PageView`. | 1 |
| RF-3 | Viewer Markdown deve ter barra de progresso de leitura. | 1 |
| RF-4 | Botão "Avançar" (Consentimento) deve ser desabilitado até o *scroll* total e o *opt-in*. | 1 |
| RF-5 | Utilizador deve poder "Recusar" (fechar o app) ou "Revogar" (com "Desfazer"). | 1 |
| RF-6 | Avatar "GU" (fallback) deve ser clicável (A11Y 48dp + Semantics). | 2 |
| RF-7 | `ModalBottomSheet` deve perguntar (Câmera/Galeria). | 2 |
| RF-8 | App deve pedir permissões (`permission_handler`) antes de usar Câmera/Galeria. | 2 |
| RF-9 | Imagem selecionada deve ter metadados (EXIF/GPS) removidos (LGPD). | 2 |
| RF-10 | Imagem processada deve ser salva na pasta interna do app (não na galeria pública). | 2 |
| RF-11 | Caminho do avatar salvo deve persistir (`PrefsService`) e carregar no `initState`. | 2 |
| RF-12 | UI do avatar deve atualizar imediatamente (`setState`) após a seleção. | 2 |
| RF-13 | Revogação (RF-5) deve também apagar o avatar salvo. | 2 |

---

## 🧩 Requisitos Não Funcionais (RNF)

- **Acessibilidade (A11Y)**: Áreas de toque (targets) ≥ 48dp, `Semantics` no avatar.
- **Privacidade (LGPD)**: Consentimento explícito (Opt-in), revogável, e processamento de imagem (remoção de metadados).
- **Arquitetura**: `UI → Service → Storage` (Abstração). `get_it` usado para Injeção de Dependência.
- **Testabilidade**: `PrefsService` foi abstraído (Interface) para permitir Mocks/Fakes nos testes.

---

## 💾 Estrutura de Dados (PrefsService)

| Chave (SharedPreferences) | Tipo | Descrição |
|--------|------|-----------|
| `onboarding_complete` | bool | Utilizador já viu o onboarding. |
| `policy_accepted_version`| string | Versão da política que o utilizador aceitou (ex: "1.0"). |
| `avatar_path` | string | Caminho absoluto (local) para o ficheiro `avatar.jpg` processado. |

**Serviço:** `PrefsService` (Interface) / `PrefsServiceImpl` (Implementação)
*Métodos principais:*
`isOnboardingComplete()`, `setOnboardingComplete()`, `getPolicyAcceptedVersion()`, `setPolicyAccepted(String v)`, `revokePolicy()`, `getAvatarPath()`, `setAvatarPath(String path)`.

---

## 🗺️ Rotas Principais (Rotas Nomeadas)

| Rota | Tela |
|------|------|
| `/` | `SplashScreen` |
| `/onboarding` | `OnboardingScreen` |
| `/consent` | `ConsentScreen` |
| `/home` | `HomeScreen` |

---

## 🧪 Testes e Validação (Fase 2)

| Tipo | Descrição | Resultado |
|------|-------------|-----------|
| **Unitário** | `PrefsServiceImpl` | Testou `setAvatarPath`, `getAvatarPath` e `revokePolicy` (limpando o avatar) usando `SharedPreferences.setMockInitialValues`. | **PASSOU** |
| **Widget** | `HomeScreen` (Fallback) | Testou se, ao iniciar, o `FakePrefsService` (com `null`) fazia o `Drawer` renderizar o *fallback* `Text('GU')`. | **PASSOU** |
| **Widget** | `HomeScreen` (Clique) | Testou se o toque (`tap`) no `Semantics` ('Avatar do usuário') abria o `showModalBottomSheet` com as opções "Tirar Foto" e "Escolher da Galeria". | **PASSOU** |
| **Manual** | Fluxo LGPD | Testado: Processamento (remoção de EXIF) e salvamento (app interno). | **PASSOU** |
| **Manual** | Persistência | Testado: Fechar e reabrir o app manteve o avatar. | **PASSOU** |
| **Manual** | Revogação | Testado: Revogar consentimento limpou o avatar e retornou ao *fallback* "GU". | **PASSOU** |

---

## ⚠️ Riscos e Decisões (Fase 2)

- **Decisão:** Abandonar o `Mockito` nos testes de widget.
- **Risco:** A IA falhou 3x em gerar testes com `mockito` (sintaxe v4, erros de `getIt`).
- **Mitigação:** A IA sugeriu usar uma classe "Fake" (`FakePrefsService`) em vez de um "Mock". Esta abordagem foi mais simples, robusta e resolveu 100% dos erros de teste.

- **Decisão:** Foco em Privacidade (LGPD) no processamento de imagem.
- **Risco:** Salvar fotos do utilizador com metadados (GPS) ou na galeria pública.
- **Mitigação:** Usada a biblioteca `image` para decodificar/re-codificar (removendo EXIF) e `path_provider` para salvar numa pasta interna e segura.

---

## 🚀 Entregáveis (Fase 2)

1. Implementação completa da funcionalidade de Avatar (PRs 1-5).
2. Código-fonte com arquitetura `UI → Service → Storage`.
3. Testes unitários e de widget (passando `flutter test`).
4. Relatório Reflexivo de IA (documentando o processo).
5. Vídeo de demonstração do fluxo completo (Fase 1 e 2).

## 3. Vídeo de Demonstração (Fase 1 & 2)

[COLE_O_SEU_LINK_DO_YOUTUBE_OU_GOOGLE_DRIVE_AQUI]

---

## 🧱 Tecnologias (Fase 1 e 2)

- **Flutter** (Material 3)
- `get_it` (Injeção de Dependência)
- `shared_preferences` (Persistência)
- `flutter_markdown` (Policy Viewer)
- `smooth_page_indicator` (Onboarding Dots)
- `image_picker` (Câmera/Galeria)
- `permission_handler` (Gestão de Permissões)
- `image` (Processamento/Compressão/Remoção de EXIF)
- `path_provider` (Armazenamento local seguro)
- `flutter_test` / `mockito` (Testes)

---

## 📈 Backlog Futuro (Próximas Fases)

- Implementar o `TODO: Implementar "Adicionar Planta"`.
- Implementar o `TODO: Puxar nome do usuário` (atualmente "Guilherme da Silva" está *hardcoded*).
- Implementar Lembretes (Notificações).
- Implementar o ícone do app com `flutter_launcher_icons`.

---

## 👤 Autor

**Guilherme da Silva**
Disciplina: *Desenvolvimento Móvel (DM)*
Instituição: UTFPR
Versão: **v2.0 — Outubro/2025**

---