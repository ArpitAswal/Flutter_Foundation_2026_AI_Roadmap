# 📘 Day 13: Dependency Injection / Dependency Management

> [!NOTE]
> **Summary:** Learn how to manage dependencies explicitly in Dart and Flutter applications, with a focus on Dependency Injection as a practical application of the Dependency Inversion Principle learned in Day 12. This day teaches how to identify dependencies, separate dependency usage from dependency construction, inject dependencies through constructors, build dependency graphs, establish composition roots, manage object ownership and lifecycles, and make implementations replaceable for testing and production environments.

**Tags:** `Dart`, `Flutter`, `Dependency Injection`, `Dependency Management`, `Dependency Inversion Principle`, `Constructor Injection`, `Dependency Graph`, `Composition Root`, `Manual Dependency Injection`, `Service Locator`, `Dependency Boundaries`, `Testability`, `Composition`, `Architecture`

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
* **What Is Dependency Injection?**: Dependency Injection (DI) is a technique where an object receives the dependencies it needs from outside instead of creating those dependencies its...
* **What Is a Dependency?**: A dependency is an object, service, abstraction, configuration value, or other required input that another component relies on to perform its respo...
* **What Problem Does Dependency Injection Solve?**: Consider a tightly coupled implementation:
* **Why Does Dependency Injection Exist?**: DI separates two different responsibilities:
* **Dependency Injection and Dependency Inversion Are Not the Same**: This distinction is extremely important.
* **Mental Model: Dependency Graph**: Think of an application as a graph of objects.
* **Constructor Injection**: Constructor injection is usually the simplest and clearest form of DI in Dart.
* **Why Constructor Injection Is Usually Preferred**: Constructor injection provides several useful properties:
* **Other Forms of Injection**: Dependency injection can technically be performed in several ways.
* **Composition Root**: The composition root is the place where the application's concrete dependencies are assembled.
* **Dependency Ownership**: One of the most important DI questions is:
* **Manual Dependency Injection**: DI does not require a package.
* **Dependency Injection With Interfaces**: Consider:
* **Service Locator vs Dependency Injection**: A service locator provides dependencies through a central registry.
* **Dependency Lifetimes**: Dependency management also involves deciding how long an object should live.
* **Singleton Is Not the Same as Dependency Injection**: Consider:
* **Dependency Management in Flutter**: A practical Flutter dependency graph might look like:
* **Dependency Injection and Testing**: One of the strongest benefits of DI is substitution.
* **Real-World Application**: Consider a Flutter e-commerce application.
* **Trade-Offs**: Dependency Injection provides explicit dependencies, easier substitution, better testability, and clearer construction ownership.
* **When Should You Use Dependency Injection?**: DI is particularly useful when:
* **When Should You Avoid or Simplify It?**: Do not introduce complex DI infrastructure when:

## 💡 Additional Materials Included
* **20 Interview Questions** included
* **Comparisons:** Use Constructor Injection When, Use Manual DI When, Consider a DI Framework When, Consider a Service Locator Carefully When, Avoid Additional Abstraction When
* **Common Mistakes & Optimizations** included
* **Architecture Implementation Notes** included

> [!TIP]
> **Deep Dive:** To read the full theory, view detailed code implementations, architectures, and common interview questions, open this lesson interactively inside the **Flutter AI Tutor App**!
