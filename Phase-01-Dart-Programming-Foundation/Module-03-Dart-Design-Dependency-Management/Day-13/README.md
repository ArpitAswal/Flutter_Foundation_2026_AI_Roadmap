# 📘 Day 13: Dependency Injection / Dependency Management

**Module 03:** [Dart Design & Dependency Management](../README.md) • **Phase 01:** [Dart Programming Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Learn how to manage dependencies explicitly in Dart and Flutter applications, with a focus on Dependency Injection as a practical application of the Dependency Inversion Principle learned in Day 12. This day teaches how to identify dependencies, separate dependency usage from dependency construction, inject dependencies through constructors, build dependency graphs & lifecycles, and make implementations replaceable for testing and production environments.

**Tags:** `Dart` `Flutter` `Dependency Injection` `Dependency Management` `Dependency Inversion Principle` `Constructor Injection` `Dependency Graph` `Composition Root` `Manual Dependency Injection` `Service Locator` `Dependency Boundaries` `Testability` `Composition` `Architecture`

---

## 🚦 Prerequisites
Dart classes, constructors, inheritance, method overriding, polymorphism, composition, abstract classes, interfaces, implements, class modifiers, mixins, and SOLID principles with particular understanding of the Dependency Inversion Principle from Day 12.

## 📖 Overview
Dependency Injection (DI) is a technique where an object receives the dependencies it needs from outside instead of creating those dependencies itself.

Consider:

```dart
class UserService {
  final ApiClient apiClient = ApiClient();
}
```

## 📚 Topics Covered
* **What Is Dependency Injection?**: Dependency Injection (DI) is a technique where an object receives the dependencies it needs from outside instead of creating those depend...
* **What Is a Dependency?**: A dependency is an object, service, abstraction, configuration value, or other required input that another component relies on to perform...
* **What Problem Does Dependency Injection Solve?**: The repository owns the construction of the API client, making those changes harder.
* **Why Does Dependency Injection Exist?**: A class should generally focus on using its collaborators to perform its responsibility.
* **Dependency Injection and Dependency Inversion Are Not the Same**: This distinction is extremely important.
* **Mental Model: Dependency Graph**: Think of an application as a graph of objects.
* **Constructor Injection**: Constructor injection is usually the simplest and clearest form of DI in Dart.
* **Why Constructor Injection Is Usually Preferred**: A test can provide a fake implementation without changing `UserService` itself.
* **Other Forms of Injection**: Dependency injection can technically be performed in several ways.
* **Composition Root**: The composition root is the place where the application's concrete dependencies are assembled.
* **Dependency Ownership**: > Who should own the creation of this dependency?
* **Manual Dependency Injection**: DI does not require a package.
* **Dependency Injection With Interfaces**: The `CheckoutService` does not change.
* **Service Locator vs Dependency Injection**: A service locator provides dependencies through a central registry.
* **Dependency Lifetimes**: Dependency management also involves deciding how long an object should live.
* **Singleton Is Not the Same as Dependency Injection**: A singleton controls instance creation globally.
* **Dependency Management in Flutter**: The concrete graph can be assembled near application startup or another appropriate composition boundary.
* **Dependency Injection and Testing**: One of the strongest benefits of DI is substitution.
* **Real-World Application**: Consider a Flutter e-commerce application.
* **Trade-Offs**: Dependency Injection provides explicit dependencies, easier substitution, better testability, and clearer construction ownership.
* **When Should You Use Dependency Injection?**: A dependency needs multiple implementations.
* **When Should You Avoid or Simplify It?**: The application is extremely small.

## 💡 Deep-Dive Materials Included

* **20 Interview Prep Scenarios** included
* **Technology Comparisons:** Use Constructor Injection When, Use Manual DI When, Consider a DI Framework When, Consider a Service Locator Carefully When, Avoid Additional Abstraction When
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 12: SOLID Principles in Dart & Flutter](../Day-12/README.md) | [📂 Module Index](../README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

