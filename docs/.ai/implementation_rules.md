# Implementation Rules

Version: 1.3

---

## 1. Objective

This document defines the strict engineering standards that must be adhered to throughout the codebase. The purpose is to guarantee architectural consistency, maintainability, scalability, and code quality.

---

## 2. Core Engineering Standards

### A. Centralized Constant Strings (`StringConstants`)
- **Rule**: All user-facing text, button labels, error descriptions, prompt hints, refusal messages, and fallback texts MUST be declared in `lib/core/constants/string_constants.dart`.
- **Prohibited**: Hardcoded raw string literals inside widgets, BLoCs, Cubits, repositories, or data sources are strictly forbidden.

### B. Single Responsibility & Clean Architecture
- Every file must have a single, clearly defined responsibility.
- No business logic, networking, or database calls inside UI build methods.
- Presentation code must communicate with domain/data layers exclusively through BLoCs and Cubits.

---

## 3. Responsive Design Rules (Tablet & iPad Optimization)

- **Rule**: All UI sizing, spacing, typography, and layout adaptations MUST use `ResponsiveExtension` (`lib/core/utils/responsive_extension.dart`).
- **Responsive Guidelines**:
  1. **Typography**: Use `context.responsiveTextTheme` rather than fixed font sizes.
  2. **Padding & Spacing**: Use `context.responsivePadding(x, y)` and `context.responsiveHeightSpace(h)` to automatically scale between small phones, normal phones, tablets, and wide iPads.
  3. **Border Radius**: Use `context.responsiveCircularRadius` for card and container corners.
  4. **Orientation & Grids**: Grid layouts must evaluate `context.isTablet` and `context.orientation` to supply appropriate `crossAxisCount` (e.g., 2 columns in landscape/tablet, 1 column in mobile portrait).
  5. **Dialog & Sheet Constraints**: Always apply constraints on modal surfaces in landscape tablet mode (`maxWidth: context.screenWidth * 0.75`) to avoid unreadable, stretched layouts.
  6. **FAB Scaling**: Compute FAB dimensions dynamically via screen dimensions with safe clamp limits.

---

## 4. Security & Privacy Standards

- **Secure Key Storage**: All user API keys must be written to encrypted platform storage via `flutter_secure_storage` (backed by iOS Keychain and Android KeyStore).
- **Zero Plaintext Secrets in State**: `AiAssistantSettingsState` and all BLoC states must NEVER store or emit raw API keys. State holds only key availability flags and non-reversible masked strings (`AIza••••••••0XYZ`).
- **Screen Protection**: All security-sensitive screens (`AiAssistantSettingsScreen`) must activate screen recording and screenshot blocking via `NoScreenshot.instance.screenshotOff()`.
- **Typed Validation Results**: Key validation must return typed enum results (`KeyValidationResult`) to differentiate unauthorized keys from network failures or billing quota limits.

---

## 5. AI Tutor & BLoC Implementation Standards

- **Deterministic Scope Evaluation**: User inputs must be evaluated by `QuestionScopePolicy` before calling any external provider. Off-topic and standalone native tutorial questions must receive immediate local refusal without token consumption.
- **App-Lifecycle In-Memory Continuity**: `AiTutorBloc` must remain an `@LazySingleton` preserving active conversations during the app session without database persistence.
- **Bounded Conversation Context**: Always format history through `ConversationContextBuilder` with hard limits (max 6 turns / 4,000 character budget) and error pruning.
- **Throttled Stream Emissions**: Streamed responses must emit the first chunk immediately for zero perceived latency, followed by 80ms chunk intervals to maintain smooth 60fps UI rendering.
- **Stream Controls**: Always support in-flight stream cancellation (`AiTutorStopRequested`), error retry (`AiTutorRetryRequested`), and session reset (`AiTutorNewChatRequested`).

---

## 6. Navigation, Deep Linking & Pop Handling

- **Declarative Routes**: All routes must be registered declaratively in `AppRouter` (`go_router`).
- **Hierarchy Navigation**: Use `context.goNamed(...)` for standard linear curriculum progression (Phases → Modules → Days).
- **Stack-Preserving Navigation**: Use `context.pushNamed(...)` for search result navigation or overlay transitions so pressing back returns to the previous state.
- **Double-Back Exit**: Root screen (`PhasesScreen`) must implement `PopScope(canPop: false)` requiring a double-back tap within 2 seconds with SnackBar feedback.

---

## 7. Performance & Debouncing

- **Search Debouncing**: Real-time text search inputs must implement a 500ms `Timer` debounce to prevent excessive calculations during typing.
- **Widget Const Constructors**: Use `const` constructors wherever possible to maximize element reuse and prevent unnecessary rebuilds.
- **Lazy List Rendering**: Use `ListView.builder` / `GridView.builder` with caching extents for performant list rendering.