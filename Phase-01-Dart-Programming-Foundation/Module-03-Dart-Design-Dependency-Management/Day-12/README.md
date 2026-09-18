# 📘 Day 12: SOLID Principles in Dart & Flutter

> [!NOTE]
> **Summary:** Learn the five SOLID principles as practical engineering guidelines for designing maintainable Dart and Flutter applications: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion. Apply them to real Flutter architecture, identify violations through code review, and understand when applying a principle improves a design versus when it creates unnecessary abstraction.

**Tags:** `Dart`, `Flutter`, `OOP`, `SOLID`, `Single Responsibility`, `Open Closed Principle`, `Liskov Substitution`, `Interface Segregation`, `Dependency Inversion`, `Composition`, `Abstraction`, `Architecture`, `Clean Architecture`, `Code Review`

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
* **What Is SOLID?**: SOLID is a group of five object-oriented design principles that help developers reason about responsibility, coupling, extensibility, substitutabil...
* **What Is It?**: A module should have a single, coherent responsibility and therefore a focused reason to change.
* **What Problem Does It Solve?**: Consider:
* **Better Separation**: And presentation remains separate:
* **SRP Does Not Mean One Method Per Class**: This is an important misconception.
* **Flutter Relationship**: A Flutter widget can become an SRP violation when it performs all of the following:
* **What Is It?**: Software entities should be open for extension but closed for modification.
* **What Problem Does It Solve?**: Consider:
* **Extension Through an Interface**: Implementations:
* **OCP Does Not Mean Never Modify Code**: Real production systems evolve.
* **What Is It?**: Subtypes should be usable wherever their base abstraction is expected without violating the expectations of the consuming code.
* **What Problem Does It Solve?**: Consider:
* **LSP Is About Contracts**: Suppose:
* **Flutter Example**: Suppose a UI depends on:
* **What Is It?**: Clients should not be forced to depend on methods they do not need.
* **What Problem Does It Solve?**: Bad design:
* **Better Design**: Split contracts according to consumer needs:
* **ISP Is About Consumers**: The important question is not:
* **What Is It?**: High-level modules should not depend directly on low-level implementation details. Both should depend on abstractions.
* **What Problem Does It Solve?**: Consider:
* **Dependency Inversion**: Define the abstraction:
* **Dependency Inversion vs Dependency Injection**: These are related but not identical.

## 💡 Additional Materials Included
* **15 Interview Questions** included
* **Comparisons:** Use SRP When, Use OCP When, Use LSP When, Use ISP When, Use DIP When, Do Not Apply SOLID Mechanically When
* **Common Mistakes & Optimizations** included
* **Architecture Implementation Notes** included

> [!TIP]
> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!
