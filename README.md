# 🚀 Flutter AI Tutor — Flutter Foundation Roadmap App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-blueviolet?style=for-the-badge)
![State Management](https://img.shields.io/badge/State%20Management-BLoC%2FCubit-02569B?style=for-the-badge)
![AI Engine](https://img.shields.io/badge/AI%20Engine-Gemini%203.5%20%7C%20GPT--5%20Mini%20%7C%20Claude%203.5-7531FF?style=for-the-badge)
![Device Support](https://img.shields.io/badge/Form%20Factor-Phone%20%26%20Tablet%20%2F%20iPad-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A production-grade, interactive mobile application designed to guide developers from beginner fundamentals to production-ready Flutter mastery. Built with modern Flutter & Dart engineering practices, **Flutter AI Tutor** combines structured day-by-day learning, offline progress tracking, real-time debounced global search, tablet/iPad responsive optimization, and an intelligent **Bring Your Own Key (BYOK)** multi-model AI tutor.

> [!TIP]
> ### 📱 Multi-Device & Responsive Support
> - **Cross-Platform**: Fully supported and tested on physical devices and simulators/emulators for **Android** and **iOS**.
> - **Tablet & iPad Optimized**: The application features a custom responsive engine (`ResponsiveExtension`) that dynamically adapts typography, padding, grid layouts (2-column grids on tablets/landscape), modal constraints, and touch targets across **phones, tablets, and wide iPads** in both **Portrait and Landscape** modes.

---

## 📱 App Preview

| Phases & Global Search | Module Navigation | Day-Wise Lessons |

<img width="250" alt="Phases Screen" src="https://github.com/user-attachments/assets/c814bd03-565f-46d2-9926-ecbc35400fba" />
<img width="250" alt="Modules Screen" src="https://github.com/user-attachments/assets/999c119a-94b4-417f-8203-cd100171ce3b" />
<img width="250" alt="Days Screen" src="https://github.com/user-attachments/assets/e74c9748-e334-4c57-912a-62b7fe6468f5" />

| Lesson Content | BYOK Settings & Security |

<img width="250" alt="Learning Screen" src="https://github.com/user-attachments/assets/7260b06a-9b43-4555-9f90-6d101b9b2089" />
<img width="250" alt="BYOK Screen" src="https://github.com/user-attachments/assets/95bfee4f-cc8b-48a4-8a39-ab295c66e354" />

---

## 🌟 Key Features

### 📚 1. Structured 3-Tier Learning Roadmap
- **Phases → Modules → Days**: Progress linearly through carefully crafted phases. 
- **Currently Available Content (v1.0.0 Release)**:
  - ✅ **Phase 1: Dart Programming Foundation** (Syntax, OOP, Mixins, Async)
  - ✅ **Phase 2: Flutter Fundamentals** (Widgets, State, Architecture, Navigation)
  - ✅ **Phase 3: State Management & Architecture** (Built-in Primitives, Provider, Riverpod, GetX, BLoC/Cubit)
  - *More advanced topics (Networking, Storage, Animations, Firebase) are currently in active development and will be released in future updates.*
- **Automated Linear Unlock System**: Days and modules unlock automatically as you complete preceding lessons, encouraging disciplined learning.
- **Offline Persistence**: Lesson completion records (`UserProgressRecord`) are stored locally in Hive NoSQL database.

### 📱 2. Full Tablet & iPad Responsive Optimization
- **Dynamic Breakpoints**: Smoothly adapts across Small Phones ($\le 360$px), Normal Phones ($360$px - $600$px), Tablets ($\ge 600$px), and Wide Tablets/iPads ($\ge 1024$px).
- **Orientation-Aware Grids**: Automatically displays 1 column on mobile portrait and 2 columns on tablets or landscape orientations for balanced, readable card layouts.
- **Adaptive Typography & Spacing**: Dynamic text scaling (`responsiveTextTheme`), proportional padding (`responsivePadding`), scalable height gaps (`responsiveHeightSpace`), and adaptive corner radiuses.
- **Constrained Landscape Modal**: In tablet landscape mode, the AI Tutor sheet is constrained to `maxWidth: screenWidth * 0.75`, ensuring readable line lengths.
- **Dynamic FAB Sizing**: The Floating Action Button scales smoothly based on screen dimensions (`clamp(60, 120)` on tablet, `clamp(40, 60)` on phone).

### 🤖 3. Multi-Model BYOK AI Assistant
- **Upgraded Provider Models**:
  - **Google Gemini**: `gemini-3.5-flash` (Speed & agentic-optimized model with low token overhead for longer query I/O).
  - **OpenAI**: `gpt-5-mini` (High-accuracy compact reasoning).
  - **Anthropic Claude**: `claude-3-5-haiku-20241022` (Upgraded from retired Claude 3 Haiku).
- **Deterministic Scope Policy (`QuestionScopePolicy`)**:
  - Pure Dart local classifier evaluated before any provider API call.
  - Returns immediate local refusal for off-topic questions or standalone native platform tutorials (e.g. "teach me Kotlin from scratch") with **zero token consumption**.
  - Direct Flutter vs. native comparisons (e.g. Flutter vs Kotlin, Flutter vs Swift) are permitted and framed around Flutter architecture.
- **App-Lifecycle In-Memory Conversation Continuity**:
  - Ephemeral chat state preserved across screens during the app session via an app-lifecycle `@LazySingleton` BLoC.
  - Bounded windowing (`ConversationContextBuilder`) with a 6-turn / 4,000-character safety budget.
- **Token-Efficient Context Injection (`CurriculumCacheService`)**:
  - Automatically parses the 35KB `curriculum_index.json` on app startup into a compact ~3KB textual roadmap skeleton.
  - Anchors the AI to the exact Phase, Module, and Day structure with near-zero latency and minimal token overhead, eliminating hallucinations.
- **Throttled Streaming & Interactive Controls**:
  - Immediate first-token emission followed by 80ms chunk throttling.
  - In-flight **Stop**, error **Retry**, and **New Chat** controls.
  - Dynamic **Contextual Starter Prompt Chips** tailored to the active screen or lesson.

### 🔒 4. Enterprise Secret Security & Privacy
- **Platform Encrypted Storage**: User API keys are stored in hardware-backed platform Keychain (iOS) and KeyStore (Android) using `flutter_secure_storage`.
- **Masked Key Display**: Raw API keys are never stored or exposed in BLoC/Cubit state or logs. Saved keys display masked as `AIza••••••••0XYZ` with verified badges.
- **Screen Protection (`no_screenshot`)**: Screenshots and screen recordings are automatically blocked on the AI Assistant Settings screen.
- **Typed Key Validation (`KeyValidationResult`)**: Validates keys against live endpoints, accurately distinguishing valid keys, invalid keys, billing quota limits, and network errors.

### 🔍 5. Debounced Real-Time Global Search
- **Instant Search**: Real-time filtering across all curriculum days by `title` or `description`.
- **500ms Input Debouncing**: Prevents UI stutter and excessive rebuilds during typing.
- **Stack-Preserving Deep-Linking**: Uses `context.pushNamed(...)` so returning from a lesson preserves the active search query and scroll position.

### 📖 6. Interactive Day-Wise Lesson Engine
- **Rich Markdown Reader**: Clear explanations with curated typography (`Hanken Grotesk`, `Inter`).
- **Syntax-Highlighted Code Blocks**: Embedded code snippets using `JetBrains Mono`.
- **Expandable Deep Dives**: Accordion sections for Architecture, Code Instruction, Comparisons, Performance Optimization, Common Mistakes, and Interview Prep.
- **Sticky Completion Bar**: Docked inside `Scaffold.bottomNavigationBar` for immediate completion toggles.
- **Scroll-to-Top FAB**: Automatically fades in when scrolling past 400px.
- **Double-Tap Back Exit (`PopScope`)**: Intercepts root back gestures with SnackBar feedback to prevent accidental app exits.

---

## 🛠️ Technology Stack

| Category | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart 3.x | Core Application SDK |
| **Architecture** | Clean Architecture (Feature-First) | Maintainable, testable layer separation |
| **State Management** | `flutter_bloc` / `cubit` | Predictable, event-driven state management |
| **Local Database** | `hive` / `hive_flutter` | Fast, offline NoSQL progress persistence |
| **Navigation & Pop** | `go_router` + `PopScope` | Declarative URL routing, deep linking & double-back exit |
| **AI Integration** | `google_generative_ai` + `dio` | Gemini 3.5 Flash, GPT-5 Mini, and Claude 3.5 Haiku |
| **Scope Evaluation** | `QuestionScopePolicy` | Deterministic local guardrail (0 token waste) |
| **Secure Storage** | `flutter_secure_storage` | Platform Keychain / Keystore encryption for API keys |
| **Screen Security** | `no_screenshot` | Screenshot & screen recording protection |
| **Preferences** | `shared_preferences` | Persistence for user model preference |
| **DI Engine** | `get_it` + `injectable` | Service locator with automated code generation |
| **Responsive Engine** | `ResponsiveExtension` | Phone, Tablet, and iPad adaptation in portrait/landscape |
| **Typography** | `google_fonts` | Hanken Grotesk, Inter, JetBrains Mono |

---

## 🏗️ Architecture & Directory Structure

The project follows **Clean Architecture** with a **Feature-First** directory layout:

```
lib/
├── core/                         # Core infrastructure & shared utilities
│   ├── constants/                # StringConstants, AssetConstants, AppConstants
│   ├── di/                       # Dependency injection (get_it + injectable)
│   ├── error/                    # Failure classes and exception handlers
│   ├── router/                   # GoRouter configuration & route names
│   ├── theme/                    # Lumina Code tokens & typography
│   └── utils/                    # ResponsiveExtension, AiContextBuilder
│
├── data/                         # Data layer (Implementations)
│   ├── local/                    # Hive storage boxes, TypeAdapters, secure storage
│   └── remote/                   # Gemini, OpenAI, and Anthropic data sources
│
├── domain/                       # Domain layer (Contracts & Pure Dart Models)
│   ├── models/                   # Phase, Module, LessonDay, LessonContent, AiModel
│   ├── repositories/             # AI Tutor & Curriculum Repository interfaces
│   ├── services/                 # QuestionScopePolicy, ConversationContextBuilder
│   └── usecases/                 # AskAiTutorUseCase, GetPhasesUseCase, etc.
│
├── features/                     # Feature modules (Presentation UI + BLoCs)
│   ├── ai_tutor/                 # AI Assistant BLoC, Settings Cubit, BottomSheet, FAB
│   ├── curriculum/               # Phases, Modules, and Days screens & nodes
│   └── lesson/                   # Lesson details screen, BLoC, and markdown reader
│
└── shared/                       # Shared reusable UI widgets
    ├── code_block_widget.dart    # Syntax-highlighted code block
    ├── expandable_widget.dart    # Custom accordion container
    └── custom_button.dart        # Reusable buttons & inputs
```

For detailed architectural documentation, see [`docs/.ai/architecture.md`](docs/.ai/architecture.md).

---

## ⚙️ Setup & Installation

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.19.0 or higher)
- [Dart SDK](https://dart.dev/get-setup) (v3.3.0 or higher)

### 1. Clone the Repository
```bash
git clone https://github.com/ArpitAswal/Flutter_Foundation_2026_AI_Roadmap.git
cd Flutter_Foundation_2026_AI_Roadmap
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Code Generation (Build Runner)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run the Application
```bash
flutter run
```

---

## 🔑 AI Assistant & BYOK Setup

The app is **100% Client-Side BYOK (Bring Your Own Key)**. No backend proxy or subscription is required:

1. Launch the app and open **AI Assistant Settings** (tap the settings gear icon inside the AI Tutor bottom sheet).
2. Choose your preferred AI model:
   - **Google Gemini**: `gemini-3.5-flash` (Get key from [Google AI Studio](https://aistudio.google.com/))
   - **OpenAI**: `gpt-5-mini` (Get key from [OpenAI Platform](https://platform.openai.com/))
   - **Anthropic Claude**: `claude-3-5-haiku-20241022` (Get key from [Anthropic Console](https://console.anthropic.com/))
3. Enter your personal API key and tap **Save key**.
4. The key is verified live against the provider endpoint:
   - **Success**: Encrypted in platform Keychain/KeyStore, displayed masked (`AIza••••••••0XYZ`) with a verified badge.
   - Screen recording and screenshots are automatically disabled on the settings screen.

---

## 🧪 Testing & Verification

Run the comprehensive unit, service, and widget test suite:
```bash
flutter test
```

Run static code analysis:
```bash
dart analyze lib test
```

---


## 📱 Building for Production

### Android
```bash
flutter build apk --release
# OR
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```
---

## 🤝 Contributing & Issue Tracking

We welcome bug reports and feature requests from both end-users and internal team members! Please use our GitHub repository's Issue Tracker to submit your feedback.

### 1. Issue Reporting (Bugs & Features)
- **GitHub Issues**: Please raise all issues directly in the repository's issue tracker.
- **Bug Reports**: Include your device model, OS version, steps to reproduce, and attach any relevant screenshots or screen recordings. Internal team members should also attach Firebase Crashlytics log IDs if applicable.
- **Feature Requests**: Outline the proposed feature, the target AI model (OpenAI, Gemini, Claude), and your use case.

### 2. Branching Strategy
Always branch off the `development` branch using descriptive naming conventions:
- `feature/your-feature-name` (e.g., `feature/claude-vision-support`)
- `fix/issue-description` (e.g., `fix/hive-pagination-crash`)
- `hotfix/critical-bug` (for production emergencies)

### 3. Creating a Pull Request (PR)
1. Ensure your local branch is up to date with `development`.
2. Run code formatting: `dart format lib/`
3. Run static analysis: `flutter analyze` *(Must pass with 0 issues)*.
4. Submit the PR and request review from at least one senior engineer or technical lead.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

This repository is provided for portfolio and evaluation purposes only. Commercial use, redistribution, modification, or reproduction without written permission is prohibited.

Developed with ❤️ by **Arpit Aswal**.
