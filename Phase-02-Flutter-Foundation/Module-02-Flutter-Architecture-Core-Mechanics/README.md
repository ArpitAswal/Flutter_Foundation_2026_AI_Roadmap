# 📦 Module 02: Flutter Architecture & Core Mechanics

**Phase 02:** [Flutter Foundation](../README.md)

> [!NOTE]
> **Overview:** Master Flutter's underlying runtime mechanics: the Three Trees (Widget, Element, RenderObject), BuildContext navigation, widget identity with Keys, and scoped data propagation through InheritedWidget.

**Module Structure:** 3 Days of Deep Dives & Practical Exercises

---

## 📅 Day-by-Day Learning Roadmap

| Day | Lesson Title | Key Skills & Tags | Hands-On Challenge |
| :---: | :--- | :--- | :--- |
| **Day 17** | [BuildContext & The Three Trees (Widget, Element, RenderObject)](Day-17/README.md) | `Flutter` `BuildContext` `Three Trees` | Build a comprehensive, interactive diagnostic application... |
| **Day 18** | [Widget Keys & State Preservation](Day-18/README.md) | `Flutter` `Keys` `ValueKey` | Build an interactive, side-by-side demonstration proving ... |
| **Day 19** | [InheritedWidget & InheritedModel: Scoped Data Propagation & Aspect Subscriptions](Day-19/README.md) | `Flutter` `InheritedWidget` `InheritedModel` | Build a clean, robust scoped state management architectur... |

---

## 📘 Detailed Lesson Overview

### [Day 17: BuildContext & The Three Trees (Widget, Element, RenderObject)](Day-17/README.md)

Understand Flutter's internal runtime architecture by mastering the Three Trees: Widget Tree (declarative configuration), Element Tree (persistent runtime identity & lifecycle manager), and RenderObject Tree (layout, painting & hit testing). Learn what BuildContext actually is—a handle to the underlying Element—and how it enables ancestor lookups, theme resolution, navigation, and safe async operations via context.mounted.

**Tags:** `Flutter` `BuildContext` `Three Trees` `Widget Tree` `Element Tree` `RenderObject Tree` `Mounted` `Inherited Lookup` `Flutter Architecture`

[Start Day 17 Lesson ➔](Day-17/README.md)

---

### [Day 18: Widget Keys & State Preservation](Day-18/README.md)

Learn how Flutter preserves, moves, and manages widget state across rebuilds using Keys. Understand the Element reconciliation algorithm (Widget.canUpdate checking runtimeType and key), why stateful widgets in dynamic collections swap incorrectly without keys, the key hierarchy (LocalKey vs GlobalKey, ValueKey, ObjectKey, UniqueKey, PageStorageKey), and production use cases such as reorderable lists, form resets, and hero animations.

**Tags:** `Flutter` `Keys` `ValueKey` `ObjectKey` `UniqueKey` `GlobalKey` `PageStorageKey` `State Preservation` `Reconciliation` `List Reordering`

[Start Day 18 Lesson ➔](Day-18/README.md)

---

### [Day 19: InheritedWidget & InheritedModel: Scoped Data Propagation & Aspect Subscriptions](Day-19/README.md)

Master Flutter's built-in mechanism for ambient data sharing down the widget tree without constructor prop-drilling. Learn how InheritedWidget works under the hood, how updateShouldNotify selectively triggers rebuilds of dependent elements, the difference between dependOnInheritedWidgetOfExactType and getInheritedWidgetOfExactType, how InheritedModel enables aspect-based conditional rebuilds with updateShouldNotifyDependent, and why InheritedWidget is the foundational pillar for Provider, Riverpod, and BLoC.

**Tags:** `Flutter` `InheritedWidget` `InheritedModel` `Aspects` `Prop Drilling` `Scoped Data` `updateShouldNotify` `dependOnInheritedWidgetOfExactType` `Theme.of` `MediaQuery.of` `State Propagation`

[Start Day 19 Lesson ➔](Day-19/README.md)

---

[⬅️ Back to Phase 02: Flutter Foundation](../README.md)

