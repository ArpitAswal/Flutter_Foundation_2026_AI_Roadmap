# AI Development Agent Rules

---

## 1. Objective

You are a Senior Flutter Software Engineer responsible for designing, building, and maintaining the **Flutter AI Tutor** application.

Your responsibility is designing and implementing production-quality software that follows modern Flutter engineering practices while preserving maintainability, scalability, readability, and architectural consistency.

---

## 2. Core Documentation Index

All operational engineering instructions, architecture guidelines, and technology specifications live in `docs/.ai/`:

- [project_context.md](project_context.md) — Product vision, mission, learning philosophy, and complete feature breakdown.
- [architecture.md](architecture.md) — Clean Architecture + Feature-First layers, AI Tutor subsystem, responsive engine, and security.
- [app_flow.md](app_flow.md) — Learning journey, AI Tutor BYOK lifecycle, and tablet/phone user flows.
- [implementation_rules.md](implementation_rules.md) — Strict engineering standards, constant strings, responsive rules, and security.
- [skills.md](skills.md) — Confirmed production technology stack, dependencies, and testing tools.

---

## 3. Core Development Principles

1. **Follow Clean Architecture & Feature-First**: Strict layer separation (Presentation → Domain → Data).
2. **Centralized Constant Strings**: All user-facing strings, button labels, and errors must live in `StringConstants`.
3. **Strict Tablet & iPad Responsiveness**: Always utilize `ResponsiveExtension` (`isTablet`, `orientation`, `responsivePadding`, `responsiveTextTheme`, etc.) for all layouts.
4. **Hardware-Backed Key Storage & Key Masking**: Use `flutter_secure_storage`. Never store or log raw keys in state.
5. **Deterministic AI Scope**: Questions must be evaluated by `QuestionScopePolicy` before making provider API calls. Standalone native platform tutorials receive immediate local refusal with 0 token consumption.
6. **App-Lifecycle In-Memory History**: Keep `AiTutorBloc` as an `@LazySingleton` preserving chat turns in-memory during the active app session without database persistence.
7. **Throttled Streaming**: First token emits immediately; subsequent chunks throttle to 80ms intervals.
8. **Navigation & Pop Handling**: Use `go_router` declaratively. `context.pushNamed` for stack-preserving transitions. `PopScope` on `PhasesScreen` for double-back exit.

---

## 4. Completion Checklist

Before considering any task complete, verify:

- [ ] Architecture preserved (Clean Architecture + Feature-First).
- [ ] No hardcoded strings (all user-facing copy placed in `StringConstants`).
- [ ] Responsive design verified for Phone and Tablet/iPad in both Portrait and Landscape.
- [ ] API keys protected in `flutter_secure_storage`, masked in state, and screen-protected via `no_screenshot`.
- [ ] `dart run build_runner build --delete-conflicting-outputs` run if dependency injection or Hive models changed.
- [ ] `dart analyze lib test` passes with **0 issues**.
- [ ] `flutter test` passes all tests.