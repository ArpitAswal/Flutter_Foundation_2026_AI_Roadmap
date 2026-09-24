# Flutter AI Tutor — Project Context

## 1. Vision & Executive Summary

**Flutter AI Tutor** is a production-grade, offline-first educational mobile application designed to guide developers from beginner fundamentals to production-ready Flutter and Dart mastery. Built using modern Flutter & Dart engineering practices, it combines a structured 3-tier curriculum roadmap with an intelligent, client-side **Bring Your Own Key (BYOK)** multi-model AI tutor.

Unlike generic chatbots or static tutorial playlists, Flutter AI Tutor pairs lesson theory, code instructions, comparisons, common mistakes, and interview preparation questions with context-aware AI coaching grounded directly in the user's active learning progress.

---

## 2. Mission & Target Audience

### Mission
Create an exceptionally high-quality Flutter learning platform where learners do not simply memorize syntax or copy-paste snippets, but deeply understand software engineering concepts through theory, experimentation, architectural comparisons, and guided AI dialogue.

### Target Audience
- **Beginners & Students**: Learning Dart and Flutter fundamentals from scratch.
- **Cross-Platform Developers**: Transitioning from native Android (Kotlin), iOS (Swift), React Native, or Web.
- **Intermediate & Senior Engineers**: Mastering clean architecture, advanced state management, offline caching, and security.
- **Interview Candidates**: Preparing for senior Flutter developer technical interviews.

---

## 3. Learning Philosophy

Learning must prioritize fundamental understanding before API mechanics. Every topic answers:
1. **What is it?** — Core concept definition.
2. **Why is it needed?** — Problem solved by this concept.
3. **When should it be used?** — Real-world production scenarios.
4. **When should it not be used?** — Anti-patterns and trade-offs.
5. **What are the alternatives?** — Technology comparisons (e.g., Hive vs Drift vs Isar).
6. **How is it implemented in production?** — Scalable, clean code patterns.

---

## 4. Comprehensive Feature Breakdown

### 📚 A. Structured 3-Tier Curriculum Roadmap
- **Hierarchy**: `CurriculumIndex` (Phases) → `LessonModule` (Modules) → `LessonDay` (Days).
- **Linear Unlock Algorithm**:
  ```dart
  // A phase, module, or day is unlocked if index == 0 OR all preceding items are completed.
  bool isLocked = index > 0 && !completedIds.contains(previousLessonId);
  ```
- **Offline Persistence**: Completed lesson IDs (e.g. `'p1_m1_d1'`) are persisted locally as a `Set<String>` in Hive NoSQL database.

### 📖 B. Interactive Day-Wise Lesson Engine
- **Rich Markdown Reader**: Clear explanations with curated typography (Hanken Grotesk, Inter).
- **Syntax-Highlighted Code Blocks**: Embedded code snippets using `JetBrains Mono` for developer-centric legibility.
- **Expandable Deep Dives**: Modular accordion sections for Architecture, Code Instruction, Comparisons, Performance Optimization, Common Mistakes, and Interview Prep.
- **Sticky Completion Bar**: Docked inside `Scaffold.bottomNavigationBar` so users can mark lessons complete without scrolling to the bottom.
- **Auto-Hiding Scroll-to-Top FAB**: Smoothly fades in via `AnimatedOpacity` once scroll offset exceeds 400px.

### 🔍 C. Debounced Real-Time Global Search
- **Instant Search**: Real-time filtering across all curriculum days by `title` or `description`.
- **500ms Input Debouncing**: Decouples high-frequency keyboard typing from UI filtering.
- **Stack-Preserving Deep Linking**: Uses `context.pushNamed(...)` so returning from a lesson preserves the active search query and scroll state.

### 🤖 D. Multi-Model BYOK AI Assistant
- **Supported Providers & Upgraded Models**:
  1. **Google Gemini**: `gemini-3.5-flash` (Speed & agentic-optimized model with low token overhead for longer query I/O).
  2. **OpenAI**: `gpt-5-mini` (High-accuracy compact reasoning).
  3. **Anthropic Claude**: `claude-3-5-haiku-20241022` (Upgraded from retired Claude 3 Haiku).
- **Deterministic Scope Policy (`QuestionScopePolicy`)**:
  - Pure Dart deterministic evaluator executed before any provider API call.
  - Classifies questions into `allowed`, `allowedComparison`, `clarificationNeeded`, or `refused`.
  - Immediate local refusal for standalone native platform tutorials (e.g. "teach me Kotlin from scratch") or off-topic queries with zero token consumption.
- **App-Lifecycle In-Memory Conversation Continuity**:
  - Maintained across screen navigations during the active app session via an app-lifecycle `@LazySingleton` BLoC.
  - Ephemeral in-memory storage (no database chat persistence).
  - Bounded windowing (`ConversationContextBuilder`) with strict turn and token budgets (max 6 turns / 4,000 characters).
- **Streaming & UI Controls**:
  - Immediate first-token emission followed by 80ms chunk throttling.
  - In-flight stream **Stop**, error **Retry**, **New Chat** session reset, and dynamic **Contextual Starter Prompt Chips**.

### 🔒 E. Secret Security & Privacy
- **Platform Encrypted Storage**: API keys are securely stored in hardware-backed platform Keychain (iOS) and KeyStore (Android) via `flutter_secure_storage`.
- **Masked Key State**: Raw API keys are never held or exposed in BLoC/Cubit states or logs. State stores only key presence and masked representation (`AIza••••••••0XYZ`).
- **Screen Protection (`no_screenshot`)**: Screenshots and screen recordings are automatically blocked on the AI Assistant Settings screen.
- **Typed Key Validation (`KeyValidationResult`)**: Validates keys against live provider endpoints with descriptive feedback (`valid`, `invalidKey`, `quotaExceeded`, `networkError`, `unknownError`).

### 📱 F. Tablet & iPad Responsive Optimization
- **Responsive Architecture (`ResponsiveExtension`)**:
  - Multi-breakpoint system: Small Phone ($\le 360$px), Normal Phone ($360$px - $600$px), Tablet ($\ge 600$px), and Wide Tablet/iPad ($\ge 1024$px).
  - Orientation-aware: Dynamically adapts across Portrait and Landscape.
  - Scaled Typography (`responsiveTextTheme`), dynamic padding (`responsivePadding`), scaled spacing (`responsiveHeightSpace`), and dynamic corner radiuses (`responsiveCircularRadius`).
- **Adaptive Grid Layouts**:
  - Mobile Portrait: 1 cross-axis item per row.
  - Tablet & Landscape: 2 cross-axis items per row for balanced, readable card layouts.
- **Landscape Bottom Sheet Constraints**:
  - Constrained to `maxWidth: context.screenWidth * 0.75` in tablet landscape to prevent overly wide, unreadable chat rows.
- **Dynamic Floating Action Button**:
  - FAB size scales proportionally (`context.screenHeight * 0.1` clamped to 60-120px on tablet; `context.screenWidth * 0.12` clamped to 40-60px on phone).

### 🚪 G. Double-Tap Back Press to Exit (`PopScope`)
- Intercepts system back gestures on the root `PhasesScreen` using Flutter's modern `PopScope`.
- Requires a second back tap within 2 seconds with SnackBar feedback, preventing accidental app termination.
