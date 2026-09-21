# 📘 Day 12: SOLID Principles in Dart & Flutter

**Module 03:** [Dart Design & Dependency Management](../README.md) • **Phase 01:** [Dart Programming Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Learn the five SOLID principles as practical engineering guidelines for designing maintainable Dart and Flutter applications. Apply them to real Flutter architecture, identify violations through code review, and understand when applying a principle improves a design versus when it creates unnecessary abstraction.

**Tags:** `Dart` `Flutter` `OOP` `SOLID` `Single Responsibility` `Open Closed Principle` `Liskov Substitution` `Interface Segregation` `Dependency Inversion` `Composition` `Abstraction` `Architecture` `Clean Architecture` `Code Review`

---

## 🚦 Prerequisites
Dart classes, inheritance, method overriding, polymorphism, composition, abstract classes, interfaces, implements, class modifiers, mixins, and the distinction between inheritance, reusable behavior, contracts, and composition.

## 📖 Overview
SOLID is a group of five object-oriented design principles that help developers reason about responsibility, coupling, extensibility, substitutability, interface design, and dependency direction.

The five principles are:

```text
S — Single Responsibility Principle
O — Open/Closed Principle
L — Liskov Substitution Principle
I — Interface Segregation Principle
D — Dependency Inversion Principle
```

## 📚 Topics Covered
* **What Is SOLID?**: SOLID is a group of five object-oriented design principles that help developers reason about responsibility, coupling, extensibility, sub...
* **What Is It?**: A module should have a single, coherent responsibility and therefore a focused reason to change.
* **What Problem Does It Solve?**: A change to the database can require modifying the same class as a UI change.
* **Better Separation**: Each component has a more focused responsibility.
* **SRP Does Not Mean One Method Per Class**: This is an important misconception.
* **Flutter Relationship**: The exact number of layers depends on the application's complexity.
* **What Is It?**: Software entities should be open for extension but closed for modification.
* **What Problem Does It Solve?**: Every new provider requires modifying `PaymentProcessor`.
* **Extension Through an Interface**: Adding another gateway extends the system without changing the checkout logic.
* **OCP Does Not Mean Never Modify Code**: Real production systems evolve.
* **What Is It?**: Subtypes should be usable wherever their base abstraction is expected without violating the expectations of the consuming code.
* **What Problem Does It Solve?**: The subtype technically satisfies the type relationship but violates the abstraction's behavioral expectation.
* **LSP Is About Contracts**: reject valid inputs that the contract permits
* **Flutter Example**: A fake implementation used in tests should preserve the relevant behavior expected by the consumer.
* **What Is It?**: Clients should not be forced to depend on methods they do not need.
* **What Problem Does It Solve?**: A payment consumer now depends on unrelated methods.
* **Better Design**: Consumers depend only on the capabilities they require.
* **ISP Is About Consumers**: > How many methods does an interface contain?
* **What Is It?**: High-level modules should not depend directly on low-level implementation details. Both should depend on abstractions.
* **What Problem Does It Solve?**: The high-level checkout logic directly controls its infrastructure dependency.
* **Dependency Inversion**: This reverses the dependency direction from the high-level application's perspective.
* **Dependency Inversion vs Dependency Injection**: These are related but not identical.

## 💡 Deep-Dive Materials Included

* **15 Interview Prep Scenarios** included
* **Technology Comparisons:** Use SRP When, Use OCP When, Use LSP When, Use ISP When, Use DIP When, Do Not Apply SOLID Mechanically When
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[📂 Module Index](../README.md) | [Day 13: Dependency Injection / Dependency Management ➡️](../Day-13/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

