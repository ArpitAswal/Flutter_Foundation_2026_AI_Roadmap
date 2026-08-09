# 🎙️ Flutter AI Tutor — Project Presentation & Architecture Guide

> **Purpose**: This document provides a complete engineering breakdown of the **Flutter AI Tutor** application. It is designed to serve as a comprehensive reference for presenting the project, conducting technical walkthroughs, or discussing architectural decisions during senior Flutter developer interviews.

---

# 📌 1. Executive Summary & Vision

### 💡 The Problem
Self-paced learning platforms for mobile software engineering often suffer from three major issues:
1. **Unstructured Information**: Beginners get lost navigating disorganised documentation or endless video playlists.
2. **Generic AI Assistance**: Traditional AI chatbots (like standard ChatGPT) lack context regarding the user's specific learning progress or what lesson they are currently studying.
3. **Privacy & API Costs**: Centralized backend services for AI tutors require expensive server infrastructure or user subscriptions.

### 🚀 The Solution
**Flutter AI Tutor** is a production-grade, offline-first mobile application that combines a **structured 3-tier curriculum roadmap** (Phases → Modules → Days) with a **client-side, multi-model AI assistant**. It features a **Bring Your Own Key (BYOK)** model supporting Google Gemini, OpenAI, and Anthropic Claude, complete with live key verification, platform encrypted key storage, screen screenshot protection (`no_screenshot`), real-time debounced search, keyboard-adaptive bottom sheet insets, double-tap back press to exit (`PopScope`), and context-aware lesson assistance.

---

# 🏗️ 2. High-Level Architecture & Layer Breakdown

The project strictly follows **Clean Architecture** combined with a **Feature-First** directory structure. This ensures strict separation of concerns, high testability, and clear ownership of business logic.

```
                    ┌─────────────────────────────────────────┐
                    │            PRESENTATION LAYER           │
                    │   (Screens, Widgets, BLoCs & Cubits)    │
                    └────────────────────┬────────────────────┘
                                         │
                                         ▼
                    ┌─────────────────────────────────────────┐
                    │               DOMAIN LAYER              │
                    │   (Entities, Use Cases, Repositories)   │
                    └────────────────────┬────────────────────┘
                                         │
                                         ▼
                    ┌─────────────────────────────────────────┐
                    │                DATA LAYER               │
                    │  (Hive Boxes, Remote APIs, SecureStore) │
                    └─────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. Presentation Layer (`lib/features/`, `lib/shared/`)
- Contains Flutter UI screens (`PhasesScreen`, `ModulesScreen`, `DaysScreen`, `LessonScreen`).
- Uses **BLoC / Cubit** for state management (`CurriculumBloc`, `LessonBloc`, `AiTutorBloc`, `AiAssistantSettingsCubit`).
- Widgets only describe UI and delegate actions to BLoCs. No business logic or networking code lives in build methods.

#### 2. Domain Layer (`lib/domain/`)
- Defines pure Dart entity models (`Phase`, `LessonModule`, `LessonDay`, `LessonContent`).
- Defines abstract repository interfaces (`CurriculumRepository`, `AiTutorRepository`).
- Has zero dependencies on Flutter framework or external third-party data drivers.

#### 3. Data Layer (`lib/data/`)
- Implements repository contracts defined in the Domain layer.
- **Local Data Sources**: Hive NoSQL database for progress tracking, `flutter_secure_storage` for encrypted API keys, `shared_preferences` for model settings.
- **Remote Data Sources**: `google_generative_ai` SDK for Gemini, `Dio` HTTP client for OpenAI (ChatGPT) and Anthropic (Claude) REST endpoints.

#### 4. Core Infrastructure (`lib/core/`)
- Centralized dependency injection (`get_it` + `injectable`).
- Declarative route registration (`go_router`) & root Pop handling (`PopScope`).
- Global String Constants management (`StringConstants`).
- Theme definitions and design tokens (`Lumina Code`).

---

# 🧩 3. Key Feature Deep-Dives

## 🟢 Feature 1: Dynamic Curriculum Engine, Progress Tracking & Double-Back Exit
- **Hierarchy**: `CurriculumIndex` (Phases) → `LessonModule` (Modules) → `LessonDay` (Days).
- **Offline Persistence**: User completion IDs (e.g. `'p1_m1_d1'`) are stored as a `Set<String>` in a Hive box.
- **Linear Unlock Algorithm**:
  ```dart
  // A phase/module/day is unlocked if index == 0 OR all preceding items are completed.
  bool isLocked = index > 0 && !completedIds.contains(previousLessonId);
  ```
- **Double-Tap Back Press to Exit (`PopScope`)**:
  ```dart
  PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      final now = DateTime.now();
      if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
        _lastBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(...);
      } else {
        SystemNavigator.pop();
      }
    },
  )
  ```
- **Scalability**: Adding 100 new days requires **zero UI code edits**.

---

## 🔵 Feature 2: Multi-Model BYOK AI Engine, Masked Display & Screen Security
- **Providers Supported**:
    1. **Google Gemini**: Gemini 2.5 Flash (via `google_generative_ai` SDK).
    2. **OpenAI**: GPT-4o / GPT-3.5-Turbo (via `Dio` REST API).
    3. **Anthropic**: Claude 3.5 Sonnet (via `Dio` REST API).
- **Live Key Verification Engine**: Sends a lightweight validation request before persisting keys to secure storage.
- **Masked Key Display & Conditional Actions**:
    - Saved keys display formatted as `AIza••••••••0XYZ` with verified badges.
    - Show/Hide Action Buttons: When saved, only **Remove** is shown (Save is hidden). When missing, only **Save key** is shown (Remove is hidden).
- **Screen Protection (`no_screenshot`)**:
  Blocks screenshots and screen recordings on the AI Assistant Settings screen (`NoScreenshot.instance.screenshotOff()`) to prevent sensitive key exposure.

---

## 🟣 Feature 3: Context-Aware AI Assistant & Keyboard Inset Adaptive Sheet
- **Context Inspection**: The floating `AiTutorFab` automatically inspects the currently active card on the screen (or current lesson content).
- **Dynamic Initial Greeting & Suggestion Chips**: Auto-generates context-specific greeting messages and clickable suggestion bubbles (`Wrap` of `OutlinedButton`).
- **Keyboard-Adaptive Bottom Sheet**:
  Uses `AnimatedPadding` driven by `MediaQuery.of(context).viewInsets.bottom` to smoothly resize the sheet container and scroll conversation history above the software keyboard when typing.

---

## 🟡 Feature 4: Debounced Real-Time Global Search Engine
- **Search Scope**: Real-time filtering across all curriculum days by `title` or `description`.
- **500ms Input Debouncing**: `Timer` debounce decouples high-frequency keyboard typing from heavy list filtering and UI reconstruction.
- **Navigation Behavior**: Uses `context.pushNamed(...)` so tapping search results preserves the search screen context when returning.

---

## 🔴 Feature 5: Lumina Code Design System & Reading UX
- **Design Aesthetic**: Minimalist with a Technical Edge (Slate neutrals, Flutter Blue `#005cad`, AI Purple `#7531ff`).
- **Sticky Completion Bar**: Docked inside `Scaffold.bottomNavigationBar` so users can complete lessons instantly without scrolling.
- **Scroll-to-Top FAB**: Uses a `ScrollController` listener; when scroll offset exceeds `400px`, an `AnimatedOpacity` button smoothly fades in to trigger `animateTo(0)`.

---

# ❓ 4. Technical Trade-Offs & Interview Q&A

### Q1: Why did you choose BLoC / Cubit over Riverpod or Provider?
> **Answer**: `flutter_bloc` provides a strict, predictable event-driven architecture that completely separates UI presentation from business logic. In a complex application with multiple asynchronous flows (like streaming AI responses, validating remote API keys, and reading Hive database state), BLoC's explicit `Event -> State` lifecycle ensures state transitions are easy to trace, test, and debug.

### Q2: How do you protect user API key security in settings?
> **Answer**: We combine hardware-backed Keychain (iOS) & KeyStore (Android) encryption (`flutter_secure_storage`) with client-side screen protection (`no_screenshot`) that blocks screenshots and screen capture. Saved keys display masked as `AIza••••••••0XYZ` to protect against visual eavesdropping.

### Q3: How do you handle bottom sheet layout when the software keyboard appears?
> **Answer**: We wrap the sheet container in `AnimatedPadding` bound to `MediaQuery.of(context).viewInsets.bottom` and dynamically adjust `maxHeight`. This ensures that when the keyboard opens, the chat list resizes smoothly and the input box stays anchored directly above the keyboard.

### Q4: Why use `PopScope` on the root screen?
> **Answer**: `PopScope` intercepts system back gestures on the root `PhasesScreen`, preventing accidental app termination. Requiring a second back-tap within 2 seconds (with SnackBar feedback) delivers a polished native Android navigation experience.

---

# 📊 5. Summary Matrix for Project Demo

| Feature | Primary Component / File | Key Engineering Benefit |
| :--- | :--- | :--- |
| **State Management** | `CurriculumBloc`, `AiTutorBloc` | Predictable, event-driven reactive state |
| **Local Database** | `HiveCurriculumDataSource` | Sub-millisecond offline data loading |
| **Secure Key Storage** | `FlutterSecureStorage` | Hardware-backed Keychain/KeyStore encryption |
| **Screen Security** | `no_screenshot` | Screenshot & screen recording blocking |
| **Pop Handling** | `PhasesScreen` (`PopScope`) | Double-back press exit protection |
| **Keyboard Inset Sheet** | `AiTutorBottomSheet` | Smooth adaptive bottom sheet resizing above soft keyboard |
| **Declarative Routing** | `AppRouter` (`go_router`) | Deep-linking & stack-preserving push navigation |
| **Global Search** | `PhasesScreen` (`_SearchResultsList`) | Real-time debounced filtering across all nested days |
| **Contextual AI** | `AiTutorFab`, `AiTutorBottomSheet` | Dynamic prompt engineering based on UI screen context |
| **Sticky UX** | `LessonScreen` | Persistent completion controls & auto-hiding scroll FAB |
