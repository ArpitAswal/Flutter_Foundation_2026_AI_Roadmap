# Skills & Technology Stack

Version: 1.3

---

## 1. Purpose

This document defines the confirmed technologies, packages, architectural patterns, and engineering knowledge required to build, test, and maintain the Flutter AI Tutor application.

---

## 2. Core Languages & Frameworks

### Dart (Latest Stable)
- Syntax, Null Safety, Sound Type System
- Records and Pattern Matching
- Sealed Classes & Exhaustive Pattern Matching (BLoC events, states, Failures)
- Asynchronous Programming (Futures, Streams, AsyncGenerators `async*`)
- Extension Methods (`ResponsiveExtension`)
- Mixins and Equatable Value Equality

### Flutter Framework
- Material Design 3 (M3) Theming & ColorSchemes
- Custom Responsive Extension (`ResponsiveExtension`)
- Adaptive Layouts across Phones, Tablets, and iPads in Portrait and Landscape
- Declarative Navigation (`go_router`) & System Gestures (`PopScope`)
- Keyboard Inset Animation & Adaptive Modals (`viewInsets.bottom`)
- Rich Markdown Rendering (`flutter_markdown_plus`)
- Spinners and Indicators (`flutter_spinkit`)

---

## 3. Production App Stack

### State Management
- **flutter_bloc** (Bloc / Cubit)
- `CurriculumBloc`: Global phase/module/day roadmap state and linear unlocks.
- `LessonBloc`: Lesson markdown content, code blocks, and completion tracking.
- `AiTutorBloc`: App-lifecycle `@LazySingleton` handling multi-turn conversation, 80ms throttled streaming, suggestions, and stream controls.
- `AiAssistantSettingsCubit`: Client-side BYOK configuration, model selection, live key verification, and masked key state.

### Local Database & Storage
- **Hive** (`hive_flutter`, `hive_generator`):
  - Fast, lightweight NoSQL key-value database for curriculum progress records (`UserProgressRecord`).
  - Strict typeId registry maintained in `lib/data/local/hive_type_ids.dart`.
- **shared_preferences**:
  - Persists non-sensitive user settings, such as active AI model selection.

### Security & Cryptography
- **flutter_secure_storage**:
  - Hardware-backed encrypted storage (iOS Keychain and Android KeyStore) for user API keys.
- **no_screenshot**:
  - Prevents screenshot capture and screen recording on sensitive security screens (`AiAssistantSettingsScreen`).
- **Key Masking**:
  - Formats stored API keys as `AIza••••••••0XYZ`.

### Networking & AI Integration
- **Google Generative AI** (`google_generative_ai`):
  - Google Gemini integration running `gemini-3.5-flash`.
- **Dio** (`dio`):
  - HTTP client for OpenAI (`gpt-5-mini`) and Anthropic Claude (`claude-3-5-haiku-20241022`) REST API endpoints.
- **QuestionScopePolicy**:
  - Pure Dart deterministic scope classifier rejecting off-topic/standalone native tutorials with 0 token consumption.
- **ConversationContextBuilder**:
  - Bounded windowing formatter enforcing 6-turn / 4,000-character safety budgets.

### Dependency Injection
- **get_it** + **injectable** (`injectable_generator`):
  - Automated compile-time service locator configuration.

### Responsive Design Engine
- **ResponsiveExtension**:
  - Custom responsive system classifying `isSmallPhone`, `isNormalPhone`, `isTablet`, `isWideTablet`, and `orientation`.
  - Scaled typography, dynamic padding, height spaces, corner radiuses, and grid cross-axis counts.

---

## 4. Testing & Quality Assurance

- **Unit Testing** (`flutter_test`): Domain models, services (`QuestionScopePolicy`, `ConversationContextBuilder`, `AiContextBuilder`), BLoCs, and repositories.
- **Widget Testing**: Interactive UI rendering, component scaling, responsive behavior, and action dispatching.
- **Static Analysis**: `dart analyze lib test` enforcing zero warnings or errors.
