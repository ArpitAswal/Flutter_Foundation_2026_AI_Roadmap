# Architecture Documentation

## 1. Architectural Pattern: Clean Architecture + Feature-First

The application strictly implements **Clean Architecture** organized with a **Feature-First** structure. This guarantees complete separation of business logic from UI rendering, high unit testability, and clear code ownership.

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

---

## 2. Layer Breakdown & Responsibilities

### Presentation Layer (`lib/features/`, `lib/shared/`)
- **Screens & Widgets**: Purely declarative UI components (`PhasesScreen`, `ModulesScreen`, `DaysScreen`, `LessonScreen`, `AiAssistantSettingsScreen`, `AiTutorBottomSheet`).
- **State Management**:
  - `CurriculumBloc`: Manages phase, module, and day hierarchy and calculates unlock states.
  - `LessonBloc`: Manages day content loading, theory markdown rendering, and completion toggles.
  - `AiTutorBloc`: App-lifecycle `@LazySingleton` managing chat turns, throttled streaming, suggestions, and stream controls.
  - `AiAssistantSettingsCubit`: Manages BYOK model preference, live key validation, and masked key state.
- **Rule**: Widgets never execute business logic, HTTP calls, or database operations directly. All events are dispatched through BLoCs/Cubits.

### Domain Layer (`lib/domain/`)
- **Entities & Models**: Pure Dart immutable models (`Phase`, `LessonModule`, `LessonDay`, `LessonContent`, `AiModel`, `ChatTurn`, `KeyValidationResult`).
- **Services & Policies**:
  - `CurriculumCacheService`: Parses the `curriculum_index.json` once into a token-efficient roadmap skeleton cache for AI context injection (saves ~30KB JSON decoding per turn).
  - `QuestionScopePolicy`: Deterministic classifier determining if queries are within the Flutter/Dart learning scope before reaching any provider.
  - `ConversationContextBuilder`: Bounded windowing service constructing structured message history within turn and token limits.
- **Use Cases**: Encapsulate distinct business actions (`AskAiTutorUseCase`, `GetPhasesUseCase`, `GetDayContentUseCase`, `MarkLessonCompleteUseCase`).
- **Repository Contracts**: Abstract interfaces (`CurriculumRepository`, `AiTutorRepository`).
- **Rule**: The domain layer has zero dependencies on Flutter framework UI or external third-party SDKs.

### Data Layer (`lib/data/`)
- **Local Data Sources**:
  - `HiveCurriculumDataSource`: Fast NoSQL persistence for curriculum and user progress (`UserProgressRecord`).
  - `AiAssistantSettingsLocalDataSource`: Platform encrypted storage (`flutter_secure_storage`) for API keys and `shared_preferences` for model selection.
- **Remote Data Sources**:
  - `GeminiRemoteDataSourceImpl`: Communicates with Google Generative AI for `gemini-3.5-flash`.
  - `OpenAiRemoteDataSourceImpl`: HTTP REST client via `Dio` for `gpt-5-mini`.
  - `AnthropicRemoteDataSourceImpl`: HTTP REST client via `Dio` for `claude-3-5-haiku-20241022`.
- **Factory**: `AiDataSourceFactory` routes requests dynamically to the appropriate data source based on user model selection.

### Core Infrastructure (`lib/core/`)
- `constants/`: Global string constants (`StringConstants`), asset paths (`AssetConstants`), app keys (`AppConstants`).
- `di/`: Centralized dependency injection using `get_it` and `injectable`.
- `router/`: Declarative URL-based routing with `go_router` and root `PopScope` exit handling.
- `theme/`: Lumina Code design tokens, color schemes, and Google Fonts typography.
- `utils/`: `ResponsiveExtension` (breakpoint helpers), `AiContextBuilder` (curriculum context budgeting).

---

## 3. AI Tutor Subsystem Architecture

```
User Input ──▶ QuestionScopePolicy ───▶ [Refused / Clarification] ──▶ Local UI Response
                      │
                   Allowed
                      ▼
            ConversationContextBuilder (Bounded Window: max 6 turns / 4k chars)
                      │
                      ▼
              AiContextBuilder (Appends CurriculumCacheService Skeleton + Active/Historical Context)
                      │
                      ▼
            AiDataSourceFactory ──▶ [Gemini / OpenAI / Anthropic]
                      │
                      ▼
         Streamed Chunks ──▶ AiTutorBloc (80ms Throttle) ──▶ AiTutorBottomSheet
```

### Deterministic Scope Policy (`QuestionScopePolicy`)
- Evaluates user messages locally using deterministic keyword and structure analysis with zero regex backtracking hazards.
- Classification outcomes:
  - `allowed`: Standard Flutter/Dart curriculum queries.
  - `allowedComparison`: Explicit comparison between Flutter and native platforms (e.g. Flutter vs Kotlin, Flutter vs Swift).
  - `clarificationNeeded`: Ambiguous or under-specified queries (e.g. "it crashed", "help me").
  - `refused`: Standalone native platform tutorials (e.g. "teach me Kotlin from scratch", "how to write Swift UI without Flutter") and off-topic queries.
- Refused queries receive an immediate local refusal message without calling provider APIs or consuming tokens.

### Conversation Continuity & Bounded Windowing
- `AiTutorBloc` is registered as an app-lifecycle `@LazySingleton`, preserving chat history across screen navigations in the current session without database persistence.
- `ConversationContextBuilder` enforces hard limits:
  - Maximum of 6 recent turns.
  - 4,000 character token safety budget.
  - Error messages and empty turns are automatically pruned.
  - Provider payloads are formatted in native provider structures (`contents` for Gemini, `messages` for OpenAI and Anthropic).

### Throttling & Streaming Performance
- First token chunk emits immediately to ensure zero perceived latency.
- Subsequent chunk emissions are throttled to 80ms intervals, preventing frame drops during high-frequency token generation.
- Interactive user controls: **Stop** (aborts in-flight request), **Retry** (re-runs last query), and **New Chat** (resets session and refreshes context chips).

---

## 4. Responsive & Adaptive Architecture

The application implements a custom responsive extension (`ResponsiveExtension` on `BuildContext`) supporting phones and tablets in all orientations:

```dart
extension ResponsiveExtension on BuildContext {
  bool get isTablet => screenWidth >= 600;
  bool get isSmallPhone => screenWidth <= 360;
  bool get isNormalPhone => !isSmallPhone && !isTablet;
  bool get isWideTablet => screenWidth >= 1024;
  Orientation get orientation => MediaQuery.of(this).orientation;
}
```

### Responsive Capabilities
1. **Typography (`responsiveTextTheme`)**: Dynamically scales `fontSize` and `letterSpacing` across small phones, normal phones, tablets, and wide iPads.
2. **Padding & Spacing (`responsivePadding`, `responsiveHeightSpace`)**: Scales margins and padding based on screen width/height to prevent excessive whitespace on tablets or clipping on small devices.
3. **Corner Radius (`responsiveCircularRadius`)**: Adapts container radiuses proportionally (12px on small, 16px on normal, 24px on tablet, 36px on wide iPad).
4. **Adaptive Grid Count**:
   - Mobile Portrait: 1 cross-axis column.
   - Tablet & Landscape: 2 cross-axis columns with balanced aspect ratios.
5. **Modal Bottom Sheet Constraints**:
   - In Tablet Landscape: Constrained to `maxWidth: context.screenWidth * 0.75` for readable, centered presentation.
6. **Dynamic FAB Sizing**:
   - Tablet: `(context.screenHeight * 0.1).clamp(60.0, 120.0)`
   - Phone: `(context.screenWidth * 0.12).clamp(40.0, 60.0)`

---

## 5. Security & Privacy Architecture

1. **Hardware-Backed Encryption**: API keys are written directly to platform Keychain (iOS) and KeyStore (Android) using `flutter_secure_storage`.
2. **Zero Plaintext Secret Exposure**: `AiAssistantSettingsState` never stores or exposes raw API keys. State holds only key availability flags and non-reversible masked representations (`AIza••••••••0XYZ`).
3. **Screen Capture Protection**: `NoScreenshot.instance.screenshotOff()` prevents screenshots and screen recordings on security-sensitive screens.
4. **Typed Key Validation**: Key validation returns `KeyValidationResult` (`valid`, `invalidKey`, `quotaExceeded`, `networkError`, `unknownError`), providing accurate user feedback without confusing rate limits with invalid keys.
