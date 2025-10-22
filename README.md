# Leafy 🌿

## 1. Objetivo do Projeto

**Leafy** é um aplicativo de cuidados com plantas desenvolvido como parte do projeto da disciplina de Desenvolvimento Móvel (DM).

O objetivo principal é ajudar usuários com rotinas corridas, como estudantes, a lembrar de regar e cuidar de suas plantas através de lembretes simples e checklists, garantindo uma interface acessível (A11Y) e respeito à privacidade (LGPD), com todos os dados salvos localmente.

## 2. Política de Branch

Este repositório segue uma política de Git Flow simplificada para garantir a estabilidade da branch `main`.

* **`main`**: Esta branch é protegida. Ela contém apenas o código de produção estável (releases). Nenhum *push* direto é permitido.
* **`dev`**: Branch principal de desenvolvimento. Todo o código novo é integrado aqui antes de ir para a `main`.
* **`feature/<nome-da-feature>`**: Todas as novas funcionalidades (ex: `feature/avatar`, `feature/onboarding`) devem ser criadas a partir da `dev`. Ao serem concluídas, elas são mescladas de volta na `dev` através de um Pull Request (PR).

**Fluxo:** `feature/*` -> `dev` -> `main`