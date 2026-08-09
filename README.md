# 🚀 Flutter AI Tutor — Flutter Foundation Roadmap App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-blueviolet?style=for-the-badge)
![State Management](https://img.shields.io/badge/State%20Management-BLoC%2FCubit-02569B?style=for-the-badge)
![AI Engine](https://img.shields.io/badge/AI%20Engine-Gemini%20%7C%20OpenAI%20%7C%20Claude-7531FF?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A production-grade, interactive mobile application designed to guide developers from beginner fundamentals to production-ready Flutter mastery. Built with modern Flutter & Dart engineering practices, **Flutter AI Tutor** combines structured day-by-day learning, offline progress tracking, real-time debounced global search, and an intelligent **Bring Your Own Key (BYOK)** multi-model AI tutor.

> [!IMPORTANT]
> ### 📱 Device & Platform Compatibility
> - **Platform Tested**: Currently, this application has only been rigorously tested on Android physical devices. While the codebase is cross-platform (iOS compatible), iOS-specific testing and native channel verification are pending.
> - **UI Optimization**: The user interface is strictly optimized for mobile phone form factors. Tablets, iPads, and desktop window sizes are not currently supported and may exhibit layout overflow or improper scaling.

---

## 📱 App Preview

| Phases & Global Search | Module Navigation | Day-Wise Lessons | Contextual AI Tutor | BYOK Settings & Security |
| :---: | :---: | :---: | :---: | :---: |
| *Curriculum & Search* | *Linear Progress* | *Markdown & Code* | *Keyboard-Adaptive Chat* | *Masked Key & NoScreenshot* |

---

## 🌟 Key Features

### 📚 1. Structured 3-Tier Learning Roadmap
- **Phases → Modules → Days**: Progress linearly through carefully crafted phases covering Dart, Flutter Framework, State Management, Networking, Storage, Architecture, and Production Deployment.
- **Automated Linear Unlock System**: Days and modules unlock automatically as you complete preceding lessons, encouraging disciplined learning.

### 📖 2. Interactive Day-Wise Lesson Engine
- **Rich Markdown Reader**: Clear explanations with customized typography (Hanken Grotesk, Inter).
- **Dark-Theme Syntax Highlighted Code Blocks**: Embedded code snippets using `JetBrains Mono` for developer-centric legibility.
- **Expandable Deep Dives**: Accordions for Architecture, Code Instruction, Comparisons, Performance Optimization, Common Mistakes, and Interview Questions.

### 🔍 3. Debounced Global Search Engine
- **Instant Search**: Search across the entire curriculum by lesson `title` or `description` from the main screen.
- **500ms Input Debouncing**: Smooth UI responsiveness without lag or unnecessary calculations while typing.
- **Direct Deep-Linking**: Tapping search results uses `context.pushNamed(...)` to navigate directly to the lesson while keeping search context intact upon returning.

### 🤖 4. Multi-Model BYOK AI Tutor
- **Multi-Provider Support**: Choose between **Google Gemini (Gemini 2.5 Flash)**, **OpenAI (ChatGPT)**, and **Anthropic (Claude 3.5 Sonnet)**.
- **Bring Your Own Key (BYOK)**: Secure, client-side API key entry with real-time live verification endpoints before saving.
- **Encrypted Storage & Masked Display**: Keys are stored in platform Keychain/Keystore (`flutter_secure_storage`). Saved keys display masked as `AIza••••••••0XYZ` with verified badges, and Save/Remove buttons dynamically toggle based on key state.
- **Screen Protection**: Integrates `no_screenshot` package to block screen recording and screenshot capture on the AI Settings screen.
- **Persisted Model Selection**: Seamlessly switch active AI models with automatic local persistence (`shared_preferences`).

### 💡 5. Context-Aware AI Assistance & Keyboard Inset Adaptive Sheet
- **Dynamic Context Injection**: The floating AI Tutor FAB dynamically inspects the current screen or active learning card to greet you with relevant context.
- **Keyboard-Adaptive Bottom Sheet**: Animated padding handles soft keyboard insets (`viewInsets.bottom`), resizing the sheet so chat history and text input remain 100% visible.
- **Interactive Suggestion Bubbles**: Contextual suggestion chips rendered directly inside the AI bottom sheet to spark immediate learning questions.

### 🎨 6. Superior UX & Lumina Code Design System
- **Sticky Completion Bar**: Bottom action bar remains docked at the screen footer so lessons can be completed instantly regardless of scroll length.
- **Scroll-to-Top FAB**: Animated floating action button appears automatically when scrolling past 400px to smoothly return to the top.

---

## 🛠️ Technology Stack

| Category | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x / Dart 3.x | Core Application SDK |
| **Architecture** | Clean Architecture (Feature-First) | Maintainable, testable, and scalable layer separation |
| **State Management** | `flutter_bloc` / `cubit` | Predictable, event-driven state management |
| **Local Database** | `hive` / `hive_flutter` | Fast, encrypted NoSQL offline progress persistence |
| **Navigation & Pop** | `go_router` + `PopScope` | Declarative URL routing, deep-linking & double-back exit handling |
| **Networking** | `dio` | HTTP client for OpenAI & Anthropic Claude REST endpoints |
| **AI SDK** | `google_generative_ai` | Official SDK for Google Gemini AI integration |
| **Secure Storage** | `flutter_secure_storage` | Platform Keychain / Keystore encryption for API keys |
| **Screen Security** | `no_screenshot` | Screenshot & screen recording protection for security screens |
| **Preferences** | `shared_preferences` | Persistence for user settings (e.g., active AI model) |
| **DI Engine** | `get_it` + `injectable` | Service locator with automated code generation |
| **Typography** | `google_fonts` | Hanken Grotesk, Inter, JetBrains Mono |

---

## 🏗️ Architecture & Directory Structure

The project follows **Clean Architecture** with a **Feature-First** directory layout:

```
lib/
├── core/                         # Core infrastructure & shared utilities
│   ├── constants/                # AssetConstants, StringConstants
│   ├── di/                       # Injection setup (get_it + injectable)
│   ├── errors/                   # Custom Exception & Error mappings
│   ├── router/                   # GoRouter configuration
│   └── theme/                    # Lumina Code theme tokens & typography
│
├── data/                         # Data layer (Implementations)
│   ├── local/                    # Hive storage boxes, type IDs & security storage
│   └── remote/                   # Gemini, OpenAI, and Anthropic API data sources
│
├── domain/                       # Domain layer (Contracts & Models)
│   ├── models/                   # Phase, Module, LessonDay, LessonContent
│   └── repositories/             # AI Tutor & Curriculum Repository interfaces
│
├── features/                     # Feature modules (UI + BLoCs)
│   ├── ai_tutor/                 # AI Assistant BLoC, Settings Cubit, BottomSheet, FAB
│   ├── curriculum/               # Phases, Modules, and Days screens & nodes
│   └── lesson/                   # Lesson details screen, BLoC, and markdown builder
│
└── shared/                       # Shared reusable UI widgets
    ├── code_block_widget.dart    # Syntax-highlighted code container
    ├── expandable_widget.dart    # Custom accordion container
    └── custom_button.dart        # Reusable buttons & inputs
```

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

The app is **100% Client-Side BYOK (Bring Your Own Key)**. No backend server or secret proxy is required!

1. Launch the app and open the **AI Assistant Settings** (tap the settings gear inside the AI Tutor sheet or FAB menu).
2. Choose your preferred AI provider:
   - **Google Gemini** (Get key from [Google AI Studio](https://aistudio.google.com/))
   - **OpenAI ChatGPT** (Get key from [OpenAI Platform](https://platform.openai.com/))
   - **Anthropic Claude** (Get key from [Anthropic Console](https://console.anthropic.com/))
3. Enter your API key and tap **Save key**.
4. The app verifies the key live against the provider's API endpoint. Upon successful verification:
   - The key is saved securely in your platform Keychain/Keystore.
   - The input field switches to a **Masked Key Display** (`AIza••••••••0XYZ`) with a verified badge.
   - The **Remove** button appears for key management.
   - Screenshots and recordings are automatically blocked on the settings screen via `no_screenshot`.

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

### Web
```bash
flutter build web --release
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

This repository is provided for portfolio and evaluation purposes only.

Commercial use, redistribution, modification, or reproduction without written permission is prohibited.

Developed with ❤️ by **Arpit Aswal**.
